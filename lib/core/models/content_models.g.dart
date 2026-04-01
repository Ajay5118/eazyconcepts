// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubjectAdapter extends TypeAdapter<Subject> {
  @override
  final int typeId = 0;

  @override
  Subject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subject(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconAsset: fields[3] as String,
      colorIndex: fields[4] as int,
      moduleIds: (fields[5] as List).cast<String>(),
      order: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Subject obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconAsset)
      ..writeByte(4)
      ..write(obj.colorIndex)
      ..writeByte(5)
      ..write(obj.moduleIds)
      ..writeByte(6)
      ..write(obj.order);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModuleAdapter extends TypeAdapter<Module> {
  @override
  final int typeId = 1;

  @override
  Module read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Module(
      id: fields[0] as String,
      subjectId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      chapterIds: (fields[4] as List).cast<String>(),
      order: fields[5] as int,
      starsOnCompletion: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Module obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.subjectId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.chapterIds)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.starsOnCompletion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterAdapter extends TypeAdapter<Chapter> {
  @override
  final int typeId = 2;

  @override
  Chapter read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chapter(
      id: fields[0] as String,
      moduleId: fields[1] as String,
      title: fields[2] as String,
      summary: fields[3] as String,
      lessonIds: (fields[4] as List).cast<String>(),
      order: fields[5] as int,
      starsOnCompletion: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Chapter obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.moduleId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.lessonIds)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.starsOnCompletion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonAdapter extends TypeAdapter<Lesson> {
  @override
  final int typeId = 3;

  @override
  Lesson read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Lesson(
      id: fields[0] as String,
      chapterId: fields[1] as String,
      title: fields[2] as String,
      subtitle: fields[3] as String,
      blocks: (fields[4] as List).cast<LessonBlock>(),
      order: fields[5] as int,
      estimatedMinutes: fields[6] as int,
      starsOnCompletion: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Lesson obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.chapterId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.subtitle)
      ..writeByte(4)
      ..write(obj.blocks)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.estimatedMinutes)
      ..writeByte(7)
      ..write(obj.starsOnCompletion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonBlockAdapter extends TypeAdapter<LessonBlock> {
  @override
  final int typeId = 4;

  @override
  LessonBlock read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonBlock(
      id: fields[0] as String,
      type: fields[1] as LessonBlockType,
      data: (fields[2] as Map).cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, LessonBlock obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonBlockAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserProgressAdapter extends TypeAdapter<UserProgress> {
  @override
  final int typeId = 5;

  @override
  UserProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProgress(
      userId: fields[0] as String,
      totalStars: fields[1] as int,
      totalXp: fields[2] as int,
      level: fields[3] as int,
      currentStreakDays: fields[4] as int,
      lastActiveDate: fields[5] as DateTime?,
      lessonProgress: (fields[6] as Map?)?.cast<String, LessonProgress>(),
      chapterProgress: (fields[7] as Map?)?.cast<String, ChapterProgress>(),
      moduleProgress: (fields[8] as Map?)?.cast<String, ModuleProgress>(),
      currentLessonId: fields[9] as String?,
      currentChapterId: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProgress obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.totalStars)
      ..writeByte(2)
      ..write(obj.totalXp)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.currentStreakDays)
      ..writeByte(5)
      ..write(obj.lastActiveDate)
      ..writeByte(6)
      ..write(obj.lessonProgress)
      ..writeByte(7)
      ..write(obj.chapterProgress)
      ..writeByte(8)
      ..write(obj.moduleProgress)
      ..writeByte(9)
      ..write(obj.currentLessonId)
      ..writeByte(10)
      ..write(obj.currentChapterId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LessonProgressAdapter extends TypeAdapter<LessonProgress> {
  @override
  final int typeId = 6;

  @override
  LessonProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LessonProgress(
      lessonId: fields[0] as String,
      isCompleted: fields[1] as bool,
      starsEarned: fields[2] as int,
      xpEarned: fields[3] as int,
      completedAt: fields[4] as DateTime?,
      bestAccuracyPercent: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LessonProgress obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.lessonId)
      ..writeByte(1)
      ..write(obj.isCompleted)
      ..writeByte(2)
      ..write(obj.starsEarned)
      ..writeByte(3)
      ..write(obj.xpEarned)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.bestAccuracyPercent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ChapterProgressAdapter extends TypeAdapter<ChapterProgress> {
  @override
  final int typeId = 7;

  @override
  ChapterProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChapterProgress(
      chapterId: fields[0] as String,
      completedLessons: fields[1] as int,
      totalLessons: fields[2] as int,
      isCompleted: fields[3] as bool,
      starsEarned: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ChapterProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.completedLessons)
      ..writeByte(2)
      ..write(obj.totalLessons)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.starsEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChapterProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ModuleProgressAdapter extends TypeAdapter<ModuleProgress> {
  @override
  final int typeId = 8;

  @override
  ModuleProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ModuleProgress(
      moduleId: fields[0] as String,
      completedChapters: fields[1] as int,
      totalChapters: fields[2] as int,
      isCompleted: fields[3] as bool,
      starsEarned: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ModuleProgress obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.moduleId)
      ..writeByte(1)
      ..write(obj.completedChapters)
      ..writeByte(2)
      ..write(obj.totalChapters)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.starsEarned);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModuleProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 9;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      isDarkMode: fields[0] as bool,
      notificationsEnabled: fields[1] as bool,
      languageCode: fields[2] as String,
      soundEnabled: fields[3] as bool,
      hapticEnabled: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.notificationsEnabled)
      ..writeByte(2)
      ..write(obj.languageCode)
      ..writeByte(3)
      ..write(obj.soundEnabled)
      ..writeByte(4)
      ..write(obj.hapticEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
