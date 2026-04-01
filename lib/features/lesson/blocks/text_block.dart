// ─── text_block.dart ──────────────────────────────────────────────────────────
// lib/features/lesson/blocks/text_block.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/models/content_models.dart';

class TextBlock extends StatelessWidget {
  final LessonBlock block;
  final bool isDark;
  const TextBlock({super.key, required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final markdown = block.data['markdown'] as String? ?? '';
    // TODO: Replace with flutter_markdown for full markdown support
    return Text(
      markdown,
      style: AppTextStyles.lessonBody.copyWith(
        color: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
      ),
    );
  }
}
