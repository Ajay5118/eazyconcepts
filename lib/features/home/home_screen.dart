import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/content_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../shared/widgets/gradient_card.dart';
import '../../shared/widgets/star_row.dart';
import '../../shared/widgets/xp_progress_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final contentLoaded = ref.watch(contentLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      // ✅ Removed hardcoded backgroundColor — lets AppBackground image show through
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: _HomeHeader(progress: progress),
            ),

            // ── Streak & stars row ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      iconColor: AppColors.cardOrangeEnd,
                      label: '${progress.currentStreakDays} day streak',
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.starGold,
                      label: '${progress.totalStars} stars',
                    ),
                    const SizedBox(width: 10),
                    _StatChip(
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.info,
                      label: '${progress.totalXp} XP',
                    ),
                  ],
                ),
              ),
            ),

            // ── Continue card ──
            if (progress.currentLessonId != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: _ContinueCard(lessonId: progress.currentLessonId!),
                ),
              ),

            // ── Section: Your subjects ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Your subjects',
                  style: AppTextStyles.headline3.copyWith(color: textPrimary),
                ),
              ),
            ),

            contentLoaded.when(
              data: (_) {
                final subjects = ContentRepository.instance.allSubjects;
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _SubjectCard(subject: subjects[i], ref: ref),
                      childCount: subjects.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Error: $e')),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final UserProgress progress;
  const _HomeHeader({required this.progress});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Stack(
        children: [
          // Pink glow overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.bgPinkOverlay.withOpacity(0.15),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Welcome back! 👋',
                            style: AppTextStyles.headline2.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.buttonGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Lv ${progress.level}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                XpProgressBar(progress: progress),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _StatChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          // ✅ Slight transparency so background image shows through chips too
          color: (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              .withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContinueCard extends ConsumerWidget {
  final String lessonId;
  const _ContinueCard({required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ContentRepository.instance.lessonById(lessonId);
    if (lesson == null) return const SizedBox.shrink();

    final chapter = ContentRepository.instance.chapterById(lesson.chapterId);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.lesson,
        arguments: lessonId,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Continue learning',
              style: AppTextStyles.overline.copyWith(
                color: Colors.white54,
                letterSpacing: 0.8,
                fontFamily: 'CinzelDecorative',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.title,
              style: AppTextStyles.headline3.copyWith(fontFamily: 'CinzelDecorative',color: Colors.white),
            ),
            if (chapter != null)
              Text(
                chapter.title,
                style: AppTextStyles.bodySmall.copyWith(fontFamily: 'CinzelDecorative',color: Colors.white60),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.45,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Resume →',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.buttonDeepVioletEnd,
                    ),
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

class _SubjectCard extends StatelessWidget {
  final dynamic subject;
  final WidgetRef ref;
  const _SubjectCard({required this.subject, required this.ref});

  @override
  Widget build(BuildContext context) {
    final gradient = subject.colorIndex == 0
        ? AppColors.mathGradient
        : AppColors.physicsGradient;
    final iconEmoji = subject.colorIndex == 0 ? '∑' : '⚛';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.subjects,
        arguments: subject.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                iconEmoji,
                style: const TextStyle(fontFamily: 'Cinzel',fontSize: 18, color: Colors.white),
              ),
            ),
            const Spacer(),
            Text(
              subject.name,
              style: AppTextStyles.headline3.copyWith(fontFamily: 'CinzelDecorative',color: Colors.white),
            ),
            const SizedBox(height: 2),
            Text(
              '${subject.moduleIds.length} modules',
              style: AppTextStyles.bodySmall.copyWith(fontFamily: 'Cinzel',color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}