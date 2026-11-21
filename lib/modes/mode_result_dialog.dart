import 'package:bokboolbok_roulette/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../result_share.dart';

/// Result dialog for the ladder and team modes. It mirrors the roulette
/// winner dialog: a featured card, a "share result" utility pill, and
/// close / play-again buttons.
class ModeResultDialog extends StatefulWidget {
  final String title;
  final Widget content;
  final String shareMessage;
  final int participants;
  final String mode;
  final String againLabel;
  final VoidCallback onClose;
  final VoidCallback onAgain;

  const ModeResultDialog({
    super.key,
    required this.title,
    required this.content,
    required this.shareMessage,
    required this.participants,
    required this.mode,
    required this.againLabel,
    required this.onClose,
    required this.onAgain,
  });

  @override
  State<ModeResultDialog> createState() => _ModeResultDialogState();
}

class _ModeResultDialogState extends State<ModeResultDialog> {
  final GlobalKey _shareKey = GlobalKey();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = AppLocalizations.of(context)!;
    final box = _shareKey.currentContext?.findRenderObject() as RenderBox?;
    final origin =
        box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _sharing = true);
    final ok = await shareResultText(
      '${widget.shareMessage}\n\n${l10n.shareInvite}',
      mode: widget.mode,
      participants: widget.participants,
      origin: origin,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.shareFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      backgroundColor: kCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: kBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kText,
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: SingleChildScrollView(child: widget.content),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              key: _shareKey,
              onPressed: _sharing ? null : _share,
              // Utility pill (DESIGN.md): grey surface, ink text, 20px radius.
              style: TextButton.styleFrom(
                backgroundColor: kSurface,
                foregroundColor: kText,
                disabledForegroundColor: kDisabled,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              icon: const Icon(Icons.ios_share, size: 16),
              label: Text(l10n.shareResult),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kText,
                      side: const BorderSide(color: kBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(l10n.close),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAction,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(widget.againLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A colored round badge with a number or initial, as used in result rows.
class ResultBadge extends StatelessWidget {
  final int colorIndex;
  final String text;

  const ResultBadge({super.key, required this.colorIndex, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: participantColor(colorIndex),
        shape: BoxShape.circle,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: participantTextColor(colorIndex),
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
