import 'user_profile.dart';
import 'friend.dart';

class AppUser {
  String email;
  String password;
  final UserProfile profile;
  String? coverPhotoPath;

  AppUser({
    required this.email,
    required this.password,
    required this.profile,
    this.coverPhotoPath,
  });
}

/// Simple in-memory auth service (no backend).
class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._() {
    // Pre-register Romeo's account
    _users.add(AppUser(
      email: 'romeopogi@email.com',
      password: 'missyousobra',
      coverPhotoPath: 'lib/assets/capy_cover.jpg',
      profile: UserProfile(
        name: 'Romeo Albeza Jr.',
        username: '@Romeo',
        bio: '2nd Year BSIT Student. Passionate Developer.',
        email: 'romeopogi@email.com',
        phone: '+63 987 000 6767',
        hobby: 'Coding, Gaming, Traveling, Workout',
        skills: 'Flutter, Dart, HTML, CSS, JavaScript, Bootstrap, Vue.js, React, Python, Java, C#, C++, MySQL',
        aboutMe: "I'm a BSIT student who loves building mobile and web applications. I enjoy learning new technologies and solving complex problems through code.",
        interests: 'Mobile Development, Web Development, UI/UX Design',
        profileImagePath: 'lib/assets/romeoprofile.jpg',
        friends: [
          Friend(name: 'Nairb Varona', username: '@Nairb', contact: 'nairb@email.com'),
          Friend(name: 'Raniel Dela Cruz', username: '@Raniel', contact: 'raniel@email.com'),
          Friend(name: 'Sofia Padua', username: '@Sofia', contact: 'sofia@email.com'),
          Friend(name: 'Anthony Duenas', username: '@Anthony', contact: 'anthony@email.com'),
          Friend(name: 'Marcus Montero', username: '@Marcus', contact: 'marcus@email.com'),
          Friend(name: 'Cj Garcia', username: '@Cj', contact: 'cj@email.com'),
          Friend(name: 'Carlo Baracena', username: '@Carlo', contact: 'carlo@email.com'),
          Friend(name: 'Beejay Carpio', username: '@Beejay', contact: 'beejay@email.com'),
          Friend(name: 'Lance Art Fortaleza', username: '@Lance', contact: 'lance@email.com'),
          Friend(name: 'Jc Guzman', username: '@Jc', contact: 'jc@email.com'),
          Friend(name: 'Jv Mirador', username: '@Jv', contact: 'jv@email.com'),
          Friend(name: 'Gian Boaquina', username: '@Gian', contact: 'gian@email.com'),
          Friend(name: 'Gregemn Sagabaen', username: '@Gregemn', contact: 'gregemn@email.com'),
          Friend(name: 'Ashton Garcia', username: '@Ashton', contact: 'ashton@email.com'),
          Friend(name: 'Kyle Colambo', username: '@Kyle', contact: 'kyle@email.com'),
        ],
      ),
    ));
  }

  final List<AppUser> _users = [];
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Sign in. Returns null on success, or error message.
  String? signIn(String email, String password) {
    final trimEmail = email.trim().toLowerCase();
    final trimPass = password.trim();
    if (trimEmail.isEmpty || trimPass.isEmpty) {
      return 'Please fill in all fields.';
    }
    try {
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == trimEmail && u.password == trimPass,
      );
      _currentUser = user;
      return null;
    } catch (_) {
      return 'Invalid email or password.';
    }
  }

  /// Sign up. Returns null on success, or error message.
  String? signUp(String email, String password, String name) {
    final trimEmail = email.trim().toLowerCase();
    final trimPass = password.trim();
    final trimName = name.trim();
    if (trimEmail.isEmpty || trimPass.isEmpty || trimName.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!trimEmail.contains('@') || !trimEmail.contains('.')) {
      return 'Please enter a valid email.';
    }
    if (trimPass.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    final exists = _users.any((u) => u.email.toLowerCase() == trimEmail);
    if (exists) {
      return 'An account with this email already exists.';
    }
    final newUser = AppUser(
      email: trimEmail,
      password: trimPass,
      profile: UserProfile(
        name: trimName,
        username: '@${trimName.split(' ').first}',
        email: trimEmail,
      ),
    );
    _users.add(newUser);
    _currentUser = newUser;
    return null;
  }

  /// Update the current user's email or password.
  String? updateCredentials({String? newEmail, String? newPassword}) {
    if (_currentUser == null) return 'Not logged in.';
    if (newEmail != null && newEmail.trim().isNotEmpty) {
      final trimEmail = newEmail.trim().toLowerCase();
      if (!trimEmail.contains('@') || !trimEmail.contains('.')) {
        return 'Please enter a valid email.';
      }
      final exists = _users.any(
          (u) => u != _currentUser && u.email.toLowerCase() == trimEmail);
      if (exists) return 'Email already in use.';
      _currentUser!.email = trimEmail;
      _currentUser!.profile.email = trimEmail;
    }
    if (newPassword != null && newPassword.trim().isNotEmpty) {
      if (newPassword.trim().length < 8) {
        return 'Password must be at least 8 characters.';
      }
      _currentUser!.password = newPassword.trim();
    }
    return null;
  }

  void signOut() {
    _currentUser = null;
  }
}
