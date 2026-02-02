import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gita/features/profile/data/user_profile.dart';

class ProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    // Ensure box is open (openBox is idempotent)
    final box = await Hive.openBox<UserProfile>('user_profile');
    return box.get('current') ?? UserProfile(name: 'User');
  }

  Future<void> updateProfile({String? name, String? imagePath}) async {
    final currentProfile = state.value ?? UserProfile(name: 'User');
    final updated = currentProfile.copyWith(
      name: name,
      imagePath: imagePath,
    );
    
    state = AsyncData(updated);
    
    final box = Hive.box<UserProfile>('user_profile');
    await box.put('current', updated);
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, UserProfile>(() {
  return ProfileNotifier();
});
