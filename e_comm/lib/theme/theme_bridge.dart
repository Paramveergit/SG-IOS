// Theme Bridge - Maintains backward compatibility while enabling modern theming
// This allows gradual migration from old AppConstant to new AppTheme

import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeBridge {
  static bool _isInitialized = false;
  
  /// Initialize the theme bridge
  static void init() {
    if (!_isInitialized) {
      _isInitialized = true;
      // Any initialization logic can go here
    }
  }
  
  /// Get the current theme (maintains backward compatibility)
  static ThemeData get theme => AppTheme.lightTheme;
  
  /// Get the current color scheme
  static ColorScheme get colorScheme => AppTheme.lightTheme.colorScheme;
  
  /// Backward compatibility getters for AppConstant
  static Color get appMainColor => AppThemeCompat.appMainColor;
  static Color get appScendoryColor => AppThemeCompat.appScendoryColor;
  static Color get appTextColor => AppThemeCompat.appTextColor;
  static Color get appStatusBarColor => AppThemeCompat.appStatusBarColor;
  static String get appMainName => AppThemeCompat.appMainName;
  static String get appPoweredBy => AppThemeCompat.appPoweredBy;
  
  /// Modern theme getters
  static Color get primary => AppTheme.primary;
  static Color get primaryDark => AppTheme.primaryDark;
  static Color get primaryLight => AppTheme.primaryLight;
  static Color get accent => AppTheme.accent;
  static Color get background => AppTheme.background;
  static Color get surface => AppTheme.surface;
  static Color get surfaceVariant => AppTheme.surfaceVariant;
  static Color get onPrimary => AppTheme.onPrimary;
  static Color get onSurface => AppTheme.onSurface;
  static Color get onSurfaceVariant => AppTheme.onSurfaceVariant;
  static Color get onBackground => AppTheme.onBackground;
  static Color get success => AppTheme.success;
  static Color get warning => AppTheme.warning;
  static Color get error => AppTheme.error;
  static Color get info => AppTheme.info;
  
  /// Spacing system
  static double get spaceXs => AppTheme.spaceXs;
  static double get spaceSm => AppTheme.spaceSm;
  static double get spaceMd => AppTheme.spaceMd;
  static double get spaceLg => AppTheme.spaceLg;
  static double get spaceXl => AppTheme.spaceXl;
  static double get space2xl => AppTheme.space2xl;
  static double get space3xl => AppTheme.space3xl;
  
  /// Border radius system
  static double get radiusXs => AppTheme.radiusXs;
  static double get radiusSm => AppTheme.radiusSm;
  static double get radiusMd => AppTheme.radiusMd;
  static double get radiusLg => AppTheme.radiusLg;
  static double get radiusXl => AppTheme.radiusXl;
  static double get radius2xl => AppTheme.radius2xl;
  static double get radiusFull => AppTheme.radiusFull;
  
  /// Elevation system
  static double get elevation0 => AppTheme.elevation0;
  static double get elevation1 => AppTheme.elevation1;
  static double get elevation2 => AppTheme.elevation2;
  static double get elevation3 => AppTheme.elevation3;
  static double get elevation4 => AppTheme.elevation4;
  static double get elevation5 => AppTheme.elevation5;
  
  /// Animation durations
  static Duration get durationFast => AppTheme.durationFast;
  static Duration get durationMedium => AppTheme.durationMedium;
  static Duration get durationSlow => AppTheme.durationSlow;
  
  /// Typography system
  static TextStyle get displayLarge => AppTheme.displayLarge;
  static TextStyle get displayMedium => AppTheme.displayMedium;
  static TextStyle get displaySmall => AppTheme.displaySmall;
  static TextStyle get headlineLarge => AppTheme.headlineLarge;
  static TextStyle get headlineMedium => AppTheme.headlineMedium;
  static TextStyle get headlineSmall => AppTheme.headlineSmall;
  static TextStyle get titleLarge => AppTheme.titleLarge;
  static TextStyle get titleMedium => AppTheme.titleMedium;
  static TextStyle get titleSmall => AppTheme.titleSmall;
  static TextStyle get labelLarge => AppTheme.labelLarge;
  static TextStyle get labelMedium => AppTheme.labelMedium;
  static TextStyle get labelSmall => AppTheme.labelSmall;
  static TextStyle get bodyLarge => AppTheme.bodyLarge;
  static TextStyle get bodyMedium => AppTheme.bodyMedium;
  static TextStyle get bodySmall => AppTheme.bodySmall;
}
