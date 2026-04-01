// ─── star_row.dart ────────────────────────────────────────────────────────────
// lib/shared/widgets/star_row.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class StarRow extends StatelessWidget {
  final int earned;
  final int total;
  final double size;
  const StarRow({
    super.key,
    required this.earned,
    required this.total,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < earned;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: isFilled ? AppColors.starGold : AppColors.starEmpty,
        );
      }),
    );
  }
}
