class Friend {
  String name;
  String username;
  String contact;
  String bio;
  String skills;
  String? profileImagePath;

  Friend({
    required this.name,
    this.username = '',
    required this.contact,
    this.bio = '',
    this.skills = '',
    this.profileImagePath,
  });
}