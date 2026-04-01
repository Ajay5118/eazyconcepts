import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/content_models.dart';
import '../../../data/local/providers.dart';

/// Renders a sentence with underline blanks to fill in.
/// template: "The area of a circle is ___ × r²"
/// blanks: ["π"]
class FillInBlankBlock extends ConsumerStatefulWidget {
  final LessonBlock block;
  final bool isDark;
  const FillInBlankBlock(
      {super.key, required this.block, required this.isDark});

  @override
  ConsumerState<FillInBlankBlock> createState() =>
      _FillInBlankBlockState();
}

class _FillInBlankBlockState extends ConsumerState<FillInBlankBlock> {
  final List<TextEditingController> _controllers = [];
  final List<bool?> _results = [];
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    final blanks =
        List<String>.from(widget.block.data['blanks'] as List? ?? []);
    for (var _ in blanks) {
      _controllers.add(TextEditingController());
      _results.add(null);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _checkAnswers() {
    final blanks =
        List<String>.from(widget.block.data['blanks'] as List? ?? []);
    setState(() {
      _submitted = true;
      for (int i = 0; i < blanks.length; i++) {
        _results[i] = _controllers[i].text.trim().toLowerCase() ==
            blanks[i].trim().toLowerCase();
      }
    });
    // Record combined answer
    final combined = _controllers.map((c) => c.text).join('|');
    ref.read(lessonSessionProvider.notifier)
        .answerQuiz(widget.block.id, combined);
  }

  @override
  Widget build(BuildContext context) {
    final template = widget.block.data['template'] as String? ?? '';
    final blanks =
        List<String>.from(widget.block.data['blanks'] as List? ?? []);
    final hint = widget.block.data['hint'] as String?;

    final parts = template.split('___');
    int blankIndex = 0;

    final List<InlineSpan> spans = [];
    for (int i = 0; i < parts.length; i++) {
      // Add text part
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(
          text: parts[i],
          style: AppTextStyles.lessonBody.copyWith(
            color: widget.isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ));
      }
      // Add blank
      if (i < parts.length - 1 && blankIndex < blanks.length) {
        final idx = blankIndex;
        Color underlineColor;
        if (!_submitted) {
          underlineColor = AppColors.buttonPurpleStart;
        } else {
          underlineColor =
              _results[idx] == true ? AppColors.success : AppColors.error;
        }

        spans.add(WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 70,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextField(
              controller: _controllers[idx],
              enabled: !_submitted,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: widget.isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 4, vertical: 6),
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: underlineColor, width: 2),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: underlineColor, width: 2),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: underlineColor, width: 2),
                ),
                filled: false,
              ),
            ),
          ),
        ));
        blankIndex++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(text: TextSpan(children: spans)),
        const SizedBox(height: 12),

        if (_submitted)
          Row(
            children: [
              Icon(
                _results.every((r) => r == true)
                    ? Icons.check_circle_rounded
                    : Icons.cancel_rounded,
                size: 16,
                color: _results.every((r) => r == true)
                    ? AppColors.success
                    : AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                _results.every((r) => r == true)
                    ? 'Perfect!'
                    : 'Answer: ${blanks.join(', ')}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _results.every((r) => r == true)
                      ? AppColors.success
                      : AppColors.error,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              GestureDetector(
                onTap: _checkAnswers,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Check',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
              if (hint != null) ...[
                const SizedBox(width: 10),
                Text(
                  hint,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.warning),
                ),
              ],
            ],
          ),
      ],
    );
  }
}
