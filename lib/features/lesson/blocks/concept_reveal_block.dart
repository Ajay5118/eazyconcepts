import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/content_models.dart';

class ConceptRevealBlock extends StatefulWidget {
  final LessonBlock block;
  final bool isDark;
  const ConceptRevealBlock(
      {super.key, required this.block, required this.isDark});

  @override
  State<ConceptRevealBlock> createState() => _ConceptRevealBlockState();
}

class _ConceptRevealBlockState extends State<ConceptRevealBlock> {
  int _revealedCount = 1;

  @override
  Widget build(BuildContext context) {
    final steps = List<Map<String, dynamic>>.from(
        widget.block.data['steps'] as List? ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...steps.asMap().entries.map((entry) {
          final i = entry.key;
          final step = entry.value;
          final isRevealed = i < _revealedCount;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            opacity: isRevealed ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 400),
              offset: isRevealed ? Offset.zero : const Offset(0, 0.1),
              curve: Curves.easeOutCubic,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step number
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (step['title'] != null)
                            Text(
                              step['title'] as String,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: widget.isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          if (step['body'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              step['body'] as String,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        // Reveal next step button
        if (_revealedCount < steps.length)
          GestureDetector(
            onTap: () =>
                setState(() => _revealedCount++),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.buttonPurpleStart,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_downward_rounded,
                      size: 14, color: AppColors.buttonPurpleStart),
                  const SizedBox(width: 6),
                  Text(
                    'Show step ${_revealedCount + 1}',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.buttonPurpleStart),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
