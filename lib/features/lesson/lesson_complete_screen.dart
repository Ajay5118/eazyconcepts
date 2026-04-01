import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/content_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../shared/widgets/star_row.dart';

class LessonCompleteScreen extends ConsumerStatefulWidget {
  final String lessonId;
  final CompletionResult? result;
  const LessonCompleteScreen({
    super.key,
    required this.lessonId,
    required this.result,
  });

  @override
  ConsumerState<LessonCompleteScreen> createState() =>
      _LessonCompleteScreenState();
}

class _LessonCompleteScreenState
    extends ConsumerState<LessonCompleteScreen>
    with TickerProviderStateMixin {
  late AnimationController _trophyCtrl;
  late AnimationController _starsCtrl;
  late AnimationController _rewardsCtrl;
  late Animation<double> _trophyScale;
  late Animation<double> _starsOpacity;
  late Animation<double> _rewardsSlide;

  @override
  void initState() {
    super.initState();

    _trophyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _starsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _rewardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _trophyScale = CurvedAnimation(
      parent: _trophyCtrl,
      curve: Curves.elasticOut,
    );
    _starsOpacity = CurvedAnimation(
      parent: _starsCtrl,
      curve: Curves.easeOut,
    );
    _rewardsSlide = CurvedAnimation(
      parent: _rewardsCtrl,
      curve: Curves.easeOutCubic,
    );

    // Staggered entrance
    Future.delayed(const Duration(milliseconds: 100), () {
      _trophyCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _starsCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      _rewardsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _trophyCtrl.dispose();
    _starsCtrl.dispose();
    _rewardsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ContentRepository.instance.lessonById(widget.lessonId);
    final chapter = lesson != null
        ? ContentRepository.instance.chapterById(lesson.chapterId)
        : null;
    final result = widget.result;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ── Trophy ──
              ScaleTransition(
                scale: _trophyScale,
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.cardGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cardGoldStart.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🏆',
                      style: TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'Lesson complete!',
                style: AppTextStyles.headline1.copyWith(color: textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                lesson?.title ?? '',
                style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                textAlign: TextAlign.center,
              ),
              if (chapter != null)
                Text(
                  chapter.title,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: textSecondary),
                ),

              const SizedBox(height: 28),

              // ── Stars earned ──
              FadeTransition(
                opacity: _starsOpacity,
                child: Column(
                  children: [
                    if (result?.chapterCompleted == true) ...[
                      _MilestoneBanner(
                        icon: '🎉',
                        label: 'Chapter complete! +5 stars',
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (result?.moduleCompleted == true) ...[
                      _MilestoneBanner(
                        icon: '🔥',
                        label: 'Module complete! +10 stars',
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (result?.leveledUp == true) ...[
                      _MilestoneBanner(
                        icon: '⬆️',
                        label:
                            'Level up! You\'re now level ${result?.newLevel}',
                        color: AppColors.buttonPurpleStart,
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('⭐',
                            style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          '+${result?.starsEarned ?? 1} star earned',
                          style: AppTextStyles.headline3
                              .copyWith(color: AppColors.starGold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Reward stats ──
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(_rewardsSlide),
                child: FadeTransition(
                  opacity: _rewardsSlide,
                  child: Row(
                    children: [
                      _RewardStat(
                        value: '+${result?.xpEarned ?? 50}',
                        label: 'XP gained',
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _RewardStat(
                        value: '${result?.accuracyPercent ?? 100}%',
                        label: 'Accuracy',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Chapter progress bar ──
              if (chapter != null) ...[
                const SizedBox(height: 20),
                _ChapterProgressBar(
                  chapter: chapter,
                  isDark: isDark,
                ),
              ],

              const Spacer(),

              // ── Action buttons ──
              _ActionButtons(
                lessonId: widget.lessonId,
                isDark: isDark,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _MilestoneBanner extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;
  const _MilestoneBanner({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _RewardStat extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;
  const _RewardStat({
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTextStyles.headline2.copyWith(
                color: AppColors.buttonPurpleStart,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterProgressBar extends ConsumerWidget {
  final Chapter chapter;
  final bool isDark;
  const _ChapterProgressBar({required this.chapter, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final cp = progress.chapterProgress[chapter.id];
    final completed = cp?.completedLessons ?? 0;
    final total = cp?.totalLessons ?? chapter.lessonIds.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.buttonDeepVioletEnd.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.buttonPurpleStart.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Chapter progress',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.buttonPurpleStart,
                ),
              ),
              Text(
                '$completed / $total lessons',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.buttonPurpleStart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : completed / total,
              backgroundColor:
                  AppColors.buttonPurpleStart.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation(
                  AppColors.buttonPurpleStart),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            completed < total
                ? '${total - completed} more lesson${total - completed > 1 ? 's' : ''} to earn 5 chapter stars ⭐⭐⭐⭐⭐'
                : 'Chapter complete! All stars earned 🎉',
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  final String lessonId;
  final bool isDark;
  const _ActionButtons({required this.lessonId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextLesson =
        ContentRepository.instance.nextLesson(lessonId);

    return Column(
      children: [
        if (nextLesson != null)
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(
              context,
              AppRoutes.lesson,
              arguments: nextLesson.id,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.buttonGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                'Continue to next lesson →',
                style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
              ),
            ),
          ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.popUntil(
            context,
            (route) => route.settings.name == AppRoutes.shell,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'Back to subjects',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
