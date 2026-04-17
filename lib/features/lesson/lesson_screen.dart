import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _LessonScreenState extends ConsumerState<LessonScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  int _totalPages = 0; // intro + blocks + complete
  double _dragOffset = 0;

  // Animation controllers for page entrance
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lesson = ContentRepository.instance.lessonById(widget.lessonId);
      if (lesson != null) {
        setState(() {
          // Page 0 = intro, pages 1..n = blocks, page n+1 = complete
          _totalPages = lesson.blocks.length + 2;
        });
        ref.read(lessonSessionProvider.notifier).startLesson(lesson);
        ref.read(progressProvider.notifier).setCurrentLesson(lesson.id);
        _playEntrance();
      }
    });
  }

  void _playEntrance() {
    _fadeController.forward(from: 0);
    _slideController.forward(from: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page < 0 || page >= _totalPages) return;
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
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
          // ── Top bar with step indicators ──
          _LessonTopBar(
            lesson: lesson,
            currentPage: _currentPage,
            totalPages: _totalPages,
            isDark: isDark,
            onClose: () => Navigator.pop(context),
          ),

          // ── Full-screen vertical PageView ──
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
                HapticFeedback.selectionClick();
                _playEntrance();
              },
              itemBuilder: (context, index) {
                // Page 0 → intro
                if (index == 0) {
                  return _IntroPage(
                    lesson: lesson,
                    isDark: isDark,
                    fadeController: _fadeController,
                    slideController: _slideController,
                    onContinue: () => _goToPage(1),
                  );
                }

                // Last page → complete
                if (index == _totalPages - 1) {
                  return _CompletePage(
                    isDark: isDark,
                    fadeController: _fadeController,
                    onComplete: _completeLesson,
                  );
                }

                // Block pages (index 1 → block 0, etc.)
                final blockIndex = index - 1;
                final block = lesson.blocks[blockIndex];
                return _BlockPage(
                  block: block,
                  blockIndex: blockIndex,
                  totalBlocks: lesson.blocks.length,
                  isDark: isDark,
                  fadeController: _fadeController,
                  slideController: _slideController,
                  onContinue: () => _goToPage(index + 1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar with segmented step indicators ────────────────────────────────────

class _LessonTopBar extends StatelessWidget {
  final Lesson lesson;
  final int currentPage;
  final int totalPages;
  final bool isDark;
  final VoidCallback onClose;

  const _LessonTopBar({
    required this.lesson,
    required this.currentPage,
    required this.totalPages,
    required this.isDark,
    required this.onClose,
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
                  onPressed: onClose,
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
                // Step indicator text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface2
                        : AppColors.lightSurface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${currentPage + 1} / $totalPages',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Instagram-style segmented progress bars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(totalPages, (i) {
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 3,
                    margin: EdgeInsets.only(right: i < totalPages - 1 ? 3 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: i <= currentPage
                          ? AppColors.buttonGradient
                          : null,
                      color: i > currentPage
                          ? (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder)
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ── Intro page (first screen) ─────────────────────────────────────────────────

class _IntroPage extends StatelessWidget {
  final Lesson lesson;
  final bool isDark;
  final AnimationController fadeController;
  final AnimationController slideController;
  final VoidCallback onContinue;

  const _IntroPage({
    required this.lesson,
    required this.isDark,
    required this.fadeController,
    required this.slideController,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim =
        CurvedAnimation(parent: fadeController, curve: Curves.easeOut);
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Lesson icon/emoji
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: AppColors.buttonGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.buttonPurpleStart.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                lesson.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.lessonConceptTitle.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              if (lesson.subtitle.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  lesson.subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${lesson.estimatedMinutes} min  •  ${lesson.blocks.length} steps',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // "Start" button
              _PillButton(
                label: 'Start Learning',
                icon: Icons.arrow_downward_rounded,
                onTap: onContinue,
              ),

              const SizedBox(height: 20),
              // Scroll hint
              _ScrollHint(isDark: isDark),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Block page (each lesson block) ────────────────────────────────────────────

class _BlockPage extends StatelessWidget {
  final LessonBlock block;
  final int blockIndex;
  final int totalBlocks;
  final bool isDark;
  final AnimationController fadeController;
  final AnimationController slideController;
  final VoidCallback onContinue;

  const _BlockPage({
    required this.block,
    required this.blockIndex,
    required this.totalBlocks,
    required this.isDark,
    required this.fadeController,
    required this.slideController,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim =
        CurvedAnimation(parent: fadeController, curve: Curves.easeOut);
    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: slideController, curve: Curves.easeOut));

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Column(
          children: [
            // Step label
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'STEP ${blockIndex + 1}',
                      style: AppTextStyles.overline.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _blockTypeLabel(block.type),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),

            // Block content — scrollable within the page
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                physics: const BouncingScrollPhysics(),
                child: _buildBlock(block, isDark),
              ),
            ),

            // Bottom "Continue" tap area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _PillButton(
                label: blockIndex < totalBlocks - 1
                    ? 'Continue'
                    : 'Final Step →',
                icon: Icons.arrow_downward_rounded,
                onTap: onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _blockTypeLabel(LessonBlockType type) {
    switch (type) {
      case LessonBlockType.text:
        return '📖 Reading';
      case LessonBlockType.equation:
        return '🔢 Equation';
      case LessonBlockType.quiz:
        return '❓ Quiz';
      case LessonBlockType.conceptReveal:
        return '💡 Concept';
      case LessonBlockType.fillInBlank:
        return '✏️ Practice';
      case LessonBlockType.interactive:
        return '🎮 Interactive';
      case LessonBlockType.image:
        return '🖼️ Visual';
      case LessonBlockType.animation:
        return '✨ Animation';
    }
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

// ── Complete page (last screen) ───────────────────────────────────────────────

class _CompletePage extends StatelessWidget {
  final bool isDark;
  final AnimationController fadeController;
  final VoidCallback onComplete;

  const _CompletePage({
    required this.isDark,
    required this.fadeController,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final fadeAnim =
        CurvedAnimation(parent: fadeController, curve: Curves.easeOut);

    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Celebration icon
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cardGoldStart.withOpacity(0.35),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 42,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Lesson Complete!',
              style: AppTextStyles.lessonConceptTitle.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great work! You\'ve gone through\nevery step. Ready to wrap up?',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 40),
            _CompleteLessonButton(onTap: onComplete),
          ],
        ),
      ),
    );
  }
}

// ── Pill-shaped continue button ───────────────────────────────────────────────

class _PillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.buttonPurpleStart.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 8),
            AnimatedBuilder(
              animation: _bounceController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 3 * _bounceController.value),
                  child: child,
                );
              },
              child: Icon(widget.icon, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Scroll hint widget ────────────────────────────────────────────────────────

class _ScrollHint extends StatefulWidget {
  final bool isDark;
  const _ScrollHint({required this.isDark});

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.4 + 0.6 * _animController.value,
          child: Transform.translate(
            offset: Offset(0, 4 * _animController.value),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: widget.isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            size: 24,
          ),
          Text(
            'Swipe up to begin',
            style: AppTextStyles.labelSmall.copyWith(
              color: widget.isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Complete button (final page) ──────────────────────────────────────────────

class _CompleteLessonButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CompleteLessonButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardGoldStart.withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          'Complete Lesson  ★',
          style: AppTextStyles.labelLarge.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ── Image / animation block stubs ─────────────────────────────────────────────

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
