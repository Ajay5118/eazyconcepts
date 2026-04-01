import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/local/providers.dart';
import '../../data/local/content_repository.dart';
import '../../shared/widgets/star_row.dart';
import '../../shared/widgets/xp_progress_bar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final surface =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: AppTextStyles.headline2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Avatar & name ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'EC',
                      style: AppTextStyles.headline2
                          .copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Guest User',
                    style:
                        AppTextStyles.headline3.copyWith(color: textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${progress.level} · Explorer',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── XP bar ──
            XpProgressBar(progress: progress, showLabel: true),
            const SizedBox(height: 20),

            // ── Stats grid ──
            Row(
              children: [
                _StatBox(
                  value: '${progress.totalStars}',
                  label: 'Stars',
                  icon: Icons.star_rounded,
                  color: AppColors.starGold,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  value: '${progress.lessonProgress.values.where((l) => l.isCompleted).length}',
                  label: 'Lessons',
                  icon: Icons.menu_book_rounded,
                  color: AppColors.buttonPurpleStart,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  value: '${progress.currentStreakDays}',
                  label: 'Day streak',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.cardOrangeEnd,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Subject progress ──
            Text(
              'Subject progress',
              style: AppTextStyles.labelSmall.copyWith(
                color: textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            _SubjectProgressSection(isDark: isDark),
            const SizedBox(height: 24),

            // ── Settings ──
            Text(
              'Settings',
              style: AppTextStyles.labelSmall.copyWith(
                color: textSecondary,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Column(
                children: [
                  _SettingsToggle(
                    icon: Icons.dark_mode_rounded,
                    iconBg: const Color(0xFF230A3E),
                    label: 'Dark mode',
                    value: settings.isDarkMode,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).toggleDarkMode(v),
                    isDark: isDark,
                    isLast: false,
                  ),
                  _SettingsToggle(
                    icon: Icons.notifications_outlined,
                    iconBg: AppColors.buttonPurpleStart,
                    label: 'Notifications',
                    value: settings.notificationsEnabled,
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .toggleNotifications(v),
                    isDark: isDark,
                    isLast: false,
                  ),
                  _SettingsToggle(
                    icon: Icons.volume_up_rounded,
                    iconBg: AppColors.cardOrangeEnd,
                    label: 'Sound effects',
                    value: settings.soundEnabled,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).toggleSound(v),
                    isDark: isDark,
                    isLast: false,
                  ),
                  _SettingsToggle(
                    icon: Icons.vibration_rounded,
                    iconBg: AppColors.success,
                    label: 'Haptic feedback',
                    value: settings.hapticEnabled,
                    onChanged: (v) =>
                        ref.read(settingsProvider.notifier).toggleHaptic(v),
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── About / version ──
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 0.5),
              ),
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.info_outline_rounded,
                    iconBg: AppColors.info,
                    label: 'About EazyConcepts',
                    isDark: isDark,
                    isLast: false,
                    onTap: () {},
                  ),
                  _SettingsRow(
                    icon: Icons.logout_rounded,
                    iconBg: AppColors.error,
                    label: 'Sign out',
                    isDark: isDark,
                    isLast: true,
                    onTap: () {},
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                'EazyConcepts v1.0.0 · Phase 1',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat box ──────────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
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
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTextStyles.headline3.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subject progress section ──────────────────────────────────────────────────

class _SubjectProgressSection extends ConsumerWidget {
  final bool isDark;
  const _SubjectProgressSection({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final subjects = ContentRepository.instance.allSubjects;

    return Column(
      children: subjects.map((s) {
        final gradient =
            s.colorIndex == 0 ? AppColors.mathGradient : AppColors.physicsGradient;
        final modules = ContentRepository.instance.modulesForSubject(s.id);
        int totalStars = 0;
        int maxStars = 0;
        for (final m in modules) {
          maxStars += 10;
          totalStars +=
              progress.moduleProgress[m.id]?.starsEarned ?? 0;
          for (final ch in ContentRepository.instance.chaptersForModule(m.id)) {
            maxStars += 5;
            totalStars +=
                progress.chapterProgress[ch.id]?.starsEarned ?? 0;
            maxStars += ch.lessonIds.length;
            for (final lId in ch.lessonIds) {
              totalStars +=
                  progress.lessonProgress[lId]?.starsEarned ?? 0;
            }
          }
        }
        final pct = maxStars == 0 ? 0.0 : totalStars / maxStars;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  s.colorIndex == 0 ? '∑' : '⚛',
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.name,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '$totalStars / $maxStars ⭐',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.starGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        backgroundColor: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        valueColor: AlwaysStoppedAnimation(
                          s.colorIndex == 0
                              ? AppColors.buttonPurpleStart
                              : AppColors.cardOrangeEnd,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Settings toggle row ───────────────────────────────────────────────────────

class _SettingsToggle extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final bool isLast;
  const _SettingsToggle({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
              ),
            ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.buttonPurpleStart,
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.buttonPurpleStart.withOpacity(0.3)
                    : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final bool isDark;
  final bool isLast;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SettingsRow({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.isDark,
    required this.isLast,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: isLast
            ? null
            : BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                ),
              ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDestructive
                        ? AppColors.error
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
