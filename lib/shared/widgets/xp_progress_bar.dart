import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/models/content_models.dart';

class XpProgressBar extends StatelessWidget {
  final UserProgress progress;
  final bool showLabel;
  const XpProgressBar({
    super.key,
    required this.progress,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = progress.levelProgress.clamp(0.0, 1.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: const AlwaysStoppedAnimation(AppColors.starGold),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${progress.totalXp} XP',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
            Text(
              showLabel
                  ? 'Level ${progress.level} → ${progress.level + 1}'
                  : '${progress.xpForNextLevel} XP to next level',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
