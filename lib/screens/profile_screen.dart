import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/glass_theme.dart';
import '../models/user_profile.dart';
import '../models/auth_service.dart';
import '../widgets/glass_card.dart';
import 'profile_editor_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  UserProfile get profile => AuthService().currentUser!.profile;
  AppUser get user => AuthService().currentUser!;

  void refresh() => setState(() {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkMissingInfo());
  }

  void _checkMissingInfo() {
    // Check if user has info (using aboutMe and skills as proxy for "Info")
    if (profile.aboutMe.isEmpty && profile.skills.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Palette.border, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Palette.border, offset: Offset(4, 4), blurRadius: 0),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Palette.secondary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: Palette.secondary, width: 2),
                  ),
                  child: Icon(Icons.person_add_rounded, size: 32, color: Palette.secondary),
                ),
                const SizedBox(height: 20),
                Text('You do not have an Info yet',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text('Would you like to set up your profile now to connect with others?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: Palette.textSecondary, fontSize: 14, height: 1.4)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: BrutalButton(
                        text: 'Later',
                        onPressed: () => Navigator.pop(ctx),
                        color: Palette.surface,
                        textColor: Palette.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BrutalButton(
                        text: 'Add Info',
                        onPressed: () {
                          Navigator.pop(ctx);
                          _navigateToEditor();
                        },
                        color: Palette.primary,
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover Photo ──
            GestureDetector(
              onTap: () => _showPhotoOptions(isCover: true),
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _getCoverImage() == null ? Colors.grey : Palette.secondary,
                  image: _getCoverImage(),
                  border: const Border(
                    bottom: BorderSide(color: Palette.border, width: 2.5),
                  ),
                ),
              ),
            ),

            // ── Avatar & Action Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Avatar (Negative margin to overlap)
                  Transform.translate(
                    offset: const Offset(0, -60),
                    child: GestureDetector(
                      onTap: () => _showPhotoOptions(isCover: false),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Palette.background,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Palette.border, width: 2.5),
                          ),
                          child: ClipOval(child: _buildAvatar(120)),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // ── Profile Info ──
            Transform.translate(
              offset: const Offset(0, -50),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Name & Handle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          profile.name.isNotEmpty ? profile.name : 'New User',
                          style: GoogleFonts.lexend(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Palette.textPrimary,
                          ),
                        ),
                      ),
                      BrutalCard(
                        onTap: _navigateToEditor,
                        padding: const EdgeInsets.all(10),
                        borderRadius: 100, // Circle
                        color: Palette.surface,
                        shadowOffset: 2,
                        child: const Icon(Icons.edit_outlined, size: 18, color: Palette.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Palette.white,
                      border: Border.all(color: Palette.border, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Palette.border, offset: Offset(2, 2)),
                      ],
                    ),
                    child: Text(
                      profile.username.isNotEmpty ? profile.username : '@user',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: Palette.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bio
                  if (profile.aboutMe.isNotEmpty) ...[
                    BrutalCard(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        profile.aboutMe,
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: Colors.black,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Stats Row
                  _buildSocialStats(),
                  const SizedBox(height: 24),

                  // Divider
                  const Divider(color: Palette.border, thickness: 1.5),
                  const SizedBox(height: 24),

                  // ── Content Sections ──
                  BrutalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Contact Info', Icons.perm_contact_calendar_rounded, Palette.blue),
                        const SizedBox(height: 12),
                        _buildContactList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  BrutalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Tech Stack', Icons.layers_rounded, Palette.primary),
                        const SizedBox(height: 12),
                        _buildSkillsWrap(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  BrutalCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Interests & Hobbies', Icons.category_rounded, Palette.pink),
                        const SizedBox(height: 12),
                        _buildInterestsWrap(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }

  DecorationImage? _getCoverImage() {
    if (user.coverPhotoPath != null && user.coverPhotoPath!.isNotEmpty) {
      ImageProvider img;
      if (user.coverPhotoPath!.startsWith('lib/')) {
        img = AssetImage(user.coverPhotoPath!);
      } else {
        img = FileImage(File(user.coverPhotoPath!));
      }
      return DecorationImage(image: img, fit: BoxFit.cover);
    }
    return null;
  }

  void _showPhotoOptions({required bool isCover}) {
    final hasPhoto = isCover
        ? (user.coverPhotoPath != null && user.coverPhotoPath!.isNotEmpty)
        : (profile.profileImagePath != null && profile.profileImagePath!.isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: const Border(
            top: BorderSide(color: Palette.border, width: 2.5),
            left: BorderSide(color: Palette.border, width: 2.5),
            right: BorderSide(color: Palette.border, width: 2.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (hasPhoto) ...[
                  Expanded(child: BrutalButton(
                    text: 'View',
                    icon: Icons.visibility_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      _showExpandedImage(isCover);
                    },
                    color: Palette.primary,
                    textColor: Colors.white,
                  )),
                  const SizedBox(width: 12),
                ],
                Expanded(child: BrutalButton(
                  text: 'Upload',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    _pickPhoto(isCover);
                  },
                  color: Palette.secondary,
                  textColor: Colors.white,
                )),
              ],
            ),
            // Only show Remove button if it is Cover Photo AND has a photo
            if (isCover && hasPhoto) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: BrutalButton(
                      text: 'Remove',
                      icon: Icons.delete_outline,
                      onPressed: () {
                        Navigator.pop(context);
                        _removePhoto(isCover);
                      },
                      color: Colors.red,
                      textColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showExpandedImage(bool isCover) {
    final path = isCover ? user.coverPhotoPath : profile.profileImagePath;
    final bool hasCustom = path != null && path.isNotEmpty;

    Widget imageWidget;
    if (hasCustom) {
      if (path!.startsWith('lib/')) {
        imageWidget = Image.asset(path!);
      } else {
        imageWidget = Image.file(File(path!));
      }
    } else {
      if (isCover) {
        imageWidget = Image.asset('lib/assets/capy_cover.jpg');
      } else {
        imageWidget = Container(
          width: 300, height: 300,
          color: Palette.secondary.withOpacity(0.15),
          alignment: Alignment.center,
          child: Icon(Icons.person, size: 100, color: Palette.secondary),
        );
      }
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: InteractiveViewer(
                child: imageWidget,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BrutalCard(
                onTap: () => Navigator.pop(context),
                padding: const EdgeInsets.all(8),
                borderRadius: 30,
                color: Palette.white,
                shadowOffset: 2,
                child: const Icon(Icons.close, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto(bool isCover) async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (isCover) {
          user.coverPhotoPath = file.path;
        } else {
          profile.profileImagePath = file.path;
        }
      });
    }
  }

  void _removePhoto(bool isCover) {
    setState(() {
      if (isCover) {
        user.coverPhotoPath = null;
      } else {
        profile.profileImagePath = null;
      }
    });
  }

  Widget _buildSocialStats() {
    final friendCount = profile.friends.length;
    final skillCount = profile.skills.split(',').where((s) => s.isNotEmpty).length;
    final hobbyCount = profile.hobby.split(',').where((s) => s.isNotEmpty).length +
        profile.interests.split(',').where((s) => s.isNotEmpty).length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem('Friends', '$friendCount'),
        _statItem('Skills', '$skillCount'),
        _statItem('Interests', '$hobbyCount'),
      ],
    );
  }

  Widget _statItem(String label, String value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: BrutalCard(
          padding: const EdgeInsets.symmetric(vertical: 10),
          shadowOffset: 2,
          child: Column(
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Palette.textPrimary,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: Palette.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    if (profile.profileImagePath != null &&
        profile.profileImagePath!.isNotEmpty) {
      if (profile.profileImagePath!.startsWith('lib/')) {
        return Image.asset(
          profile.profileImagePath!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      } else {
        return Image.file(
          File(profile.profileImagePath!),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
      }
    }
    return Container(
      width: size,
      height: size,
      color: Palette.secondary.withOpacity(0.15),
      child: Icon(Icons.person, size: size * 0.5, color: Palette.secondary),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.black),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Palette.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactList() {
    final hasEmail = profile.email.isNotEmpty;
    final hasPhone = profile.phone.isNotEmpty;

    if (!hasEmail && !hasPhone) {
      return Text('No contact info added.',
          style: GoogleFonts.dmSans(color: Palette.textMuted));
    }

    return Column(
      children: [
        if (hasEmail) _contactRow(Icons.email_outlined, profile.email),
        if (hasEmail && hasPhone) const SizedBox(height: 12),
        if (hasPhone) _contactRow(Icons.phone_outlined, profile.phone),
      ],
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Palette.border, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Palette.border, offset: Offset(2, 2), blurRadius: 0),
            ],
          ),
          child: Icon(icon, size: 16, color: Palette.textPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Palette.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsWrap() {
    final skills = profile.skills
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (skills.isEmpty) {
      return Text('No skills added.',
          style: GoogleFonts.dmSans(color: Palette.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) => _skillChip(skill)).toList(),
    );
  }

  Widget _skillChip(String skill) {
    final iconUrl = _getTechIconUrl(skill);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border, width: 1.5),
        boxShadow: const [
          BoxShadow(
              color: Palette.border, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconUrl != null) ...[
            SvgPicture.network(
              iconUrl,
              width: 16,
              height: 16,
              placeholderBuilder: (_) => const SizedBox(width: 16, height: 16),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            skill,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsWrap() {
    final hobbies = profile.hobby
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final interests = profile.interests
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    
    final all = [...hobbies, ...interests];

    if (all.isEmpty) {
      return Text('No interests added.',
          style: GoogleFonts.dmSans(color: Palette.textMuted));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: all.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Palette.border, width: 1.5),
            boxShadow: const [
              BoxShadow(
                  color: Palette.border, offset: Offset(2, 2), blurRadius: 0),
            ],
          ),
          child: Text(
            item,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Palette.textPrimary,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _navigateToEditor() async {
    final result = await Navigator.push<UserProfile>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileEditorScreen(profile: profile),
      ),
    );
    if (result != null) {
      final p = AuthService().currentUser!.profile;
      p.name = result.name;
      p.username = result.username;
      p.bio = result.bio;
      p.email = result.email;
      p.phone = result.phone;
      p.hobby = result.hobby;
      p.skills = result.skills;
      p.aboutMe = result.aboutMe;
      p.interests = result.interests;
      p.profileImagePath = result.profileImagePath;
      setState(() {});
    }
  }

  String? _getTechIconUrl(String skill) {
    final s = skill.toLowerCase().trim();
    const base = 'https://cdn.jsdelivr.net/gh/devicons/devicon/icons';

    switch (s) {
      case 'flutter': return '$base/flutter/flutter-original.svg';
      case 'dart': return '$base/dart/dart-original.svg';
      case 'python': return '$base/python/python-original.svg';
      case 'java': return '$base/java/java-original.svg';
      case 'javascript': case 'js': return '$base/javascript/javascript-original.svg';
      case 'html': case 'html5': return '$base/html5/html5-original.svg';
      case 'css': case 'css3': return '$base/css3/css3-original.svg';
      case 'bootstrap': return '$base/bootstrap/bootstrap-original.svg';
      case 'vue': case 'vue.js': case 'vuejs': return '$base/vuejs/vuejs-original.svg';
      case 'react': case 'reactjs': return '$base/react/react-original.svg';
      case 'node': case 'nodejs': return '$base/nodejs/nodejs-original.svg';
      case 'c++': case 'cpp': return '$base/cplusplus/cplusplus-original.svg';
      case 'c#': case 'csharp': return '$base/csharp/csharp-original.svg';
      case 'git': return '$base/git/git-original.svg';
      case 'mysql': return '$base/mysql/mysql-original.svg';
      case 'firebase': return '$base/firebase/firebase-plain.svg';
      case 'swift': return '$base/swift/swift-original.svg';
      case 'kotlin': return '$base/kotlin/kotlin-original.svg';
      case 'php': return '$base/php/php-original.svg';
      case 'go': case 'golang': return '$base/go/go-original-wordmark.svg';
      case 'ruby': return '$base/ruby/ruby-original.svg';
      case 'rust': return '$base/rust/rust-plain.svg';
      case 'typescript': case 'ts': return '$base/typescript/typescript-original.svg';
      default: return null;
    }
  }
}
