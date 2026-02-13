import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/glass_theme.dart';
import '../models/auth_service.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'connections_screen.dart';

// ── Main shell with bottom navigation ──
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  final _profileKey = GlobalKey<ProfileScreenState>();
  final _connectionsKey = GlobalKey<ConnectionsScreenState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      ProfileScreen(key: _profileKey),
      ConnectionsScreen(key: _connectionsKey),
    ];
  }

  void _signOut() {
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
                  border: Border.all(color: Palette.border, width: 2),
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 28, color: Palette.error),
              ),
              const SizedBox(height: 16),
              Text('Sign Out?',
                  style: GoogleFonts.lexend(
                      fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text('Are you sure you want to sign out?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                      fontSize: 13, color: Palette.textSecondary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _dialogButton('Cancel', Palette.primary,
                        Colors.white, () => Navigator.pop(context)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dialogButton('Sign Out', Palette.error,
                        Colors.white, () {
                      AuthService().signOut();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                        (_) => false,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogButton(
      String text, Color bg, Color textColor, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Palette.border, width: 2.5),
          boxShadow: const [
            BoxShadow(
              color: Palette.border,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(text,
            style: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w700, color: textColor)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Palette.surface,
          border: Border(
            top: BorderSide(color: Palette.border, width: 2.5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_rounded, 'Home', 0),
            _navItem(Icons.people_rounded, 'Friends', 1),
            _navItem(Icons.logout_rounded, 'Sign Out', -1, isSignOut: true),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int idx, {bool isSignOut = false}) {
    final active = !isSignOut && _idx == idx;
    return GestureDetector(
      onTap: isSignOut ? _signOut : () => setState(() => _idx = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: active
            ? BoxDecoration(
                color: (isSignOut ? Palette.error : Palette.primary),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.border, width: 2.5),
                boxShadow: const [
                  BoxShadow(
                    color: Palette.border,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, 
                color: active ? Colors.white : Palette.textMuted),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : Palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}