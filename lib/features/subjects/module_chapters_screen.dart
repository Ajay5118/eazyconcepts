import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../core/models/content_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Module Chapters Screen
// Full golden-gradient background, horizontal chapter path with
// chapter_bg / chapter_bg_selected / chapter_lock PNG nodes
// ─────────────────────────────────────────────────────────────────────────────
class ModuleChaptersScreen extends ConsumerWidget {
  final String moduleId;
  const ModuleChaptersScreen({super.key, required this.moduleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ContentRepository.instance.moduleById(moduleId);
    final chapters = ContentRepository.instance.chaptersForModule(moduleId);
    final progress = ref.watch(progressProvider);

    if (module == null) {
      return const Scaffold(
          body: Center(child: Text('Module not found')));
    }

    // Determine chapter statuses
    // completed → all lessons done
    // current   → first not-yet-completed (or in-progress)
    // locked    → after current
    String _chapterStatus(int idx) {
      final ch = chapters[idx];
      final cp = progress.chapterProgress[ch.id];
      if (cp?.isCompleted ?? false) return 'completed';
      // Check if previous chapter is completed
      if (idx == 0) return 'current';
      final prevCp =
          progress.chapterProgress[chapters[idx - 1].id];
      if (prevCp?.isCompleted ?? false) return 'current';
      return 'locked';
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Full golden gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.cardGoldStart, AppColors.cardOrangeEnd],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ── module_bg decorative (right side) ──
          Positioned(
            top: 450,
            right: 50,
            bottom: 0,
            child: Image.asset(
              'assets/img/module_bg.png',
              opacity: const AlwaysStoppedAnimation(0.25),
              // fit: BoxFit.fitHeight,
              width: 350,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // ── Radial lines decorative (top-left) ──
          Positioned(
            top: 0,
            left: 30,
            child: Image.asset(
              'assets/img/radial-lines.png',
              height: 10,
              color: Colors.white.withOpacity(0.4),
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ),

          // ── Safe area content ──
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Custom AppBar ──
                _ModuleHeader(module: module),

                // ── Chapter path (vertical scroll) ──
                Expanded(
                  child: _ChapterVerticalPath(
                    chapters: chapters,
                    progress: progress,
                    statusOf: _chapterStatus,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Module header — back arrow + "Module N" + module name
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleHeader extends StatelessWidget {
  final Module module;
  const _ModuleHeader({required this.module});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.buttonDeepVioletEnd.withOpacity(0.7),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Colors.white),
            ),
          ),

          const SizedBox(width: 20),

          // Module icon circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.buttonPurpleStart.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '${module.order + 1}',
              style: AppTextStyles.headline3
                  .copyWith(color: Colors.white, fontSize: 18),
            ),
          ),

          const SizedBox(width: 18),

          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MODULE ${module.order + 1}',
                  style: AppTextStyles.overline.copyWith(
                    color: AppColors.buttonPurpleStart,
                    letterSpacing: 1.6,
                    fontSize: 10,
                  ),
                ),
                Text(
                  module.title,
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.darkTextPrimary,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical chapter path
// ─────────────────────────────────────────────────────────────────────────────
class _ChapterVerticalPath extends StatelessWidget {
  final List<Chapter> chapters;
  final UserProgress progress;
  final String Function(int) statusOf;

  const _ChapterVerticalPath({
    required this.chapters,
    required this.progress,
    required this.statusOf,
  });

  @override
  Widget build(BuildContext context) {
    const double nodeSize = 120.0; // size of the chapter_bg node PNG
    const double itemH = nodeSize + 40; // total height per item

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 40),
      itemCount: chapters.length,
      itemBuilder: (ctx, i) {
        final chapter = chapters[i];
        final status = statusOf(i);
        final cp = progress.chapterProgress[chapter.id];
        final isLast = i == chapters.length - 1;

        return SizedBox(
          height: itemH,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // ── Vertical connecting divider to next ──
              if (!isLast)
                Positioned(
                  top: nodeSize / 2 + 40,
                  bottom: -40,
                  child: _ChapterDivider(status: status),
                ),

              // ── Stars above (completed / current with rating) ──
              // left:0 + right:0 are required so the child gets bounded width
              if (status != 'locked' && (cp?.starsEarned ?? 0) > 0)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _StarsRow(
                    stars: cp?.starsEarned ?? 0,
                    maxStars: 5,
                  ),
                ),

              // ── Chapter node — centered horizontally ──
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: _ChapterNode(
                    chapter: chapter,
                    status: status,
                    nodeSize: nodeSize,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// The chapter node — uses chapter_bg PNGs as DecorationImage
// ─────────────────────────────────────────────────────────────────────────────
class _ChapterNode extends StatelessWidget {
  final Chapter chapter;
  final String status; // 'current', 'completed', 'locked'
  final double nodeSize;

  const _ChapterNode({
    required this.chapter,
    required this.status,
    required this.nodeSize,
  });

  String get _bgAsset {
    switch (status) {
      case 'completed':
        return 'assets/img/chapter_bg_selected.png';
      case 'locked':
        return 'assets/img/chapter_lock.png';
      default:
        return 'assets/img/chapter_bg.png';
    }
  }

  double get _opacity {
    switch (status) {
      case 'completed':
        return 0.92;
      case 'locked':
        return 0.65;
      default:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: status == 'locked'
          ? () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Complete the previous chapter to unlock.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.buttonDeepVioletEnd,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 2),
                ),
              )
          : () => Navigator.pushNamed(
                context,
                AppRoutes.chapter,
                arguments: {
                  'moduleId': chapter.moduleId,
                  'chapterId': chapter.id,
                },
              ),
      child: Opacity(
        opacity: _opacity,
        child: SizedBox(
          width: nodeSize,
          height: nodeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── PNG background (diamond/badge shape) ──
              Image.asset(
                _bgAsset,
                width: nodeSize,
                height: nodeSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                    _FallbackNodeBg(status: status, size: nodeSize),
              ),

              // ── Chapter name centered on image ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: nodeSize * 0.18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status == 'locked') ...[
                      const Icon(Icons.lock_rounded,
                          size: 22, color: Colors.white54),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      chapter.title,
                      style: AppTextStyles.headline3.copyWith(
                        color: status == 'locked'
                            ? Colors.black
                            : AppColors.buttonDeepVioletEnd,
                        fontSize: 10,
                        fontFamily: 'CinzelDecorative',
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (status == 'completed') ...[
                      // const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Connecting horizontal divider between chapters (like reference ChapterPage)
// ─────────────────────────────────────────────────────────────────────────────
class _ChapterDivider extends StatelessWidget {
  final String status;
  const _ChapterDivider({required this.status});

  List<Color> get _colors {
    switch (status) {
      case 'completed':
        return [Colors.white, Colors.white.withOpacity(0.4)];
      case 'locked':
        return [Colors.grey.shade400, Colors.grey.shade600];
      default: // current
        return [
          AppColors.buttonDeepVioletEnd,
          AppColors.buttonPurpleStart,
          Colors.grey.shade400,
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Three-star row above completed chapters
// ─────────────────────────────────────────────────────────────────────────────
class _StarsRow extends StatelessWidget {
  final int stars;
  final int maxStars;
  const _StarsRow({required this.stars, required this.maxStars});

  @override
  Widget build(BuildContext context) {
    // Show 3 positioned stars like the reference (left, center bigger, right)
    const double bigSize = 36;
    const double smallSize = 26;
    return SizedBox(
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Transparent anchor so Stack has a non-positioned child to size from
          const SizedBox.expand(),

          // Left star
          if (stars >= 1)
            Positioned(
              left: 160,
              top: 12,
              child: Image.asset(
                'assets/img/star_1.png',
                width: smallSize,
                height: smallSize,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.star_rounded,
                  size: smallSize,
                  color: AppColors.starGold,
                ),
              ),
            ),
          // Center star (bigger)
          if (stars >= 2)
            Positioned(
              top: 2,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/img/star_2.png',
                  width: bigSize,
                  height: bigSize,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.star_rounded,
                    size: bigSize,
                    color: AppColors.starGold,
                  ),
                ),
              ),
            ),
          // Right star
          if (stars >= 3)
            Positioned(
              right: 160,
              top: 12,
              child: Image.asset(
                'assets/img/star_3.png',
                width: smallSize,
                height: smallSize,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.star_rounded,
                  size: smallSize,
                  color: AppColors.starGold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Fallback when PNG fails to load
// ─────────────────────────────────────────────────────────────────────────────
class _FallbackNodeBg extends StatelessWidget {
  final String status;
  final double size;
  const _FallbackNodeBg({required this.status, required this.size});

  @override
  Widget build(BuildContext context) {
    final colors = status == 'locked'
        ? [const Color(0xFF555555), const Color(0xFF333333)]
        : status == 'completed'
            ? [AppColors.success, const Color(0xFF0F6E56)]
            : [AppColors.cardGoldStart, AppColors.cardOrangeEnd];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient:
            LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(size * 0.12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
    );
  }
}
