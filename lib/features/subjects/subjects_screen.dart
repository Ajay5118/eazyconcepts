import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../core/models/content_models.dart';

// ─────────────────────────────────────────────────────────────────────────────
class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  int _selectedSubjectIndex = 0;

  @override
  Widget build(BuildContext context) {
    final contentLoaded = ref.watch(contentLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Subjects'),
        titleTextStyle: AppTextStyles.headline2,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: contentLoaded.when(
        data: (_) {
          final subjects = ContentRepository.instance.allSubjects;
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects available'));
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Subject tabs ──
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: subjects.length,
                  itemBuilder: (ctx, i) {
                    final selected = i == _selectedSubjectIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSubjectIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(
                            right: 10, top: 8, bottom: 8),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          gradient:
                              selected ? AppColors.buttonGradient : null,
                          color: selected
                              ? null
                              : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? Colors.transparent
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          subjects[i].name,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: selected
                                ? Colors.white
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // ── Module cards (vertical) ──
              Expanded(
                child: _ModuleVerticalList(
                  subject: subjects[_selectedSubjectIndex],
                  isDark: isDark,
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Vertical module cards
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleVerticalList extends ConsumerWidget {
  final Subject subject;
  final bool isDark;
  const _ModuleVerticalList(
      {required this.subject, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules =
        ContentRepository.instance.modulesForSubject(subject.id);
    final progress = ref.watch(progressProvider);

    if (modules.isEmpty) {
      return const Center(child: Text('No modules yet'));
    }

    // Card geometry
    const double cardH = 160.0;

    // Gradient rail lines
    const railGradient = LinearGradient(
      colors: [Color(0xFF000000), AppColors.cardGoldStart, Color(0xFF000000)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Stack(
      children: [
        // ── Vertical rail line ──
        Positioned(
          top: 0,
          bottom: 0,
          left: 30,
          child: Container(
            width: 6,
            decoration: const BoxDecoration(gradient: railGradient),
          ),
        ),

        // ── Module list ──
        ListView.builder(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
          itemCount: modules.length,
          itemBuilder: (ctx, i) {
            final module = modules[i];
            final mp = progress.moduleProgress[module.id];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 30),
              child: _ModuleCard(
                module: module,
                moduleProgress: mp,
                cardH: cardH,
                index: i,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single module card
// ─────────────────────────────────────────────────────────────────────────────
class _ModuleCard extends StatelessWidget {
  final Module module;
  final ModuleProgress? moduleProgress;
  final double cardH;
  final int index;

  const _ModuleCard({
    required this.module,
    required this.moduleProgress,
    required this.cardH,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.moduleChapters,
        arguments: {'moduleId': module.id},
      ),
      child: SizedBox(
        width: double.infinity,
        height: cardH,
        child: Card(
          clipBehavior: Clip.hardEdge,
          elevation: 8,
          shadowColor: AppColors.buttonPurpleStart.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Golden gradient base ──
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.cardGoldStart, AppColors.cardOrangeEnd],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),

              // ── module_bg decorative image (right) ──
              Positioned(
                top: 0,
                right: -20,
                bottom: 0,
                child: Image.asset(
                  'assets/img/module_bg.png',
                  opacity: const AlwaysStoppedAnimation(0.45),
                  fit: BoxFit.fitHeight,
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),

              // ── Radial lines decorative (left) ──
              Positioned(
                top: 0,
                left: -18,
                child: Image.asset(
                  'assets/img/radial-lines.png',
                  height: cardH,
                  color: Colors.white.withOpacity(0.3),
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),

              // ── Purple overlay stripe on left ──
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.buttonDeepVioletEnd.withOpacity(0.88),
                        AppColors.buttonPurpleStart.withOpacity(0.0),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // ── Music line decorative ──
              Positioned(
                right: 50,
                top: 0,
                bottom: 0,
                child: Image.asset(
                  'assets/img/music_line.png',
                  height: 0,
                  width: 150,
                  opacity: const AlwaysStoppedAnimation(0.5),
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ),

              // ── Text content ──
              Positioned(
                top: 18,
                left: 16,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MODULE ${module.order + 1}',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.cardGoldStart,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.title,
                      style: AppTextStyles.headline3.copyWith(
                        color: Colors.white,
                        fontSize: 15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.6),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // ── Chapters count badge (bottom left) ──
              Positioned(
                bottom: 12,
                left: 16,
                child: _ChaptersBadge(module: module),
              ),

              // ── Stars badge (bottom right) ──
              if (moduleProgress != null)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: _StarsBadge(
                    earned: moduleProgress!.starsEarned,
                    total: 10,
                  ),
                ),

              // ── Arrow ──
              const Positioned(
                top: 0,
                bottom: 0,
                right: 14,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChaptersBadge extends StatelessWidget {
  final Module module;
  const _ChaptersBadge({required this.module});

  @override
  Widget build(BuildContext context) {
    final chapters =
        ContentRepository.instance.chaptersForModule(module.id);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 0.5),
      ),
      child: Text(
        '${chapters.length} chapters',
        style:
            AppTextStyles.labelSmall.copyWith(color: Colors.white70, fontSize: 10),
      ),
    );
  }
}

class _StarsBadge extends StatelessWidget {
  final int earned;
  final int total;
  const _StarsBadge({required this.earned, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        total > 5 ? 5 : total,
        (i) => Icon(
          i < (earned * 5 / total).round()
              ? Icons.star_rounded
              : Icons.star_border_rounded,
          size: 12,
          color: AppColors.starGold,
        ),
      ),
    );
  }
}
