import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/models/content_models.dart';

/// Loads all lesson content from bundled JSON assets.
/// In Phase 2, this will be swapped for a network call with Hive cache.
class ContentRepository {
  ContentRepository._();
  static final ContentRepository instance = ContentRepository._();

  // In-memory cache after first load
  final Map<String, Subject> _subjects = {};
  final Map<String, Module> _modules = {};
  final Map<String, Chapter> _chapters = {};
  final Map<String, Lesson> _lessons = {};

  bool _loaded = false;

  Future<void> loadAll() async {
    if (_loaded) return;

    // Load manifest (lists all content files)
    final manifestJson = await rootBundle.loadString(
      'assets/content/manifest.json',
    );
    final manifest = jsonDecode(manifestJson) as Map<String, dynamic>;

    for (final subjectFile in manifest['subjects'] as List) {
      try {
        final raw = await rootBundle.loadString(
          'assets/content/$subjectFile',
        );
        _parseSubjectFile(jsonDecode(raw) as Map<String, dynamic>);
      } catch (e, st) {
        debugPrint('⚠️ Failed to load $subjectFile: $e\n$st');
      }
    }

    _loaded = true;
  }

  void _parseSubjectFile(Map<String, dynamic> json) {
    final subject = _subjectFromJson(json);
    _subjects[subject.id] = subject;

    for (final mJson in json['modules'] as List) {
      final module = _moduleFromJson(mJson as Map<String, dynamic>, subject.id);
      _modules[module.id] = module;

      for (final cJson in mJson['chapters'] as List) {
        final chapter = _chapterFromJson(cJson as Map<String, dynamic>, module.id);
        _chapters[chapter.id] = chapter;

        for (final lJson in cJson['lessons'] as List) {
          final lesson = _lessonFromJson(lJson as Map<String, dynamic>, chapter.id);
          _lessons[lesson.id] = lesson;
        }
      }
    }
  }

  // ─── Getters ──────────────────────────────────────────────

  List<Subject> get allSubjects {
    final list = _subjects.values.toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<Module> modulesForSubject(String subjectId) {
    final list = _modules.values
        .where((m) => m.subjectId == subjectId)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<Chapter> chaptersForModule(String moduleId) {
    final list = _chapters.values
        .where((c) => c.moduleId == moduleId)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<Lesson> lessonsForChapter(String chapterId) {
    final list = _lessons.values
        .where((l) => l.chapterId == chapterId)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  Subject? subjectById(String id) => _subjects[id];
  Module? moduleById(String id) => _modules[id];
  Chapter? chapterById(String id) => _chapters[id];
  Lesson? lessonById(String id) => _lessons[id];

  Lesson? nextLesson(String currentLessonId) {
    final current = _lessons[currentLessonId];
    if (current == null) return null;
    final siblings = lessonsForChapter(current.chapterId);
    final idx = siblings.indexWhere((l) => l.id == currentLessonId);
    if (idx >= 0 && idx < siblings.length - 1) return siblings[idx + 1];
    return null;
  }

  // ─── JSON parsers ─────────────────────────────────────────

  Subject _subjectFromJson(Map<String, dynamic> j) => Subject(
        id: j['id'] as String,
        name: j['name'] as String,
        description: j['description'] as String,
        iconAsset: j['icon_asset'] as String,
        colorIndex: j['color_index'] as int,
        moduleIds: List<String>.from(j['module_ids'] as List),
        order: j['order'] as int,
      );

  Module _moduleFromJson(Map<String, dynamic> j, String subjectId) => Module(
        id: j['id'] as String,
        subjectId: subjectId,
        title: j['title'] as String,
        description: j['description'] as String,
        chapterIds: List<String>.from(j['chapter_ids'] as List),
        order: j['order'] as int,
      );

  Chapter _chapterFromJson(Map<String, dynamic> j, String moduleId) => Chapter(
        id: j['id'] as String,
        moduleId: moduleId,
        title: j['title'] as String,
        summary: j['summary'] as String,
        lessonIds: List<String>.from(j['lesson_ids'] as List),
        order: j['order'] as int,
      );

  Lesson _lessonFromJson(Map<String, dynamic> j, String chapterId) => Lesson(
        id: j['id'] as String,
        chapterId: chapterId,
        title: j['title'] as String,
        subtitle: j['subtitle'] as String,
        blocks: (j['blocks'] as List)
            .map((b) => _blockFromJson(b as Map<String, dynamic>))
            .toList(),
        order: j['order'] as int,
        estimatedMinutes: j['estimated_minutes'] as int? ?? 5,
      );

  LessonBlock _blockFromJson(Map<String, dynamic> j) {
    final typeName = j['type'] as String;
    final type = LessonBlockType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () {
        debugPrint('⚠️ Unknown block type "$typeName" – treating as interactive');
        return LessonBlockType.interactive;
      },
    );
    return LessonBlock(
      id: j['id'] as String,
      type: type,
      data: Map<String, dynamic>.from(j['data'] as Map),
    );
  }
}
