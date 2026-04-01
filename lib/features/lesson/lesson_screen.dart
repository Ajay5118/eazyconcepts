import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../core/models/content_models.dart';
import 'blocks/text_block.dart';
import 'blocks/equation_block.dart';
import 'blocks/quiz_block.dart';
import 'blocks/concept_reveal_block.dart';
import 'blocks/fill_in_blank_block.dart';
import 'blocks/interactive_block.dart';

class LessonScreen extends ConsumerStatefulWidget {
  final String lessonId;
  const LessonScreen({super.key, required this.lessonId});

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lesson = ContentRepository.instance.lessonById(widget.lessonId);
      if (lesson != null) {
        ref.read(lessonSessionProvider.notifier).startLesson(lesson);
        // Track as current lesson for 'Resume' on home screen
        ref.read(progressProvider.notifier).setCurrentLesson(lesson.id);
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() {
      _scrollProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _completeLesson() async {
    final session = ref.read(lessonSessionProvider);
    if (session == null) return;

    final lesson = session.lesson;
    final chapter =
        ContentRepository.instance.chapterById(lesson.chapterId);
    final module = chapter != null
        ? ContentRepository.instance.moduleById(chapter.moduleId)
        : null;

    if (chapter == null || module == null) return;

    final chapters =
        ContentRepository.instance.chaptersForModule(module.id);
    final lessons =
        ContentRepository.instance.lessonsForChapter(chapter.id);

    final result = await ref.read(progressProvider.notifier).completeLesson(
          lessonId: lesson.id,
          chapterId: chapter.id,
          moduleId: module.id,
          totalLessonsInChapter: lessons.length,
          totalChaptersInModule: chapters.length,
          accuracyPercent: session.accuracyPercent,
        );

    ref.read(lessonSessionProvider.notifier).endLesson();

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.lessonComplete,
      arguments: {'lessonId': lesson.id, 'result': result},
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = ContentRepository.instance.lessonById(widget.lessonId);
    if (lesson == null) {
      return const Scaffold(
        body: Center(child: Text('Lesson not found')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Column(
        children: [
          // ── Lesson top bar ──
          _LessonTopBar(
            lesson: lesson,
            scrollProgress: _scrollProgress,
            isDark: isDark,
          ),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lesson title
                  Text(
                    lesson.title,
                    style: AppTextStyles.lessonConceptTitle.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (lesson.subtitle.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      lesson.subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),

                  // ── Lesson blocks ──
                  ...lesson.blocks.map((block) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildBlock(block, isDark),
                      )),

                  // ── Complete button ──
                  const SizedBox(height: 16),
                  _CompleteLessonButton(onTap: _completeLesson),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlock(LessonBlock block, bool isDark) {
    switch (block.type) {
      case LessonBlockType.text:
        return TextBlock(block: block, isDark: isDark);
      case LessonBlockType.equation:
        return EquationBlock(block: block, isDark: isDark);
      case LessonBlockType.quiz:
        return QuizBlock(block: block, isDark: isDark);
      case LessonBlockType.conceptReveal:
        return ConceptRevealBlock(block: block, isDark: isDark);
      case LessonBlockType.fillInBlank:
        return FillInBlankBlock(block: block, isDark: isDark);
      case LessonBlockType.interactive:
        return InteractiveBlock(block: block, isDark: isDark);
      case LessonBlockType.image:
        return _ImageBlock(block: block, isDark: isDark);
      case LessonBlockType.animation:
        return _AnimationBlock(block: block);
    }
  }
}

// ── Top bar with progress strip ───────────────────────────────────────────────

class _LessonTopBar extends StatelessWidget {
  final Lesson lesson;
  final double scrollProgress;
  final bool isDark;

  const _LessonTopBar({
    required this.lesson,
    required this.scrollProgress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
                Expanded(
                  child: Text(
                    lesson.title,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          // Scroll progress bar
          Stack(
            children: [
              Container(
                height: 3,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 3,
                width: MediaQuery.of(context).size.width * scrollProgress,
                decoration: const BoxDecoration(
                  gradient: AppColors.buttonGradient,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Complete button ────────────────────────────────────────────────────────────

class _CompleteLessonButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteLessonButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          'Complete lesson  ★',
          style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Image / animation block stubs (extend as needed) ─────────────────────────

class _ImageBlock extends StatelessWidget {
  final LessonBlock block;
  final bool isDark;
  const _ImageBlock({required this.block, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final assetPath = block.data['assetPath'] as String? ?? '';
    final caption = block.data['caption'] as String?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(assetPath),
        ),
        if (caption != null) ...[
          const SizedBox(height: 8),
          Text(
            caption,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimationBlock extends StatelessWidget {
  final LessonBlock block;
  const _AnimationBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with Lottie.asset(block.data['assetPath'])
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.buttonDeepVioletEnd.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: const Text('Animation placeholder'),
    );
  }
}
