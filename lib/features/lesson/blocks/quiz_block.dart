import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/content_models.dart';
import '../../../data/local/providers.dart';

class QuizBlock extends ConsumerStatefulWidget {
  final LessonBlock block;
  final bool isDark;
  const QuizBlock({super.key, required this.block, required this.isDark});

  @override
  ConsumerState<QuizBlock> createState() => _QuizBlockState();
}

class _QuizBlockState extends ConsumerState<QuizBlock> {
  String? _selectedAnswer;
  bool _answered = false;
  bool _showHint = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit(String answer) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
    });
    ref
        .read(lessonSessionProvider.notifier)
        .answerQuiz(widget.block.id, answer);
  }

  bool get _isCorrect {
    final correct =
        (widget.block.data['answer'] as String).trim().toLowerCase();
    return _selectedAnswer?.trim().toLowerCase() == correct;
  }

  @override
  Widget build(BuildContext context) {
    final quizTypeStr = widget.block.data['quizType'] as String? ?? 'mcq';
    final question = widget.block.data['question'] as String? ?? '';
    final hint = widget.block.data['hint'] as String?;
    final explanation = widget.block.data['explanation'] as String?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _answered
              ? (_isCorrect ? AppColors.success : AppColors.error)
              : (widget.isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: _answered ? 1.5 : 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz label
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Quick check',
                  style: AppTextStyles.overline
                      .copyWith(color: Colors.white),
                ),
              ),
              const Spacer(),
              if (hint != null && !_answered)
                GestureDetector(
                  onTap: () =>
                      setState(() => _showHint = !_showHint),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _showHint ? 'Hide hint' : 'Hint',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.warning),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Hint
          if (_showHint && hint != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hint,
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xFF633806),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Question
          Text(
            question,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Answer input based on type
          if (quizTypeStr == 'mcq') _buildMCQ(),
          if (quizTypeStr == 'trueFalse') _buildTrueFalse(),
          if (quizTypeStr == 'fillBlank') _buildTextInput(),
          if (quizTypeStr == 'equationInput') _buildTextInput(isEquation: true),

          // Result feedback
          if (_answered) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isCorrect
                      ? Icons.check_circle_rounded
                      : Icons.cancel_rounded,
                  size: 18,
                  color: _isCorrect ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 8),
                Text(
                  _isCorrect ? 'Correct!' : 'Not quite',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: _isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            if (!_isCorrect && explanation != null) ...[
              const SizedBox(height: 8),
              Text(
                explanation,
                style: AppTextStyles.bodySmall.copyWith(
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMCQ() {
    final options = List<String>.from(
        widget.block.data['options'] as List? ?? []);
    final correct = widget.block.data['answer'] as String;

    return Column(
      children: options.map((opt) {
        Color bg;
        Color borderColor;
        Color textColor;

        if (_answered) {
          if (opt == correct) {
            bg = AppColors.successLight;
            borderColor = AppColors.success;
            textColor = const Color(0xFF085041);
          } else if (opt == _selectedAnswer) {
            bg = AppColors.errorLight;
            borderColor = AppColors.error;
            textColor = const Color(0xFF791F1F);
          } else {
            bg = widget.isDark
                ? AppColors.darkSurface2
                : AppColors.lightSurface2;
            borderColor =
                widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
            textColor = widget.isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary;
          }
        } else {
          bg = widget.isDark
              ? AppColors.darkSurface2
              : AppColors.lightSurface2;
          borderColor =
              widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
          textColor = widget.isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary;
        }

        return GestureDetector(
          onTap: () => _submit(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Text(
              opt,
              style: AppTextStyles.bodySmall.copyWith(color: textColor),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrueFalse() {
    return Row(
      children: ['True', 'False'].map((opt) {
        final isSelected = _selectedAnswer == opt;
        final correct = widget.block.data['answer'] as String;
        Color bg;
        Color borderColor;
        Color textColor;

        if (_answered) {
          if (opt == correct) {
            bg = AppColors.successLight;
            borderColor = AppColors.success;
            textColor = const Color(0xFF085041);
          } else if (isSelected) {
            bg = AppColors.errorLight;
            borderColor = AppColors.error;
            textColor = const Color(0xFF791F1F);
          } else {
            bg = widget.isDark
                ? AppColors.darkSurface2
                : AppColors.lightSurface2;
            borderColor =
                widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
            textColor = widget.isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary;
          }
        } else {
          bg = widget.isDark
              ? AppColors.darkSurface2
              : AppColors.lightSurface2;
          borderColor =
              widget.isDark ? AppColors.darkBorder : AppColors.lightBorder;
          textColor = widget.isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => _submit(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: opt == 'True' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                opt,
                style: AppTextStyles.labelMedium
                    .copyWith(color: textColor),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput({bool isEquation = false}) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            enabled: !_answered,
            keyboardType:
                isEquation ? TextInputType.text : TextInputType.text,
            style: AppTextStyles.bodyMedium.copyWith(
              fontFamily: isEquation ? 'monospace' : null,
            ),
            decoration: InputDecoration(
              hintText: isEquation ? 'Enter equation...' : 'Your answer...',
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () => _submit(_textController.text),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Check',
              style: AppTextStyles.labelMedium
                  .copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
