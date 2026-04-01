import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/routes.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../core/models/content_models.dart';
import '../../shared/widgets/star_row.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen>
    with SingleTickerProviderStateMixin {
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
      ),
      body: contentLoaded.when(
        data: (_) {
          final subjects = ContentRepository.instance.allSubjects;
          if (subjects.isEmpty) {
            return const Center(child: Text('No subjects available'));
          }

          return Column(
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
                      onTap: () =>
                          setState(() => _selectedSubjectIndex = i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10, top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 0),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? AppColors.buttonGradient
                              : null,
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

              // ── Module / chapter list ──
              Expanded(
                child: _ModuleList(
                  subject: subjects[_selectedSubjectIndex],
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

class _ModuleList extends ConsumerWidget {
  final Subject subject;
  const _ModuleList({required this.subject});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modules = ContentRepository.instance.modulesForSubject(subject.id);
    final progress = ref.watch(progressProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: modules.length,
      itemBuilder: (ctx, i) => _ModuleCard(
        module: modules[i],
        progress: progress,
        isDark: isDark,
        isFirst: i == 0,
      ),
    );
  }
}

class _ModuleCard extends StatefulWidget {
  final Module module;
  final UserProgress progress;
  final bool isDark;
  final bool isFirst;
  const _ModuleCard({
    required this.module,
    required this.progress,
    required this.isDark,
    required this.isFirst,
  });

  @override
  State<_ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<_ModuleCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isFirst; // expand first module by default
  }

  @override
  Widget build(BuildContext context) {
    final mp = widget.progress.moduleProgress[widget.module.id];
    final chapters =
        ContentRepository.instance.chaptersForModule(widget.module.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // ── Module header ──
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Module number badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'M${widget.module.order + 1}',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.module.title,
                          style: AppTextStyles.headline3.copyWith(
                            color: widget.isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${chapters.length} chapters',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: widget.isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Stars & expand icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      StarRow(
                        earned: mp?.starsEarned ?? 0,
                        total: 10,
                        size: 12,
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        _expanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: widget.isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Chapters ──
          if (_expanded)
            ...chapters.map((ch) => _ChapterRow(
                  chapter: ch,
                  progress: widget.progress,
                  isDark: widget.isDark,
                )),
        ],
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final Chapter chapter;
  final UserProgress progress;
  final bool isDark;
  const _ChapterRow({
    required this.chapter,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cp = progress.chapterProgress[chapter.id];
    final isCompleted = cp?.isCompleted ?? false;
    final isInProgress =
        !isCompleted && (cp?.completedLessons ?? 0) > 0;

    Color statusColor;
    IconData statusIcon;
    if (isCompleted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_rounded;
    } else if (isInProgress) {
      statusColor = AppColors.buttonPurpleStart;
      statusIcon = Icons.play_arrow_rounded;
    } else {
      statusColor =
          isDark ? AppColors.darkBorder : AppColors.lightBorder;
      statusIcon = Icons.lock_outline_rounded;
    }

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chapter,
        arguments: {
          'moduleId': chapter.moduleId,
          'chapterId': chapter.id,
        },
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Icon(statusIcon, size: 12, color: statusColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (isInProgress)
                    Text(
                      '${cp?.completedLessons} / ${cp?.totalLessons} lessons',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.buttonPurpleStart,
                      ),
                    ),
                ],
              ),
            ),
            StarRow(
              earned: cp?.starsEarned ?? 0,
              total: 5,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
