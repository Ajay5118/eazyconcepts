import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../shared/widgets/star_row.dart';

class ChapterScreen extends ConsumerWidget {
  final String moduleId;
  final String chapterId;
  const ChapterScreen({
    super.key,
    required this.moduleId,
    required this.chapterId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapter = ContentRepository.instance.chapterById(chapterId);
    final lessons = ContentRepository.instance.lessonsForChapter(chapterId);
    final progress = ref.watch(progressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (chapter == null) {
      return const Scaffold(body: Center(child: Text('Chapter not found')));
    }

    final cp = progress.chapterProgress[chapterId];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: CustomScrollView(
        slivers: [
          // ── Chapter header (collapsing) ──
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGradient,
                ),
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      chapter.title,
                      style: AppTextStyles.headline2
                          .copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${lessons.length} lessons',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: Colors.white60),
                        ),
                        const SizedBox(width: 12),
                        StarRow(
                          earned: cp?.starsEarned ?? 0,
                          total: 5,
                          size: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Chapter summary ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                chapter.summary,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
          ),

          // ── Progress bar ──
          if (cp != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary,
                          ),
                        ),
                        Text(
                          '${cp.completedLessons} / ${lessons.length}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.buttonPurpleStart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: lessons.isEmpty
                            ? 0
                            : cp.completedLessons / lessons.length,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.buttonPurpleStart),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Lessons label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Text(
                'Lessons',
                style: AppTextStyles.headline3.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ),

          // ── Lesson list ──
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final lesson = lessons[i];
                  final lp = progress.lessonProgress[lesson.id];
                  final isCompleted = lp?.isCompleted ?? false;
                  final isNext = !isCompleted &&
                      (i == 0 ||
                          (progress.lessonProgress[lessons[i - 1].id]
                                  ?.isCompleted ??
                              false));

                  return GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.lesson,
                      arguments: lesson.id,
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isNext
                              ? AppColors.buttonPurpleStart.withOpacity(0.4)
                              : (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder),
                          width: isNext ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Status icon
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isCompleted
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.success,
                                        Color(0xFF0F6E56)
                                      ],
                                    )
                                  : isNext
                                      ? AppColors.buttonGradient
                                      : null,
                              color: (!isCompleted && !isNext)
                                  ? (isDark
                                      ? AppColors.darkSurface2
                                      : AppColors.lightSurface2)
                                  : null,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: isCompleted
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white)
                                : Text(
                                    '${i + 1}',
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: isNext
                                          ? Colors.white
                                          : (isDark
                                              ? AppColors.darkTextTertiary
                                              : AppColors.lightTextTertiary),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lesson.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    fontWeight: isNext
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  '${lesson.estimatedMinutes} min',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCompleted)
                            const Icon(Icons.star_rounded,
                                size: 16, color: AppColors.starGold)
                          else if (isNext)
                            const Icon(Icons.play_arrow_rounded,
                                size: 20,
                                color: AppColors.buttonPurpleStart),
                        ],
                      ),
                    ),
                  );
                },
                childCount: lessons.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
