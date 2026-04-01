// ─────────────────────────────────────────────────────────────────────────────
// EazyConcepts — Core Data Models
// Designed to be UUID-based and Django/PostgreSQL-compatible for Phase 2 sync.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:hive/hive.dart';

part 'content_models.g.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

enum SubjectType { math, physics }

enum LessonBlockType {
  text,          // Rich text / markdown paragraph
  equation,      // LaTeX equation via flutter_math_fork
  conceptReveal, // Step-by-step animated reveal
  interactive,   // CustomPainter widget (graph, simulation, geometry)
  fillInBlank,   // Inline fill-in-the-blank inside text
  quiz,          // MCQ / true-false / equation input
  image,         // Static illustration or diagram
  animation,     // Lottie/Rive animation asset
}

enum QuizType { mcq, fillBlank, trueFalse, equationInput }

enum ContentStatus { locked, available, inProgress, completed }

// ─── Subject ──────────────────────────────────────────────────────────────────

@HiveType(typeId: 0)
class Subject extends HiveObject {
  @HiveField(0) final String id;           // UUID
  @HiveField(1) final String name;
  @HiveField(2) final String description;
  @HiveField(3) final String iconAsset;
  @HiveField(4) final int colorIndex;      // maps to gradient in AppColors
  @HiveField(5) final List<String> moduleIds;
  @HiveField(6) final int order;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.iconAsset,
    required this.colorIndex,
    required this.moduleIds,
    required this.order,
  });
}

// ─── Module ───────────────────────────────────────────────────────────────────

@HiveType(typeId: 1)
class Module extends HiveObject {
  @HiveField(0) final String id;           // UUID
  @HiveField(1) final String subjectId;
  @HiveField(2) final String title;
  @HiveField(3) final String description;
  @HiveField(4) final List<String> chapterIds;
  @HiveField(5) final int order;
  @HiveField(6) final int starsOnCompletion; // always 10

  Module({
    required this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.chapterIds,
    required this.order,
    this.starsOnCompletion = 10,
  });
}

// ─── Chapter ──────────────────────────────────────────────────────────────────

@HiveType(typeId: 2)
class Chapter extends HiveObject {
  @HiveField(0) final String id;           // UUID
  @HiveField(1) final String moduleId;
  @HiveField(2) final String title;
  @HiveField(3) final String summary;
  @HiveField(4) final List<String> lessonIds;
  @HiveField(5) final int order;
  @HiveField(6) final int starsOnCompletion; // always 5

  Chapter({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.summary,
    required this.lessonIds,
    required this.order,
    this.starsOnCompletion = 5,
  });
}

// ─── Lesson ───────────────────────────────────────────────────────────────────

@HiveType(typeId: 3)
class Lesson extends HiveObject {
  @HiveField(0) final String id;           // UUID
  @HiveField(1) final String chapterId;
  @HiveField(2) final String title;
  @HiveField(3) final String subtitle;
  @HiveField(4) final List<LessonBlock> blocks; // ordered content blocks
  @HiveField(5) final int order;
  @HiveField(6) final int estimatedMinutes;
  @HiveField(7) final int starsOnCompletion; // always 1

  Lesson({
    required this.id,
    required this.chapterId,
    required this.title,
    required this.subtitle,
    required this.blocks,
    required this.order,
    required this.estimatedMinutes,
    this.starsOnCompletion = 1,
  });
}

// ─── Lesson Block (polymorphic content unit) ──────────────────────────────────

@HiveType(typeId: 4)
class LessonBlock extends HiveObject {
  @HiveField(0) final String id;
  @HiveField(1) final LessonBlockType type;
  @HiveField(2) final Map<String, dynamic> data;
  // data keys vary by type:
  // text          → { 'markdown': String }
  // equation      → { 'latex': String, 'label': String? }
  // conceptReveal → { 'steps': List<{'title':..,'body':..}> }
  // interactive   → { 'widgetKey': String, 'config': Map }
  // fillInBlank   → { 'template': String, 'blanks': List<String>, 'hint': String? }
  // quiz          → { 'quizType': String, 'question': String,
  //                   'options': List<String>?, 'answer': String,
  //                   'hint': String?, 'explanation': String? }
  // image         → { 'assetPath': String, 'caption': String? }
  // animation     → { 'assetPath': String, 'loop': bool }

  LessonBlock({
    required this.id,
    required this.type,
    required this.data,
  });
}

// ─── User Progress ────────────────────────────────────────────────────────────

@HiveType(typeId: 5)
class UserProgress extends HiveObject {
  @HiveField(0) String userId;              // 'guest' or UUID after auth
  @HiveField(1) int totalStars;
  @HiveField(2) int totalXp;
  @HiveField(3) int level;
  @HiveField(4) int currentStreakDays;
  @HiveField(5) DateTime? lastActiveDate;
  @HiveField(6) Map<String, LessonProgress> lessonProgress;   // lessonId → progress
  @HiveField(7) Map<String, ChapterProgress> chapterProgress; // chapterId → progress
  @HiveField(8) Map<String, ModuleProgress> moduleProgress;   // moduleId → progress
  @HiveField(9) String? currentLessonId;    // lesson user was last on
  @HiveField(10) String? currentChapterId;

  UserProgress({
    required this.userId,
    this.totalStars = 0,
    this.totalXp = 0,
    this.level = 1,
    this.currentStreakDays = 0,
    this.lastActiveDate,
    Map<String, LessonProgress>? lessonProgress,
    Map<String, ChapterProgress>? chapterProgress,
    Map<String, ModuleProgress>? moduleProgress,
    this.currentLessonId,
    this.currentChapterId,
  })  : lessonProgress = lessonProgress ?? {},
        chapterProgress = chapterProgress ?? {},
        moduleProgress = moduleProgress ?? {};

  // XP thresholds per level: level N requires N * 500 XP total
  int get xpForNextLevel => level * 500;
  double get levelProgress => totalXp / xpForNextLevel;
}

@HiveType(typeId: 6)
class LessonProgress extends HiveObject {
  @HiveField(0) final String lessonId;
  @HiveField(1) bool isCompleted;
  @HiveField(2) int starsEarned;        // 0 or 1
  @HiveField(3) int xpEarned;
  @HiveField(4) DateTime? completedAt;
  @HiveField(5) int bestAccuracyPercent; // 0–100

  LessonProgress({
    required this.lessonId,
    this.isCompleted = false,
    this.starsEarned = 0,
    this.xpEarned = 0,
    this.completedAt,
    this.bestAccuracyPercent = 0,
  });
}

@HiveType(typeId: 7)
class ChapterProgress extends HiveObject {
  @HiveField(0) final String chapterId;
  @HiveField(1) int completedLessons;
  @HiveField(2) int totalLessons;
  @HiveField(3) bool isCompleted;
  @HiveField(4) int starsEarned;        // 0 or 5

  ChapterProgress({
    required this.chapterId,
    this.completedLessons = 0,
    this.totalLessons = 0,
    this.isCompleted = false,
    this.starsEarned = 0,
  });

  double get progressPercent =>
      totalLessons == 0 ? 0 : completedLessons / totalLessons;
}

@HiveType(typeId: 8)
class ModuleProgress extends HiveObject {
  @HiveField(0) final String moduleId;
  @HiveField(1) int completedChapters;
  @HiveField(2) int totalChapters;
  @HiveField(3) bool isCompleted;
  @HiveField(4) int starsEarned;        // 0 or 10

  ModuleProgress({
    required this.moduleId,
    this.completedChapters = 0,
    this.totalChapters = 0,
    this.isCompleted = false,
    this.starsEarned = 0,
  });

  double get progressPercent =>
      totalChapters == 0 ? 0 : completedChapters / totalChapters;
}

// ─── App Settings ─────────────────────────────────────────────────────────────

@HiveType(typeId: 9)
class AppSettings extends HiveObject {
  @HiveField(0) bool isDarkMode;
  @HiveField(1) bool notificationsEnabled;
  @HiveField(2) String languageCode;
  @HiveField(3) bool soundEnabled;
  @HiveField(4) bool hapticEnabled;

  AppSettings({
    this.isDarkMode = false,
    this.notificationsEnabled = true,
    this.languageCode = 'en',
    this.soundEnabled = true,
    this.hapticEnabled = true,
  });
}
