import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Define el tema visual global de la aplicación Palate.
/// Centraliza la paleta de colores Material 3 y la tipografía personalizada
/// para mantener coherencia visual en todas las pantallas.
class AppTheme {
  // ==================== COLORES ====================

  /// Color primario: terracota oscuro, usado en botones y elementos principales
  static const Color primary = Color(0xFF732b16);

  /// Variante del color primario, más claro
  static const Color primaryContainer = Color(0xFF91412b);

  /// Color secundario: ámbar oscuro, usado en acentos y badges
  static const Color secondary = Color(0xFF7f5700);

  /// Contenedor secundario: mostaza, usado en chips y badges de estado
  static const Color secondaryContainer = Color(0xFFfdb733);

  /// Fondo general de la aplicación: crema cálido
  static const Color surface = Color(0xFFfff8f6);

  /// Nivel bajo de contenedor de superficie, usado en inputs
  static const Color surfaceContainerLow = Color(0xFFfff0ed);

  /// Nivel medio de contenedor de superficie, usado en cards
  static const Color surfaceContainer = Color(0xFFfaebe7);

  /// Nivel alto de contenedor de superficie
  static const Color surfaceContainerHigh = Color(0xFFf4e5e2);

  /// Color de texto principal sobre superficies claras
  static const Color onSurface = Color(0xFF211a18);

  /// Color de texto secundario, para subtítulos y textos de apoyo
  static const Color onSurfaceVariant = Color(0xFF55433e);

  /// Color de bordes y divisores
  static const Color outline = Color(0xFF88726d);

  /// Variante de bordes, más suave
  static const Color outlineVariant = Color(0xFFdbc1ba);

  /// Color de error, usado en validaciones y alertas
  static const Color error = Color(0xFFba1a1a);

  // ==================== TEMA PRINCIPAL ====================

  /// Retorna el [ThemeData] configurado con la identidad visual de Palate.
  /// Utiliza Material Design 3 con el esquema de colores terracota.
  static ThemeData get tema {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF732b16),
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF91412b),
        onPrimaryContainer: Color(0xFFffc2b2),
        secondary: Color(0xFF7f5700),
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFfdb733),
        onSecondaryContainer: Color(0xFF6d4a00),
        tertiary: Color(0xFF43423e),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF5b5955),
        onTertiaryContainer: Color(0xFFd4d0ca),
        error: Color(0xFFba1a1a),
        onError: Colors.white,
        errorContainer: Color(0xFFffdad6),
        onErrorContainer: Color(0xFF93000a),
        surface: Color(0xFFfff8f6),
        onSurface: Color(0xFF211a18),
        onSurfaceVariant: Color(0xFF55433e),
        outline: Color(0xFF88726d),
        outlineVariant: Color(0xFFdbc1ba),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFF372e2d),
        onInverseSurface: Color(0xFFfdedea),
        inversePrimary: Color(0xFFffb5a1),
        surfaceTint: Color(0xFF984630),
      ),
      scaffoldBackgroundColor: const Color(0xFFfff8f6),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFFFFBF7),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.newsreader(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          fontStyle: FontStyle.italic,
          color: const Color(0xFF732b16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFfff0ed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF7f5700), width: 1.5),
        ),
      ),
    );
  }

  /// Construye el esquema tipográfico combinando:
  /// - [GoogleFonts.newsreader] para títulos y encabezados (estilo editorial)
  /// - [GoogleFonts.inter] para cuerpo de texto (alta legibilidad)
  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.newsreader(
        fontSize: 40, fontWeight: FontWeight.w600, color: const Color(0xFF211a18),
      ),
      displayMedium: GoogleFonts.newsreader(
        fontSize: 32, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      displaySmall: GoogleFonts.newsreader(
        fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 40, fontWeight: FontWeight.w600, color: const Color(0xFF211a18),
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 32, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      headlineSmall: GoogleFonts.newsreader(
        fontSize: 24, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      titleLarge: GoogleFonts.newsreader(
        fontSize: 20, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFF211a18),
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF211a18),
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: const Color(0xFF211a18),
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: const Color(0xFF55433e),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w600,
        letterSpacing: 0.5, color: const Color(0xFF211a18),
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF55433e),
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10, fontWeight: FontWeight.w600,
        letterSpacing: 0.5, color: const Color(0xFF55433e),
      ),
    );
  }
}
