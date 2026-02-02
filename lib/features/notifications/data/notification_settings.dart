import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 7)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool dailyReminderEnabled;

  @HiveField(1)
  int reminderHour;

  @HiveField(2)
  int reminderMinute;

  @HiveField(3)
  bool habitRemindersEnabled;

  NotificationSettings({
    this.dailyReminderEnabled = true,
    this.reminderHour = 20, // 8 PM
    this.reminderMinute = 0,
    this.habitRemindersEnabled = true,
  });

  NotificationSettings copyWith({
    bool? dailyReminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    bool? habitRemindersEnabled,
  }) {
    return NotificationSettings(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      habitRemindersEnabled: habitRemindersEnabled ?? this.habitRemindersEnabled,
    );
  }
}
