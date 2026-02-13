import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_card.dart';

class AddConnectionScreen extends StatefulWidget {
  final Friend? existing;
  const AddConnectionScreen({super.key, this.existing});

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _contact;
  String? _imagePath;
  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _username = TextEditingController(text: widget.existing?.username ?? '');
    _contact = TextEditingController(text: widget.existing?.contact ?? '');
    _imagePath = widget.existing?.profileImagePath;
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _contact.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final src = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          border: const Border(
            top: BorderSide(color: Palette.border, width: 2.5),
            left: BorderSide(color: Palette.border, width: 2.5),
            right: BorderSide(color: Palette.border, width: 2.5),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Palette.textMuted, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 18),
            Text('Upload Photo', style: GoogleFonts.oswald(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: BrutalButton(
                    text: 'Camera',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    color: Palette.primary,
                    textColor: Colors.white,
                  ), 
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BrutalButton(
                    text: 'Gallery',
                    icon: Icons.photo_library_outlined,
                    onPressed: () => Navigator.pop(context, ImageSource.gallery),
                    color: Palette.secondary,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (src == null) return;
    final file = await ImagePicker()
        .pickImage(source: src, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (file != null) setState(() => _imagePath = file.path);
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
                child: Icon(
                  isEditing ? Icons.save_outlined : Icons.person_add_outlined,
                  size: 28, color: Palette.secondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isEditing ? 'Save Changes?' : 'Add Friend?',
                style: GoogleFonts.oswald(
                    fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                isEditing
                    ? 'Update ${_name.text}\'s info?'
                    : 'Add ${_name.text} to your friends?',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 13, color: Palette.textSecondary),
              ),
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
                      text: isEditing ? 'Save' : 'Add',
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
    Navigator.pop(
      context,
      Friend(
        name: _name.text.trim(),
        username: _username.text.trim().isEmpty
            ? '@${_name.text.trim().split(' ').first}'
            : _username.text.trim(),
        contact: _contact.text.trim(),
        bio: widget.existing?.bio ?? '',
        skills: widget.existing?.skills ?? '',
        profileImagePath: _imagePath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                        Icons.arrow_back_ios_new_rounded, size: 16),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    isEditing ? 'Edit Friend' : 'Add Friend',
                    style: GoogleFonts.oswald(
                        fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile picture upload ──
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Palette.secondary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(color: Palette.border, width: 2.5),
                        ),
                        child: _imagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover, width: 100, height: 100,
                                ),
                              )
                            : Icon(Icons.person_add_rounded,
                                size: 40, color: Palette.secondary),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                          color: Palette.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Palette.surface, width: 2.5),
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('Tap to upload photo',
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 11, color: Palette.textMuted)),
              ),
              const SizedBox(height: 20),

              // ── Basic Info ──
              _sectionTitle('Basic Info', Icons.manage_accounts_rounded),
              const SizedBox(height: 10),
              BrutalCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    BrutalTextField(
                      controller: _name,
                      label: 'Full Name',
                      prefixIcon: Icons.badge_outlined,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 12),
                    BrutalTextField(
                      controller: _username,
                      label: 'Username',
                      hint: '@username',
                      prefixIcon: Icons.alternate_email,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.trim().isEmpty) {
                          return 'Invalid username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    BrutalTextField(
                      controller: _contact,
                      label: 'Email / Contact',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Contact is required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Save button ──
              SizedBox(
                width: double.infinity,
                child: BrutalButton(
                  text: isEditing ? 'SAVE CHANGES' : 'ADD FRIEND',
                  icon: isEditing ? Icons.check_rounded : Icons.person_add,
                  onPressed: _confirmSave,
                  color: Palette.primary,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 24),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Palette.secondary,
            shape: BoxShape.circle,
            border: Border.all(color: Palette.border, width: 2),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.oswald(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
