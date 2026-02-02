import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 3)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? imagePath;

  UserProfile({
    required this.name,
    this.imagePath,
  });

  UserProfile copyWith({
    String? name,
    String? imagePath,
  }) {
    return UserProfile(
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
