import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/glass_theme.dart';
import '../models/user_profile.dart';
import '../models/auth_service.dart';
import '../widgets/glass_card.dart';

class ProfileEditorScreen extends StatefulWidget {
  final UserProfile profile;
  const ProfileEditorScreen({super.key, required this.profile});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _hobby;
  late final TextEditingController _skills;
  late final TextEditingController _aboutMe;
  late final TextEditingController _interests;
  late final TextEditingController _newPassword;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _username = TextEditingController(text: p.username);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _hobby = TextEditingController(text: p.hobby);
    _skills = TextEditingController(text: p.skills);
    _aboutMe = TextEditingController(text: p.aboutMe);
    _interests = TextEditingController(text: p.interests);
    _newPassword = TextEditingController();
    _imagePath = p.profileImagePath;
  }

  @override
  void dispose() {
    for (final c in [
      _name, _username, _email, _phone, _hobby, _skills, _aboutMe, _interests, _newPassword
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource src) async {
    final file = await ImagePicker()
        .pickImage(source: src, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (file != null) setState(() => _imagePath = file.path);
  }

  void _showImageOptions() {
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Palette.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text('Change Photo',
                style: GoogleFonts.oswald(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: BrutalButton(
                    text: 'Camera',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    color: Palette.primary,
                    textColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrutalButton(
                    text: 'Gallery',
                    icon: Icons.photo_library_outlined,
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    color: Palette.secondary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            if (_imagePath != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  text: 'Remove Photo',
                  icon: Icons.delete_outline,
                  onPressed: () {
                    setState(() => _imagePath = null);
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                  textColor: Colors.white,
                ), 
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmSave() {
    if (!_form.currentState!.validate()) return;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Palette.border, width: 2.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Palette.border,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Palette.secondary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.save_outlined,
                    size: 28, color: Palette.secondary),
              ),
              const SizedBox(height: 16),
              Text('Save Changes?',
                  style: GoogleFonts.oswald(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Your profile will be updated.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                      fontSize: 13, color: Palette.textSecondary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: BrutalButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      color: Palette.secondary,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BrutalButton(
                      text: 'Save',
                      onPressed: () {
                        Navigator.pop(context);
                        _save();
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

  void _save() {
    // Update auth credentials
    final error = AuthService().updateCredentials(
      newEmail: _email.text,
      newPassword: _newPassword.text.isNotEmpty ? _newPassword.text : null,
    );

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          backgroundColor: Palette.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final updated = UserProfile(
      name: _name.text.trim(),
      username: _username.text.trim(),
      bio: widget.profile.bio,
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      hobby: _hobby.text.trim(),
      skills: _skills.text.trim(),
      aboutMe: _aboutMe.text.trim(),
      interests: _interests.text.trim(),
      profileImagePath: _imagePath,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Text('Profile updated!',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w600)),
        ]),
        backgroundColor: Palette.success,
        margin: const EdgeInsets.all(16),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Palette.border, width: 1),
        ),
      ),
    );
    Navigator.pop(context, updated);
  }

  Widget _buildAvatar() {
    Widget img;
    if (_imagePath != null && _imagePath!.isNotEmpty) {
      if (_imagePath!.startsWith('lib/')) {
        img = Image.asset(_imagePath!, fit: BoxFit.cover, width: 120, height: 120);
      } else {
        img = Image.file(File(_imagePath!), fit: BoxFit.cover, width: 120, height: 120);
      }
    } else {
      img = Container(
        width: 120,
        height: 120,
        color: Palette.secondary.withOpacity(0.15),
        child: Icon(Icons.person, size: 50, color: Palette.secondary),
      );
    }

    return Center(
      child: GestureDetector(
        onTap: _showImageOptions,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Palette.border, width: 2.5),
              ),
              child: ClipOval(child: img),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                color: Palette.secondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.surface, width: 2.5),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
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

  bool _hasChanges() {
    final p = widget.profile;
    if (_name.text.trim() != p.name) return true;
    if (_username.text.trim() != p.username) return true;
    if (_email.text.trim() != p.email) return true;
    if (_phone.text.trim() != p.phone) return true;
    if (_hobby.text.trim() != p.hobby) return true;
    if (_skills.text.trim() != p.skills) return true;
    if (_aboutMe.text.trim() != p.aboutMe) return true;
    if (_interests.text.trim() != p.interests) return true;
    if (_newPassword.text.isNotEmpty) return true;
    if (_imagePath != p.profileImagePath) return true;
    return false;
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges()) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Palette.border, width: 2.5),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Palette.border, offset: Offset(4, 4), blurRadius: 0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unsaved Changes',
                  style: GoogleFonts.oswald(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Text('You have unsaved changes. Do you want to save them before leaving?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(fontSize: 14, color: Palette.textSecondary)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: BrutalButton(
                      text: 'Discard',
                      onPressed: () => Navigator.pop(ctx, true),
                      color: Palette.error,
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: BrutalButton(
                      text: 'Save',
                      onPressed: () {
                        Navigator.pop(ctx, false);
                        if (_form.currentState!.validate()) {
                          _save();
                        }
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
    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Palette.background,
        body: SafeArea(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),

                // ── Header ──
                Row(
                  children: [
                    BrutalCard(
                      padding: const EdgeInsets.all(8),
                      borderRadius: 8,
                      onTap: () async {
                        if (await _onWillPop()) {
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Text('Edit Profile',
                      style: GoogleFonts.oswald(
                          fontSize: 22, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 24),

              // ── Avatar ──
              _buildAvatar(),
              const SizedBox(height: 8),
              Center(
                child: GestureDetector(
                  onTap: _showImageOptions,
                  child: Text('Change Photo',
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Palette.secondary,
                          decoration: TextDecoration.underline,
                          decorationColor: Palette.secondary)),
                ),
              ),
              const SizedBox(height: 24),

              // ── Personal Info ──
              _sectionTitle('Personal Info', Icons.person_rounded),
              const SizedBox(height: 12),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    BrutalTextField(
                      controller: _name,
                      label: 'Full Name',
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) => v!.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),
                    BrutalTextField(
                      controller: _username,
                      label: 'Username',
                      prefixIcon: Icons.alternate_email,
                      validator: (v) => v!.trim().isEmpty ? 'Username is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── About Me ──
              _sectionTitle('About Me', Icons.info_rounded),
              const SizedBox(height: 12),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: BrutalTextField(
                  controller: _aboutMe,
                  label: 'Tell us about yourself',
                  maxLines: 4,
                ),
              ),
              const SizedBox(height: 18),

              // ── Contact ──
              _sectionTitle('Contact Info', Icons.perm_contact_calendar_rounded),
              const SizedBox(height: 12),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    BrutalTextField(
                      controller: _email,
                      label: 'Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    BrutalTextField(
                      controller: _phone,
                      label: 'Phone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Tech Stack & Interests ──
              _sectionTitle('Tech Stack & Interests', Icons.layers_rounded),
              const SizedBox(height: 12),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    BrutalTextField(
                      controller: _skills,
                      label: 'Tech Stack (comma separated)',
                      prefixIcon: Icons.code,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    BrutalTextField(
                      controller: _interests,
                      label: 'Interests (comma separated)',
                      prefixIcon: Icons.favorite_border,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 14),
                    BrutalTextField(
                      controller: _hobby,
                      label: 'Hobbies (comma separated)',
                      prefixIcon: Icons.sports_esports_outlined,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ── Change Email / Password ──
              _sectionTitle('Change Email / Password', Icons.lock_rounded),
              const SizedBox(height: 12),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    BrutalTextField(
                      controller: _email,
                      label: 'Login Email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v!.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    BrutalTextField(
                      controller: _newPassword,
                      label: 'New Password (leave empty to keep current)',
                      prefixIcon: Icons.lock_outline,
                      obscureText: true,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  text: 'SAVE CHANGES',
                  icon: Icons.check_rounded,
                  onPressed: _confirmSave,
                  color: Palette.primary,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    ));
  }
}
