import 'dart:ui';

import 'package:flutter/material.dart';

class LuminaColors {
  static const Color background = Color(0xFFFBF8FD);
  static const Color backgroundAlt = Color(0xFFF5F6F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF4F3F9);
  static const Color surfaceMuted = Color(0xFFEDECF4);
  static const Color onSurface = Color(0xFF1B1B1F);
  static const Color onSurfaceMuted = Color(0xFF5C6272);
  static const Color primary = Color(0xFF4A52FF);
  static const Color primarySoft = Color(0xFF9197FF);
  static const Color primaryDeep = Color(0xFF2D32E7);
  static const Color accent = Color(0xFF72FCB1);
  static const Color accentSoft = Color(0xFFE7FFF3);
  static const Color warning = Color(0xFFFE9D00);
  static const Color warningSoft = Color(0xFFFFF3D8);
  static const Color danger = Color(0xFFEF5350);
  static const Color outline = Color(0xFFC6C6D0);
}

ThemeData buildLuminaTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: LuminaColors.primary,
    brightness: Brightness.light,
    surface: LuminaColors.surface,
    background: LuminaColors.background,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: base.copyWith(
      primary: LuminaColors.primary,
      secondary: LuminaColors.primarySoft,
      surface: LuminaColors.surface,
      background: LuminaColors.background,
      onSurface: LuminaColors.onSurface,
    ),
    scaffoldBackgroundColor: LuminaColors.background,
    fontFamily: 'Inter',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: LuminaColors.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      centerTitle: false,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        color: LuminaColors.onSurface,
        letterSpacing: -0.9,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: LuminaColors.onSurface,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: LuminaColors.onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: LuminaColors.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: LuminaColors.onSurfaceMuted,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.45,
        color: LuminaColors.onSurfaceMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: LuminaColors.onSurface,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LuminaColors.surfaceSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: const BorderSide(color: LuminaColors.primary, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF9AA2B1)),
      labelStyle: const TextStyle(color: Color(0xFF5C6272)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: LuminaColors.primary,
        shadowColor: LuminaColors.primary.withOpacity(0.24),
        elevation: 0,
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LuminaColors.onSurface,
        side: BorderSide(color: LuminaColors.outline.withOpacity(0.5)),
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: LuminaColors.primary,
      unselectedItemColor: const Color(0xFF8C93A6),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}

class LuminaPageBackground extends StatelessWidget {
  const LuminaPageBackground({
    super.key,
    required this.child,
    this.bottomSafe = true,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final bool bottomSafe;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [LuminaColors.background, LuminaColors.backgroundAlt],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            left: -100,
            child: _GlowDot(
              color: LuminaColors.primary.withOpacity(0.10),
              size: 240,
            ),
          ),
          Positioned(
            top: 140,
            right: -70,
            child: _GlowDot(
              color: LuminaColors.primarySoft.withOpacity(0.11),
              size: 180,
            ),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: _GlowDot(
              color: LuminaColors.primary.withOpacity(0.08),
              size: 220,
            ),
          ),
          SafeArea(bottom: bottomSafe, child: child),
        ],
      ),
    );

    return content;
  }
}

class LuminaGlassCard extends StatelessWidget {
  const LuminaGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D1020).withOpacity(0.06),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class LuminaSectionCard extends StatelessWidget {
  const LuminaSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? LuminaColors.surface : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1020).withOpacity(0.05),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LuminaHeroLogo extends StatelessWidget {
  const LuminaHeroLogo({
    super.key,
    required this.assetPath,
    required this.title,
    this.subtitle,
    this.logoSize = 56,
    this.titleStyle,
  });

  final String assetPath;
  final String title;
  final String? subtitle;
  final double logoSize;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          assetPath,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style:
                  titleStyle ??
                  Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: LuminaColors.onSurfaceMuted,
                  letterSpacing: 2.8,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class LuminaPill extends StatelessWidget {
  const LuminaPill({
    super.key,
    required this.label,
    this.backgroundColor = LuminaColors.accent,
    this.textColor = LuminaColors.onSurface,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class LuminaStatCard extends StatelessWidget {
  const LuminaStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.gradient,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? LuminaColors.surface : null,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D1020).withOpacity(0.05),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: gradient == null
                  ? LuminaColors.onSurfaceMuted
                  : Colors.white.withOpacity(0.82),
              letterSpacing: 1.2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: gradient == null ? LuminaColors.onSurface : Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: gradient == null
                    ? LuminaColors.onSurfaceMuted
                    : Colors.white70,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LuminaGradientButton extends StatelessWidget {
  const LuminaGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [LuminaColors.primary, LuminaColors.primarySoft],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: LuminaColors.primary.withOpacity(0.24),
              blurRadius: 30,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: Colors.white, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  const _GlowDot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
