import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
enum MoodType {
  @HiveField(0)
  sedih,
  @HiveField(1)
  biasaAja,
  @HiveField(2)
  senang,
  @HiveField(3)
  sangatSenang,
}

@HiveType(typeId: 1)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final MoodType mood;

  @HiveField(3)
  final int intensity;

  @HiveField(4)
  final String journal;

  @HiveField(5)
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.date,
    required this.mood,
    required this.intensity,
    required this.journal,
    required this.createdAt,
  });

  factory MoodEntry.create({
    required MoodType mood,
    required int intensity,
    required String journal,
    DateTime? date,
  }) {
    final now = DateTime.now();
    return MoodEntry(
      id: const Uuid().v4(),
      date: date ?? DateTime(now.year, now.month, now.day),
      mood: mood,
      intensity: intensity,
      journal: journal,
      createdAt: now,
    );
  }
}
