import 'package:flutter/material.dart';

class MyColorsExtension extends ThemeExtension<MyColorsExtension> {
  MyColorsExtension({
    this.voiceNoteSliderBackground,
  });

  final Color? voiceNoteSliderBackground;

  @override
  ThemeExtension<MyColorsExtension> copyWith({
    Color? brandSecondaryColor,
    Color? mySecundaryColor,
  }) {
    return MyColorsExtension(
      voiceNoteSliderBackground: voiceNoteSliderBackground,
    );
  }

  @override
  ThemeExtension<MyColorsExtension> lerp(
    covariant ThemeExtension<MyColorsExtension>? other,
    double t,
  ) {
    if (other is! MyColorsExtension) {
      return this;
    }

    return MyColorsExtension(
      voiceNoteSliderBackground: Color.lerp(
          voiceNoteSliderBackground, other.voiceNoteSliderBackground, t)!,
    );
  }
}

class AppThemes {
  static double textScaleFactor = 1.0;

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Colors.deepOrange,
        onPrimary: Colors.white,
        secondary: Colors.green,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
        primaryContainer: Colors.grey,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'OpenSans',
      textTheme: _buildTextTheme(),
      extensions: [
        MyColorsExtension(voiceNoteSliderBackground: Colors.grey[800]),
      ],
      hintColor: Colors.black.withOpacity(0.4),
      iconTheme: const IconThemeData(color: Colors.deepOrange),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      dividerColor: Colors.grey[300],
      highlightColor: Colors.orange.withOpacity(0.1),
      splashColor: Colors.orange.withOpacity(0.1),
      hoverColor: Colors.orange.withOpacity(0.02),
      focusColor: const Color(0xfff3f3f4),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Colors
            .deepOrange, // Keeps the primary accent color from the light scheme
        onPrimary: Colors
            .white, // Ensures text/icons on the primary color are readable
        secondary: Colors.green, // The secondary accent color
        onSecondary:
            Colors.white, // Ensures readability on secondary buttons or accents
        surface:
            Colors.black87, // Darker surface color for cards, dialogs, etc.
        onSurface: Colors.white, // Light text/icons on surface elements
        error: Colors.red, // Red for error elements
        onError: Colors.white, // White text/icons on error elements
      ),
      extensions: [
        MyColorsExtension(voiceNoteSliderBackground: Colors.white70),
      ],

      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'OpenSans',
      textTheme:
          _buildTextTheme(), // Use a helper to dynamically scale font sizes
      
      hintColor: Colors.white.withOpacity(0.5),
      iconTheme: const IconThemeData(color: Colors.deepOrange),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white70),
      ),
      dividerColor: Colors.grey[300],
      highlightColor: Colors.orange.withOpacity(0.1),
      splashColor: Colors.orange.withOpacity(0.1),
      hoverColor: Colors.orange.withOpacity(0.02),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      bodyLarge: TextStyle(
          fontSize: 18.0 * textScaleFactor, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(
          fontSize: 14.0 * textScaleFactor, fontWeight: FontWeight.normal),
      bodySmall: TextStyle(
          fontSize: 12.0 * textScaleFactor, fontWeight: FontWeight.normal),
      displayLarge: TextStyle(
          fontSize: 22.0 * textScaleFactor, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(
          fontSize: 20.0 * textScaleFactor, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(
          fontSize: 16.0 * textScaleFactor, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(
          fontSize: 16.0 * textScaleFactor, fontWeight: FontWeight.normal),
    );
  }
}
