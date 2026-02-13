import 'friend.dart';

class UserProfile {
  String name;
  String username;
  String bio;
  String email;
  String phone;
  String hobby;
  String skills;
  String aboutMe;
  String interests;
  String? profileImagePath;
  List<Friend> friends;

  UserProfile({
    this.name = '',
    this.username = '',
    this.bio = '',
    this.email = '',
    this.phone = '',
    this.hobby = '',
    this.skills = '',
    this.aboutMe = '',
    this.interests = '',
    this.profileImagePath,
    List<Friend>? friends,
  }) : friends = friends ?? [];

  UserProfile copyWith({
    String? name,
    String? username,
    String? bio,
    String? email,
    String? phone,
    String? hobby,
    String? skills,
    String? aboutMe,
    String? interests,
    String? profileImagePath,
    List<Friend>? friends,
  }) {
    return UserProfile(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hobby: hobby ?? this.hobby,
      skills: skills ?? this.skills,
      aboutMe: aboutMe ?? this.aboutMe,
      interests: interests ?? this.interests,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      friends: friends ?? this.friends,
    );
  }
}