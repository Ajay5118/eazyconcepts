import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/content_models.dart';
import '../local/hive_service.dart';
import '../local/content_repository.dart';

// ─── Content providers ────────────────────────────────────────────────────────

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository.instance;
});

final contentLoadedProvider = FutureProvider<bool>((ref) async {
  await ContentRepository.instance.loadAll();
  return true;
});

final allSubjectsProvider = Provider<List<Subject>>((ref) {
  ref.watch(contentLoadedProvider);
  return ContentRepository.instance.allSubjects;
});

final modulesProvider = Provider.family<List<Module>, String>((ref, subjectId) {
  return ContentRepository.instance.modulesForSubject(subjectId);
});

final chaptersProvider = Provider.family<List<Chapter>, String>((ref, moduleId) {
  return ContentRepository.instance.chaptersForModule(moduleId);
});

final lessonsProvider = Provider.family<List<Lesson>, String>((ref, chapterId) {
  return ContentRepository.instance.lessonsForChapter(chapterId);
});

final lessonByIdProvider = Provider.family<Lesson?, String>((ref, id) {
  return ContentRepository.instance.lessonById(id);
});

// ─── Progress providers ───────────────────────────────────────────────────────

class ProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() => HiveService.getOrCreateProgress();

  Future<CompletionResult> completeLesson({
    required String lessonId,
    required String chapterId,
    required String moduleId,
    required int totalLessonsInChapter,
    required int totalChaptersInModule,
    required int accuracyPercent,
  }) async {
    final before = state;

    await HiveService.completeLesson(
      lessonId: lessonId,
      chapterId: chapterId,
      moduleId: moduleId,
      totalLessonsInChapter: totalLessonsInChapter,
      totalChaptersInModule: totalChaptersInModule,
      accuracyPercent: accuracyPercent,
    );
    
    // Automatically point the "Continue" card to the NEXT lesson
    final nextLesson = ContentRepository.instance.nextLesson(lessonId);
    if (nextLesson != null) {
      final prog = HiveService.getOrCreateProgress();
      prog.currentLessonId = nextLesson.id;
      await HiveService.saveProgress(prog);
    }

    final after = HiveService.getOrCreateProgress();
    state = after;

    // Determine what was newly earned for the completion screen
    final starsEarned = after.totalStars - before.totalStars;
    final xpEarned = after.totalXp - before.totalXp;
    final chapterCompleted = !(before.chapterProgress[chapterId]?.isCompleted ?? false) &&
        (after.chapterProgress[chapterId]?.isCompleted ?? false);
    final moduleCompleted = !(before.moduleProgress[moduleId]?.isCompleted ?? false) &&
        (after.moduleProgress[moduleId]?.isCompleted ?? false);
    final leveledUp = after.level > before.level;

    return CompletionResult(
      starsEarned: starsEarned,
      xpEarned: xpEarned,
      chapterCompleted: chapterCompleted,
      moduleCompleted: moduleCompleted,
      leveledUp: leveledUp,
      newLevel: after.level,
      accuracyPercent: accuracyPercent,
    );
  }

  ContentStatus lessonStatus(String lessonId) {
    final lp = state.lessonProgress[lessonId];
    if (lp?.isCompleted == true) return ContentStatus.completed;
    return ContentStatus.available;
  }

  ContentStatus chapterStatus(String chapterId, List<String> lessonIds) {
    final cp = state.chapterProgress[chapterId];
    if (cp?.isCompleted == true) return ContentStatus.completed;
    final anyDone = lessonIds.any(
      (id) => state.lessonProgress[id]?.isCompleted == true,
    );
    if (anyDone) return ContentStatus.inProgress;
    // Chapter is available if it's the first or the previous is completed
    return ContentStatus.available;
  }

  Future<void> setCurrentLesson(String lessonId) async {
    final prog = state;
    if (prog.currentLessonId != lessonId) {
      prog.currentLessonId = lessonId;
      await HiveService.saveProgress(prog);
      state = HiveService.getOrCreateProgress();
    }
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);

// ─── Settings provider ────────────────────────────────────────────────────────

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => HiveService.getOrCreateSettings();

  Future<void> toggleDarkMode(bool value) async {
    await HiveService.toggleDarkMode(value);
    state = state..isDarkMode = value;
  }

  Future<void> toggleNotifications(bool value) async {
    state.notificationsEnabled = value;
    await HiveService.saveSettings(state);
  }

  Future<void> toggleSound(bool value) async {
    state.soundEnabled = value;
    await HiveService.saveSettings(state);
  }

  Future<void> toggleHaptic(bool value) async {
    state.hapticEnabled = value;
    await HiveService.saveSettings(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ─── Active lesson state ──────────────────────────────────────────────────────

class LessonSessionNotifier extends Notifier<LessonSession?> {
  @override
  LessonSession? build() => null;

  void startLesson(Lesson lesson) {
    state = LessonSession(lesson: lesson);
  }

  void answerQuiz(String blockId, String answer) {
    if (state == null) return;
    state = state!.copyWithAnswer(blockId, answer);
  }

  void endLesson() => state = null;
}

final lessonSessionProvider =
    NotifierProvider<LessonSessionNotifier, LessonSession?>(
  LessonSessionNotifier.new,
);

// ─── Supporting classes ───────────────────────────────────────────────────────

class LessonSession {
  final Lesson lesson;
  final Map<String, String> answers; // blockId → user answer
  final DateTime startTime;

  LessonSession({
    required this.lesson,
    Map<String, String>? answers,
    DateTime? startTime,
  })  : answers = answers ?? {},
        startTime = startTime ?? DateTime.now();

  LessonSession copyWithAnswer(String blockId, String answer) => LessonSession(
        lesson: lesson,
        answers: {...answers, blockId: answer},
        startTime: startTime,
      );

  int get accuracyPercent {
    final quizBlocks = lesson.blocks
        .where((b) => b.type == LessonBlockType.quiz)
        .toList();
    if (quizBlocks.isEmpty) return 100;
    int correct = 0;
    for (final b in quizBlocks) {
      final userAns = answers[b.id]?.trim().toLowerCase();
      final correctAns = (b.data['answer'] as String).trim().toLowerCase();
      if (userAns == correctAns) correct++;
    }
    return ((correct / quizBlocks.length) * 100).round();
  }

  Duration get elapsed => DateTime.now().difference(startTime);
}

class CompletionResult {
  final int starsEarned;
  final int xpEarned;
  final bool chapterCompleted;
  final bool moduleCompleted;
  final bool leveledUp;
  final int newLevel;
  final int accuracyPercent;

  const CompletionResult({
    required this.starsEarned,
    required this.xpEarned,
    required this.chapterCompleted,
    required this.moduleCompleted,
    required this.leveledUp,
    required this.newLevel,
    required this.accuracyPercent,
  });
}
