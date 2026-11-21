import 'dart:math';

import 'package:bokboolbok_roulette/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_analytics.dart';
import '../design_tokens.dart';
import '../review_prompter.dart';
import 'mode_result_dialog.dart';

/// Splits participant indexes 0..[count)-1 into [teams] teams at random.
/// Team sizes differ by at most one.
List<List<int>> splitIntoTeams(int count, int teams, Random random) {
  assert(teams >= 1 && teams <= max(count, 1));
  final order = List<int>.generate(count, (i) => i)..shuffle(random);
  final result = List.generate(teams, (_) => <int>[]);
  for (var i = 0; i < order.length; i++) {
    result[i % teams].add(order[i]);
  }
  for (final team in result) {
    team.sort();
  }
  return result;
}

/// The "team split" tab below the shared participant list.
class TeamSplitPanel extends StatefulWidget {
  final List<String> names;

  /// Runs [next] after the result dialog closes: shows the interstitial
  /// first (unless ad-free), the same rule as the roulette.
  final void Function(VoidCallback next) afterResult;

  const TeamSplitPanel({
    super.key,
    required this.names,
    required this.afterResult,
  });

  @override
  State<TeamSplitPanel> createState() => TeamSplitPanelState();
}

/// Public so the home screen's bottom action bar can call [split].
class TeamSplitPanelState extends State<TeamSplitPanel> {
  final Random _random = Random();
  int _teamCount = 2;
  List<List<int>>? _result;

  int get _maxTeams => max(2, widget.names.length);

  @override
  void didUpdateWidget(covariant TeamSplitPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameNames(oldWidget.names, widget.names)) {
      _result = null;
    }
    if (_teamCount > _maxTeams) _teamCount = _maxTeams;
  }

  bool _sameNames(List<String> a, List<String> b) =>
      a.length == b.length &&
      List.generate(a.length, (i) => a[i] == b[i]).every((x) => x);

  /// Splits the current participants. Called from the bottom action bar.
  void split() {
    final n = widget.names.length;
    if (n < 2) return;
    final teams = _teamCount.clamp(2, n);
    final result = splitIntoTeams(n, teams, _random);
    AppAnalytics.teamSplit(participants: n, teams: teams);
    HapticFeedback.mediumImpact();
    setState(() => _result = result);
    _showResult(result);
  }

  String _shareMessage(AppLocalizations l10n, List<List<int>> result) {
    final lines = [
      l10n.shareTeamMessage(widget.names.length, result.length),
      for (var t = 0; t < result.length; t++)
        '${l10n.teamName(t + 1)}: ${result[t].map((i) => widget.names[i]).join(', ')}',
    ];
    return lines.join('\n');
  }

  void _showResult(List<List<int>> result) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder:
          (ctx) => ModeResultDialog(
            title: l10n.teamResultTitle,
            content: _TeamCards(names: widget.names, result: result),
            shareMessage: _shareMessage(l10n, result),
            participants: widget.names.length,
            mode: 'teams',
            againLabel: l10n.teamAgain,
            onClose: () {
              Navigator.pop(ctx);
              widget.afterResult(
                () => ReviewPrompter.onResult(canPrompt: true),
              );
            },
            onAgain: () {
              Navigator.pop(ctx);
              ReviewPrompter.onResult(canPrompt: false);
              widget.afterResult(split);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final n = widget.names.length;
    final teams = _teamCount.clamp(2, _maxTeams);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ModeStepper(
            label: l10n.teamCount,
            value: teams,
            decreaseLabel: l10n.decrease,
            increaseLabel: l10n.increase,
            onMinus:
                teams <= 2
                    ? null
                    : () => setState(() => _teamCount = teams - 1),
            onPlus:
                n < 2 || teams >= n
                    ? null
                    : () => setState(() => _teamCount = teams + 1),
          ),
          const SizedBox(height: 12),
          if (_result != null) ...[
            _TeamCards(names: widget.names, result: _result!),
            const SizedBox(height: 12),
          ],
          // The "split" button lives in the home screen's bottom bar.
          if (n < 2) ...[
            Text(
              l10n.noParticipants,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextSub, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _TeamCards extends StatelessWidget {
  final List<String> names;
  final List<List<int>> result;

  const _TeamCards({required this.names, required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var t = 0; t < result.length; t++) ...[
          if (t > 0) const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.teamName(t + 1)} · ${l10n.presetPersonCount(result[t].length)}',
                  style: const TextStyle(
                    color: kText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final i in result[t])
                      _NameChip(
                        name: i < names.length ? names[i] : '',
                        colorIndex: i,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _NameChip extends StatelessWidget {
  final String name;
  final int colorIndex;

  const _NameChip({required this.name, required this.colorIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: participantColor(colorIndex),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: kText, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Label   [-] value [+]" card, matching the roulette winner-count stepper.
class ModeStepper extends StatelessWidget {
  final String label;
  final int value;
  final String decreaseLabel;
  final String increaseLabel;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const ModeStepper({
    super.key,
    required this.label,
    required this.value,
    required this.decreaseLabel,
    required this.increaseLabel,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: kText,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              _RoundIconButton(
                icon: Icons.remove,
                tooltip: decreaseLabel,
                onPressed: onMinus,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$value',
                  style: const TextStyle(
                    color: kSuccess,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              _RoundIconButton(
                icon: Icons.add,
                tooltip: increaseLabel,
                onPressed: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Material IconButton: 48dp target, ripple, focus and a TalkBack label.
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 16),
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        foregroundColor: kTextSub,
        disabledForegroundColor: kBorder,
        backgroundColor: kCard,
        disabledBackgroundColor: kDisabled,
        side: const BorderSide(color: kBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
