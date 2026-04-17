import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../core/models/content_models.dart';
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

                  return _VerticalLessonCard(
                    lesson: lesson,
                    isCompleted: isCompleted,
                    isNext: isNext,
                    index: i,
                    totalLessons: lessons.length,
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

// ─────────────────────────────────────────────────────────────────────────────
// Vertical Lesson Card (Flode Style Implementation)
// ─────────────────────────────────────────────────────────────────────────────
class _VerticalLessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final bool isNext;
  final int index;
  final int totalLessons;

  const _VerticalLessonCard({
    required this.lesson,
    required this.isCompleted,
    required this.isNext,
    required this.index,
    required this.totalLessons,
  });

  String get _lessonType {
    if (lesson.blocks.any((b) => b.type == LessonBlockType.quiz)) return 'quiz';
    if (lesson.blocks.any((b) => b.type == LessonBlockType.interactive)) return 'practice';
    return 'lesson';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.lesson, arguments: lesson.id),
      child: Container(
        height: 140,
        margin: const EdgeInsets.only(bottom: 20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Vertical connecting divider to next ──
            if (index != totalLessons - 1)
              Positioned(
                top: 80,
                bottom: -30,
                left: 60,
                child: Container(
                  width: 5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(35, 10, 62, 1),
                        Color.fromRGBO(140, 72, 205, 1),
                        Color.fromRGBO(35, 10, 62, 1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

            // ── Card background (Square badge) ──
            Positioned(
              top: 10,
              left: 0,
              child: Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/chapter_card.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: Center(
                  child: Image.asset(
                    _lessonType == 'quiz' ? 'assets/img/practice.png' 
                    : _lessonType == 'practice' ? 'assets/img/lession.png'
                    : 'assets/img/ccc.png',
                    width: 45,
                    errorBuilder: (_, __, ___) => const Icon(Icons.menu_book_rounded, color: Colors.white),
                  ),
                ),
              ),
            ),

            // ── Text Label Box (Border wrapper) ──
            Positioned(
              top: 30,
              left: 95, 
              right: 0,
              child: Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/img/card_border.png'),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      _lessonType == 'lesson' ? 'assets/img/piano.png' : 'assets/img/play.png',
                      height: 30,
                      errorBuilder: (_, __, ___) => const Icon(Icons.play_circle_fill, color: AppColors.buttonDeepVioletEnd),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                             lesson.title,
                             style: AppTextStyles.headline3.copyWith(
                               fontSize: 13,
                               color: AppColors.buttonDeepVioletEnd,
                             ),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                           Text(
                             '${_lessonType.toUpperCase()} • ${lesson.estimatedMinutes} min',
                             style: AppTextStyles.labelSmall.copyWith(
                               color: Colors.grey.shade700,
                               fontSize: 10,
                             ),
                           ),
                        ],
                      ),
                    ),
                    if (isCompleted)
                      Image.asset('assets/img/star_2.png', height: 35, errorBuilder: (_, __, ___) => const Icon(Icons.star_rounded, color: AppColors.starGold, size: 28))
                    else if (isNext)
                      const Icon(Icons.play_circle_fill_rounded, color: AppColors.buttonPurpleStart, size: 28),
                  ],
                ),
              ),
            ),
            
            // ── Stars on top left if rated ──
            if (isCompleted)
              Positioned(
                 top: -10,
                 left: 30,
                 child: Row(
                   children: [
                     Image.asset('assets/img/star_1.png', height: 20),
                     Image.asset('assets/img/star_2.png', height: 30),
                     Image.asset('assets/img/star_3.png', height: 20),
                   ],
                 ),
              ),
          ],
        ),
      ),
    );
  }
}
