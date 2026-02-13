import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/friend.dart';
import '../models/auth_service.dart';
import '../theme/glass_theme.dart';
import '../widgets/glass_card.dart';
import 'add_connection_screen.dart';

class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({super.key});

  @override
  State<ConnectionsScreen> createState() => ConnectionsScreenState();
}

class ConnectionsScreenState extends State<ConnectionsScreen> {
  // Access friends from the current user's profile
  List<Friend> get friends => AuthService().currentUser?.profile.friends ?? [];

  @override
  void initState() {
    super.initState();
  }

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Friend> get filteredFriends {
    if (_searchQuery.isEmpty) return friends;
    return friends
        .where((f) =>
            f.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            f.username.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _addOrEdit({Friend? friend, int? index}) async {
    final result = await Navigator.push<Friend>(
      context,
      MaterialPageRoute(
        builder: (_) => AddConnectionScreen(existing: friend),
      ),
    );
    if (result != null) {
      setState(() {
        if (index != null) {
          // preserve the profile image from old friend
          if (result.profileImagePath == null && friend?.profileImagePath != null) {
            friends[index] = Friend(
              name: result.name,
              username: result.username,
              contact: result.contact,
              bio: result.bio,
              skills: result.skills,
              profileImagePath: friend!.profileImagePath,
            );
          } else {
            friends[index] = result;
          }
        } else {
          friends.add(result);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(index != null ? 'Updated!' : 'Friend added!',
                style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
          ]),
          backgroundColor: Palette.success,
          margin: const EdgeInsets.all(16),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Palette.border, width: 1),
          ),
        ));
      }
    }
  }

  void _pickFriendImage(int index) async {
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
            Text('Change Photo', style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w600)),
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
    if (file != null) {
      setState(() {
        final f = friends[index];
        friends[index] = Friend(
          name: f.name,
          username: f.username,
          contact: f.contact,
          bio: f.bio,
          skills: f.skills,
          profileImagePath: file.path,
        );
      });
    }
  }

  void _delete(int index) {
    final name = friends[index].name;

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
                  color: Palette.error.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_remove_outlined,
                    size: 28, color: Palette.error),
              ),
              const SizedBox(height: 16),
              Text('Remove Friend?',
                  style: GoogleFonts.lexend(
                      fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Remove $name from your friends list?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
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
                      text: 'Remove',
                      onPressed: () {
                        setState(() => friends.removeAt(index));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('$name removed',
                              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                          backgroundColor: Palette.error,
                          margin: const EdgeInsets.all(16),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Palette.border, width: 1),
                          ),
                        ));
                      },
                      color: Palette.error,
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

  @override
  Widget build(BuildContext context) {
    final displayed = filteredFriends;

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Header (Title + Add Button) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Friends', 
                    style: GoogleFonts.lexend(
                        fontSize: 32, fontWeight: FontWeight.w800, color: Palette.textPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Palette.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Palette.border, width: 1.5),
                    ),
                    child: Text('${friends.length}',
                        style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Palette.secondary)),
                  ),
                  const Spacer(),
                  BrutalButton(
                    text: 'Add Friend',
                    icon: Icons.person_add_rounded,
                    onPressed: () => _addOrEdit(),
                    color: Palette.primary,
                    textColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: Palette.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Palette.border, width: 2.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Palette.border,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 20,
                        color: Palette.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: GoogleFonts.dmSans(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search by Name or Username',
                          hintStyle: GoogleFonts.dmSans(
                              fontSize: 13, color: Palette.textMuted),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Friends list ──
            Expanded(
              child: displayed.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: displayed.length,
                      itemBuilder: (_, i) {
                        final actualIndex = friends.indexOf(displayed[i]);
                        return _friendListTile(displayed[i], actualIndex);
                      },
                    ),
            ),
          ],
        ),
      ), 
    );
  }

  Widget _friendListTile(Friend f, int index) {
    final colors = [Palette.secondary, Palette.tertiary, Palette.green, Palette.blue];
    final color = colors[index % colors.length];
  
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shadowOffset: 2,
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: () => _pickFriendImage(index),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Palette.border, width: 2),
                ),
                alignment: Alignment.center,
                child: f.profileImagePath != null
                    ? ClipOval(
                        child: Image.file(
                          File(f.profileImagePath!),
                          fit: BoxFit.cover, width: 50, height: 50,
                        ),
                      )
                    : Text(
                        f.name.isNotEmpty ? f.name[0].toUpperCase() : '?',
                        style: GoogleFonts.lexend(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Palette.textPrimary,
                    ),
                  ),
                  if (f.username.isNotEmpty)
                    Text(
                      f.username,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Palette.textSecondary,
                      ),
                    ),
                ],
              ),
            ),

            // Actions
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Palette.textPrimary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Palette.border, width: 2),
              ),
              color: Palette.surface,
              elevation: 4,
              onSelected: (value) {
                if (value == 'edit') {
                  _addOrEdit(friend: f, index: index);
                } else if (value == 'delete') {
                  _delete(index);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit_outlined, size: 18, color: Palette.textPrimary),
                      const SizedBox(width: 12),
                      Text('Edit Friend', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline_rounded, size: 18, color: Palette.error),
                      const SizedBox(width: 12),
                      Text('Remove Friend', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600, color: Palette.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: BrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.secondary.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(color: Palette.border, width: 2),
              ),
              child: Icon(Icons.people_outline_rounded,
                  size: 40, color: Palette.secondary),
            ),
            const SizedBox(height: 16),
            Text('No friends yet',
                style: GoogleFonts.lexend(
                    fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Tap + to add your first friend',
                style: GoogleFonts.dmSans(
                    fontSize: 13, color: Palette.textSecondary)),
          ],
        ),
      ),
    );
  }
}
