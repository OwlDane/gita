import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 2)
enum HabitStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  completed,
  @HiveField(2)
  skipped,
}

@HiveType(typeId: 3)
class Habit extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int hour;

  @HiveField(3)
  final int minute;

  @HiveField(4)
  final String iconPath;

  @HiveField(5)
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday

  @HiveField(6)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.hour,
    required this.minute,
    required this.iconPath,
    required this.daysOfWeek,
    required this.createdAt,
  });
}

@HiveType(typeId: 4)
class HabitLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String habitId;

  @HiveField(2)
  final DateTime date; // Normalized to date only

  @HiveField(3)
  final HabitStatus status;

  @HiveField(4)
  final DateTime loggedAt;

  HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.status,
    required this.loggedAt,
  });
}
