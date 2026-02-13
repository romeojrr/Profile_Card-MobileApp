import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/glass_theme.dart';

/// Card with bold border and offset shadow.
class BrutalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final double borderWidth;
  final double shadowOffset;
  final VoidCallback? onTap;

  const BrutalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 12,
    this.color,
    this.borderColor,
    this.borderWidth = 2.5,
    this.shadowOffset = 4,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fill = color ?? Palette.surface;
    final bColor = borderColor ?? Palette.border;

    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: bColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: bColor,
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return _TapBounce(onTap: onTap!, child: card);
    }
    return card;
  }
}

/// Button with cute scale-press animation.
class BrutalButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const BrutalButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.icon,
    this.borderRadius = 8,
    this.padding,
  });

  @override
  State<BrutalButton> createState() => _BrutalButtonState();
}

class _BrutalButtonState extends State<BrutalButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0,
      upperBound: 1,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Curves.easeOutQuad,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fill = widget.color ?? Palette.secondary;
    final tColor = widget.textColor ??
        (fill == Palette.white ? Palette.textPrimary : Colors.white);

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: Palette.border, width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Palette.border,
                offset: Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: tColor),
                const SizedBox(width: 8),
              ],
              Text(
                widget.text,
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: tColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Styled text field.
class BrutalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final Color? focusColor;

  const BrutalTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.focusColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      style: GoogleFonts.dmSans(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: Palette.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 20, color: Palette.textSecondary)
            : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Palette.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.border, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusColor ?? Palette.border, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.error, width: 2.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Palette.error, width: 2.5),
        ),
      ),
    );
  }
}

/// Reusable tap-bounce wrapper for cute press animations.
class _TapBounce extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;
  const _TapBounce({required this.onTap, required this.child});

  @override
  State<_TapBounce> createState() => _TapBounceState();
}

class _TapBounceState extends State<_TapBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Staggered entry animation for lists and columns.
class BrutalEntryAnimation extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final double verticalOffset;

  const BrutalEntryAnimation({
    super.key,
    required this.child,
    this.index = 0,
    this.delay = Duration.zero,
    this.verticalOffset = 50.0,
  });

  @override
  State<BrutalEntryAnimation> createState() => _BrutalEntryAnimationState();
}

class _BrutalEntryAnimationState extends State<BrutalEntryAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    // Calculate staggered start time based on index
    final double start = (widget.index * 0.1).clamp(0.0, 0.5);
    final double end = (start + 0.5).clamp(0.0, 1.0);

    _slide = Tween<Offset>(
            begin: Offset(0, widget.verticalOffset / 100), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _ctrl,
            curve: Interval(start, end, curve: Curves.easeOutBack)));
            
    _fade = CurvedAnimation(
        parent: _ctrl, curve: Interval(start, end, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Alias for old code referencing GlassCard
typedef GlassCard = BrutalCard;
