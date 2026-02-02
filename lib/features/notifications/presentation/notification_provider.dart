import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gita/features/notifications/data/notification_settings.dart';
import 'package:gita/core/services/notification_service.dart';

class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  @override
  Future<NotificationSettings> build() async {
    final box = await Hive.openBox<NotificationSettings>('notification_settings');
    return box.get('settings') ?? NotificationSettings();
  }

  Future<void> toggleDailyReminder(bool enabled) async {
    final current = state.value ?? NotificationSettings();
    final updated = current.copyWith(dailyReminderEnabled: enabled);
    
    state = AsyncData(updated);
    
    final box = Hive.box<NotificationSettings>('notification_settings');
    await box.put('settings', updated);

    final notificationService = NotificationService();
    if (enabled) {
      await notificationService.scheduleDailyJournalReminder(
        hour: updated.reminderHour,
        minute: updated.reminderMinute,
      );
    } else {
      await notificationService.cancelDailyReminder();
    }
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    final current = state.value ?? NotificationSettings();
    final updated = current.copyWith(
      reminderHour: hour,
      reminderMinute: minute,
    );
    
    state = AsyncData(updated);
    
    final box = Hive.box<NotificationSettings>('notification_settings');
    await box.put('settings', updated);

    // Reschedule if enabled
    if (updated.dailyReminderEnabled) {
      final notificationService = NotificationService();
      await notificationService.scheduleDailyJournalReminder(
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> toggleHabitReminders(bool enabled) async {
    final current = state.value ?? NotificationSettings();
    final updated = current.copyWith(habitRemindersEnabled: enabled);
    
    state = AsyncData(updated);
    
    final box = Hive.box<NotificationSettings>('notification_settings');
    await box.put('settings', updated);

    // Note: Habit reminders are scheduled/cancelled when habits are created/modified
    // This setting just controls whether to schedule them or not
  }
}

final notificationSettingsProvider = 
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(() {
  return NotificationSettingsNotifier();
});
