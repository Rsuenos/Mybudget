import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeOption {
  light,
  dark,
  colorful,
  minimalist,
  neomorphic,
  flat,
  materialDesign,
  samsungOneUI,
  themeBull,
}

class ThemeProvider extends ChangeNotifier {
  static const _prefKey = 'selected_theme';

  ThemeProvider() {
    _loadFromPrefs();
  }

  AppThemeOption _option = AppThemeOption.light;

  AppThemeOption get option => _option;

  ThemeData get themeData {
    switch (_option) {
      case AppThemeOption.dark:
        return ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF00BFA5), // teal accent
            secondary: Color(0xFF80DEEA),
            surface: Color(0xFF121212),
            onSurface: Colors.white,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.white60),
          ),
        );

      case AppThemeOption.colorful:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.deepPurple,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
          ).copyWith(secondary: Colors.amber),
          scaffoldBackgroundColor: Colors.white,
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        );

      case AppThemeOption.light:
        return ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.blueAccent,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        );

      case AppThemeOption.minimalist:
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: const ColorScheme.light(
            primary: Colors.black,
            onPrimary: Colors.white,
            secondary: Colors.grey,
            surface: Colors.white,
            onSurface: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            foregroundColor: Colors.black,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        );

      case AppThemeOption.neomorphic:
        // Neomorphic: soft shadows, raised surfaces — increase contrast for accessibility
        final bg = const Color(0xFFECEFF1);
        final surface = Colors.white;
        final shadow = Colors.grey.shade400;
        return ThemeData(
          brightness: Brightness.light,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey)
              .copyWith(
                surface: bg,
                surfaceContainerHighest: surface,
                primary: Colors.blueGrey.shade800,
                onPrimary: Colors.white,
                secondary: Colors.cyan.shade700,
                onSurface: Colors.black87,
              ),
          cardTheme: CardThemeData(
            color: surface,
            elevation: 4,
            shadowColor: shadow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 6,
              shadowColor: shadow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.blueGrey.shade900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        );

      case AppThemeOption.flat:
        // Flat design: bold colors, no shadows — increase contrast and font sizes
        final primary = Colors.teal.shade900;
        return ThemeData(
          brightness: Brightness.light,
          primaryColor: primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primary,
          ).copyWith(secondary: Colors.cyan.shade700),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          cardTheme: const CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        );

      case AppThemeOption.materialDesign:
        // Material 3 with accessible typography and higher contrast
        final seed = Colors.indigo.shade700;
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
          ).copyWith(onSurface: Colors.black87),
          appBarTheme: const AppBarTheme(centerTitle: true),
          cardTheme: CardThemeData(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
            bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
            bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        );

      case AppThemeOption.samsungOneUI:
        // One UI: larger headers, rounded corners, high accessibility
        final bg = const Color(0xFFF6F6F6);
        final primary = Colors.deepPurple.shade700;
        return ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(seedColor: primary).copyWith(
            secondary: Colors.deepPurpleAccent,
            surface: bg,
            onSurface: Colors.black87,
          ),
          scaffoldBackgroundColor: bg,
          appBarTheme: AppBarTheme(
            backgroundColor: bg,
            elevation: 0,
            foregroundColor: Colors.black,
            titleTextStyle: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            bodyLarge: TextStyle(fontSize: 18),
            bodyMedium: TextStyle(fontSize: 16),
          ),
        );

      case AppThemeOption.themeBull:
        // Theme Bull: inspired by metallic/golden budget icon - dark background with gold accents
        final primaryGold = const Color(0xFFB8892B);
        final accent = const Color(0xFF2BB3A6); // complementary teal accent
        final bg = const Color(0xFF071225); // deep navy/charcoal
        final card = const Color(0xFF0E2636);
        return ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.dark(
            primary: primaryGold,
            secondary: accent,
            surface: card,
            onSurface: Colors.white,
            onPrimary: Colors.black,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: bg,
            elevation: 1,
            foregroundColor: primaryGold,
            titleTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          cardTheme: CardThemeData(
            color: card,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: accent,
            foregroundColor: Colors.white,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: card,
            hintStyle: TextStyle(color: Colors.white70),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
            bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
            bodyMedium: TextStyle(color: Colors.white60, fontSize: 14),
          ),
        );
    }
  }

  void setTheme(AppThemeOption option) {
    _option = option;
    _saveToPrefs();
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt(_prefKey);
    if (idx != null && idx >= 0 && idx < AppThemeOption.values.length) {
      _option = AppThemeOption.values[idx];
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKey, _option.index);
  }
}
