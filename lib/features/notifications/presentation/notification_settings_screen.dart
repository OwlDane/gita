import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gita/core/theme/app_colors.dart';
import 'package:gita/features/notifications/presentation/notification_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        centerTitle: false,
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _PermissionStatusCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Pengingat Harian'),
            const SizedBox(height: 16),
            _buildDailyReminderCard(context, ref, settings),
            const SizedBox(height: 32),
            _buildSectionTitle('Pengingat Kebiasaan'),
            const SizedBox(height: 16),
            _buildHabitReminderCard(ref, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildDailyReminderCard(
    BuildContext context,
    WidgetRef ref,
    settings,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.textMain.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengingat Journaling',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ngingetin kamu buat cerita setiap hari',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: settings.dailyReminderEnabled,
                onChanged: (value) {
                  ref
                      .read(notificationSettingsProvider.notifier)
                      .toggleDailyReminder(value);
                },
                activeColor: AppColors.primary,
              ),
            ],
          ),
          if (settings.dailyReminderEnabled) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Waktu Pengingat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => _selectTime(context, ref, settings),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${settings.reminderHour.toString().padLeft(2, '0')}:${settings.reminderMinute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitReminderCard(WidgetRef ref, settings) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.textMain.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengingat Kebiasaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Notifikasi otomatis sesuai jadwal habit',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: settings.habitRemindersEnabled,
            onChanged: (value) {
              ref
                  .read(notificationSettingsProvider.notifier)
                  .toggleHabitReminders(value);
            },
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    WidgetRef ref,
    settings,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(notificationSettingsProvider.notifier)
          .updateReminderTime(picked.hour, picked.minute);
    }
  }
}

class _PermissionStatusCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PermissionStatusCard> createState() =>
      _PermissionStatusCardState();
}

class _PermissionStatusCardState extends ConsumerState<_PermissionStatusCard> {
  bool _isGranted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    if (Platform.isLinux) {
      setState(() {
        _isGranted = true;
        _isLoading = false;
      });
      return;
    }
    
    final status = await Permission.notification.status;
    setState(() {
      _isGranted = status.isGranted;
      _isLoading = false;
    });
  }

  Future<void> _requestPermission() async {
    if (Platform.isLinux) return;
    
    final status = await Permission.notification.request();
    setState(() {
      _isGranted = status.isGranted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    if (_isGranted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.moodSenang.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.moodSenang.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.moodSenang),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Izin notifikasi sudah aktif ✓',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.moodSenang,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.moodMarah.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.moodMarah.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications_off, color: AppColors.moodMarah),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Izin notifikasi belum diaktifkan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.moodMarah,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _requestPermission,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.moodMarah,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aktifkan Izin Notifikasi'),
            ),
          ),
        ],
      ),
    );
  }
}
