import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:audioplayers/audioplayers.dart';
import 'package:bokboolbok_roulette/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_analytics.dart';
import '../design_tokens.dart';
import '../review_prompter.dart';
import 'mode_result_dialog.dart';

// ─── Ladder logic ─────────────────────────────────────────────────────────────

/// `rungs[row][gap]` is true when a rung joins column `gap` and `gap + 1`
/// on that row. Two rungs never touch on the same row, and every gap has at
/// least one rung.
///
/// Fairness: the outcome is drawn first as a uniformly random permutation,
/// and the ladder is built to produce exactly it. A few random "noise" rows
/// come first so the ladder looks hand-drawn; correction rows after them
/// (adjacent swaps from a bubble sort, packed into rows) turn whatever the
/// noise did into the chosen outcome. So every participant is equally likely
/// to reach every slot, at any size.
List<List<bool>> generateRungs(
  int columns,
  Random random, {
  int noiseRows = 6,
}) {
  if (columns < 2) return const [];
  final gaps = columns - 1;
  final rungs = <List<bool>>[];

  // 1. Noise rows: random, non-touching rungs.
  for (var r = 0; r < noiseRows; r++) {
    final row = List<bool>.filled(gaps, false);
    for (var g = 0; g < gaps; g++) {
      if (g > 0 && row[g - 1]) continue;
      row[g] = random.nextDouble() < 0.5;
    }
    rungs.add(row);
  }

  // 2. Target: participant i ends at slot target[i], uniformly at random.
  final target = List<int>.generate(columns, (i) => i)..shuffle(random);

  // After the noise, participant i stands in column at[i]; the value we must
  // carry to the bottom for whoever stands in column c is want[c].
  final noiseMapping = ladderMapping(rungs, columns);
  final want = List<int>.filled(columns, 0);
  for (var i = 0; i < columns; i++) {
    want[noiseMapping[i]] = target[i];
  }

  // 3. Bubble-sort `want`; every swap of columns g, g+1 is one rung. Pack
  // each swap into the earliest row after any rung it shares a column with,
  // which keeps the swaps' effect and never puts two rungs side by side.
  final correction = <List<bool>>[];
  final lastRow = List<int>.filled(gaps, -1);
  final a = [...want];
  for (var i = 0; i < columns; i++) {
    for (var g = 0; g < gaps - i; g++) {
      if (a[g] <= a[g + 1]) continue;
      final t = a[g];
      a[g] = a[g + 1];
      a[g + 1] = t;
      var row = lastRow[g];
      if (g > 0) row = max(row, lastRow[g - 1]);
      if (g < gaps - 1) row = max(row, lastRow[g + 1]);
      row += 1;
      while (correction.length <= row) {
        correction.add(List<bool>.filled(gaps, false));
      }
      correction[row][g] = true;
      lastRow[g] = row;
    }
  }
  rungs.addAll(correction);

  // 4. A gap with no rung at all looks broken: add a pair of rungs on it in
  // two new rows. Two swaps on the same gap cancel, so the outcome stays.
  for (var g = 0; g < gaps; g++) {
    if (rungs.any((row) => row[g])) continue;
    final insertAt = random.nextInt(rungs.length + 1);
    final pair = List<bool>.filled(gaps, false)..[g] = true;
    rungs.insertAll(insertAt, [
      pair,
      [...pair],
    ]);
  }
  return rungs;
}

/// Grid points of the path that starts at the top of [start]: x is a column
/// index, y runs from 0 (top) to rows + 1 (bottom).
List<Point<int>> ladderPath(List<List<bool>> rungs, int start) {
  var c = start;
  final points = <Point<int>>[Point(c, 0)];
  for (var r = 0; r < rungs.length; r++) {
    points.add(Point(c, r + 1));
    if (c < rungs[r].length && rungs[r][c]) {
      c++;
      points.add(Point(c, r + 1));
    } else if (c > 0 && rungs[r][c - 1]) {
      c--;
      points.add(Point(c, r + 1));
    }
  }
  points.add(Point(c, rungs.length + 1));
  return points;
}

/// The bottom slot each top column ends at. Always a permutation.
List<int> ladderMapping(List<List<bool>> rungs, int columns) =>
    List.generate(columns, (i) => ladderPath(rungs, i).last.x);

// ─── Ladder tab ───────────────────────────────────────────────────────────────

const _kResultsKey = 'ladder_results';
const double _kColumnMinWidth = 72;
const double _kNameRowHeight = 44;
const double _kLadderMinHeight = 280;
const double _kRowHeight = 18;

/// Same length as the roulette spin (CircularPanPhysics, 2s).
const Duration _kDrawDuration = Duration(seconds: 2);
const double _kResultRowHeight = 48;

class LadderPanel extends StatefulWidget {
  final List<String> names;

  /// Runs [next] after the result dialog closes: shows the interstitial
  /// first (unless ad-free), the same rule as the roulette.
  final void Function(VoidCallback next) afterResult;
  final ValueChanged<bool> onBusyChanged;

  const LadderPanel({
    super.key,
    required this.names,
    required this.afterResult,
    required this.onBusyChanged,
  });

  @override
  State<LadderPanel> createState() => LadderPanelState();
}

/// Public so the home screen's bottom action bar can call [start].
class LadderPanelState extends State<LadderPanel>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final AudioPlayer _winPlayer = AudioPlayer();
  late final AnimationController _progress;
  List<List<bool>>? _rungs;
  List<String>? _stored;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: _kDrawDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _onFinished();
      });
    _loadResults();
  }

  @override
  void dispose() {
    _progress.dispose();
    _winPlayer.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LadderPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final same =
        oldWidget.names.length == widget.names.length &&
        List.generate(
          widget.names.length,
          (i) => oldWidget.names[i] == widget.names[i],
        ).every((x) => x);
    if (!same && !_busy) {
      _rungs = null;
      _progress.value = 0;
    }
  }

  Future<void> _loadResults() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_kResultsKey);
    if (mounted) setState(() => _stored = list);
  }

  Future<void> _saveResults(List<String>? list) async {
    final prefs = await SharedPreferences.getInstance();
    if (list == null) {
      await prefs.remove(_kResultsKey);
    } else {
      await prefs.setStringList(_kResultsKey, list);
    }
  }

  /// One result per participant: the saved ones first, then defaults
  /// ("win" in the first slot of a fresh ladder, "blank" everywhere else).
  List<String> _results(AppLocalizations l10n) {
    final base = _stored ?? const <String>[];
    return List.generate(widget.names.length, (i) {
      if (i < base.length && base[i].trim().isNotEmpty) return base[i];
      return i == 0 && base.isEmpty ? l10n.ladderWin : l10n.ladderLose;
    });
  }

  /// The current ladder, or null when it no longer fits the participant
  /// count (the list changed since it was drawn).
  List<List<bool>>? _validRungs(int n) {
    final r = _rungs;
    if (r == null || r.isEmpty || r.first.length != n - 1) return null;
    return r;
  }

  void _setBusy(bool value) {
    setState(() => _busy = value);
    widget.onBusyChanged(value);
  }

  /// Draws a new ladder. Called from the bottom action bar.
  void start() {
    final n = widget.names.length;
    if (_busy || n < 2) return;
    _setBusy(true);
    AppAnalytics.ladderStart(participants: n);
    HapticFeedback.mediumImpact();
    setState(() => _rungs = generateRungs(n, _random));
    // DESIGN.md §15: under reduced motion the reveal is instant.
    _progress.duration =
        MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : _kDrawDuration;
    _progress.forward(from: 0);
  }

  void _onFinished() {
    if (!mounted || _rungs == null) return;
    if (_validRungs(widget.names.length) == null) {
      // The list changed mid-run; drop the stale ladder instead of crashing.
      _rungs = null;
      _progress.value = 0;
      _setBusy(false);
      return;
    }
    HapticFeedback.heavyImpact();
    _winPlayer.play(AssetSource('sounds/win.wav'));
    _setBusy(false);
    _showResult();
  }

  void _showResult() {
    final l10n = AppLocalizations.of(context)!;
    final names = widget.names;
    final results = _results(l10n);
    final mapping = ladderMapping(_rungs!, names.length);
    final share = [
      l10n.shareLadderMessage(names.length),
      for (var i = 0; i < names.length; i++)
        '${names[i]} → ${results[mapping[i]]}',
    ].join('\n');
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (ctx) => ModeResultDialog(
            title: l10n.ladderResultTitle,
            content: Column(
              children: [
                for (var i = 0; i < names.length; i++) ...[
                  if (i > 0) const SizedBox(height: 6),
                  _ResultRow(
                    colorIndex: i,
                    name: names[i],
                    result: results[mapping[i]],
                  ),
                ],
              ],
            ),
            shareMessage: share,
            participants: names.length,
            mode: 'ladder',
            againLabel: l10n.ladderAgain,
            onClose: () {
              Navigator.pop(ctx);
              widget.afterResult(
                () => ReviewPrompter.onResult(canPrompt: true),
              );
            },
            onAgain: () {
              Navigator.pop(ctx);
              ReviewPrompter.onResult(canPrompt: false);
              widget.afterResult(start);
            },
          ),
    );
  }

  Future<void> _editResult(int slot) async {
    final l10n = AppLocalizations.of(context)!;
    final current = _results(l10n);
    final controller = TextEditingController(text: current[slot]);
    final value = await showDialog<String>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.ladderEditTitle),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLength: 20,
              decoration: const InputDecoration(counterText: ''),
              onSubmitted: (v) => Navigator.pop(ctx, v),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: Text(l10n.save),
              ),
            ],
          ),
    );
    controller.dispose();
    if (value == null || !mounted) return;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return;
    final updated = [...current]..[slot] = trimmed;
    setState(() => _stored = updated);
    _saveResults(updated);
  }

  void _resetResults() {
    setState(() => _stored = null);
    _saveResults(null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final names = widget.names;
    final n = names.length;
    final results = _results(l10n);
    final rungs = _validRungs(n);
    final done = rungs != null && _progress.isCompleted;
    final mapping = rungs == null ? null : ladderMapping(rungs, n);
    final ladderHeight =
        rungs == null
            ? _kLadderMinHeight
            : max(_kLadderMinHeight, (rungs.length + 1) * _kRowHeight);
    // Which participant lands on each bottom slot, once the run is done.
    final arrivals = <int, int>{
      if (done && mapping != null)
        for (var i = 0; i < n; i++) mapping[i]: i,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (n < 2)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.noParticipants,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextSub),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.ladderEditHint,
                    style: const TextStyle(color: kTextSub, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: _busy || _stored == null ? null : _resetResults,
                  style: TextButton.styleFrom(
                    foregroundColor: kTextSub,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text(l10n.ladderResetResults),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: kCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Wider columns at large font sizes so names still fit.
                  final colWidth = max(
                    MediaQuery.textScalerOf(context).scale(_kColumnMinWidth),
                    constraints.maxWidth / n,
                  );
                  final width = colWidth * n;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      child: Column(
                        children: [
                          SizedBox(
                            height: _kNameRowHeight,
                            child: Row(
                              children: [
                                for (var i = 0; i < n; i++)
                                  SizedBox(
                                    width: colWidth,
                                    child: _NameLabel(
                                      name: names[i],
                                      colorIndex: i,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: ladderHeight,
                            width: width,
                            child: AnimatedBuilder(
                              animation: _progress,
                              builder:
                                  (_, __) => CustomPaint(
                                    painter: _LadderPainter(
                                      columns: n,
                                      rungs: rungs,
                                      progress: _progress.value,
                                    ),
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: _kResultRowHeight,
                            child: Row(
                              children: [
                                for (var s = 0; s < n; s++)
                                  SizedBox(
                                    width: colWidth,
                                    child: _ResultSlot(
                                      text: results[s],
                                      arrivedColor:
                                          arrivals[s] == null
                                              ? null
                                              : participantColor(arrivals[s]!),
                                      onTap:
                                          _busy ? null : () => _editResult(s),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // The "start" button lives in the home screen's bottom bar.
          ],
        ],
      ),
    );
  }
}

class _NameLabel extends StatelessWidget {
  final String name;
  final int colorIndex;

  const _NameLabel({required this.name, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: participantColor(colorIndex),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: kText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSlot extends StatelessWidget {
  final String text;
  final Color? arrivedColor;
  final VoidCallback? onTap;

  const _ResultSlot({required this.text, this.arrivedColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: arrivedColor ?? kBorder,
              width: arrivedColor == null ? 1 : 2,
            ),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: kText,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final int colorIndex;
  final String name;
  final String result;

  const _ResultRow({
    required this.colorIndex,
    required this.name,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          ResultBadge(
            colorIndex: colorIndex,
            text: name.isEmpty ? '' : name.characters.first,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kText, fontSize: 15),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 16, color: kTextSub),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              result,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: kText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LadderPainter extends CustomPainter {
  final int columns;
  final List<List<bool>>? rungs;
  final double progress;

  _LadderPainter({
    required this.columns,
    required this.rungs,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final colWidth = size.width / columns;
    const topPad = 6.0;
    const bottomPad = 6.0;
    final usable = size.height - topPad - bottomPad;
    final rowCount = rungs?.length ?? 10;
    final rowStep = usable / (rowCount + 1);
    double x(int c) => colWidth * (c + 0.5);
    double y(int r) => topPad + rowStep * r;

    final rail =
        Paint()
          ..color = kDisabled
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;
    for (var c = 0; c < columns; c++) {
      canvas.drawLine(Offset(x(c), y(0)), Offset(x(c), y(rowCount + 1)), rail);
    }

    final rs = rungs;
    if (rs == null) return;
    for (var r = 0; r < rs.length; r++) {
      for (var g = 0; g < rs[r].length; g++) {
        if (rs[r][g]) {
          canvas.drawLine(
            Offset(x(g), y(r + 1)),
            Offset(x(g + 1), y(r + 1)),
            rail,
          );
        }
      }
    }

    for (var c = 0; c < columns; c++) {
      final points = ladderPath(rs, c);
      final path = Path()..moveTo(x(points.first.x), y(points.first.y));
      for (final p in points.skip(1)) {
        path.lineTo(x(p.x), y(p.y));
      }
      final paint =
          Paint()
            ..color = participantColor(c)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round;
      for (final PathMetric metric in path.computeMetrics()) {
        canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LadderPainter old) =>
      old.progress != progress || old.rungs != rungs || old.columns != columns;
}
