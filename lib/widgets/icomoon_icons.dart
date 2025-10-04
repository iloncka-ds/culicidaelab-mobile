/// A library that provides custom icons from the Icomoon icon font.
///
/// This library contains icon definitions that can be used throughout the application
/// for consistent iconography. The icons are generated from an Icomoon font package
/// and should be configured in the pubspec.yaml file.
///
/// To use these icons, ensure the icomoon font is properly configured:
/// ```yaml
/// flutter:
///   fonts:
///    - family: icomoon
///      fonts:
///       - asset: fonts/icomoon.ttf
/// ```
import 'package:flutter/widgets.dart';

/// {@template icomoon_icons}
/// A collection of custom icons from the Icomoon font package.
///
/// This class provides static constant definitions for custom icons that can be
/// used throughout the Flutter application. All icons are defined with their
/// corresponding Unicode code points and are associated with the 'icomoon' font family.
///
/// Example usage:
/// ```dart
/// Icon(Icomoon.mosquitoB)
/// Icon(Icomoon.mosquitoT, size: 24.0, color: Colors.green)
/// ```
/// {@endtemplate}
class Icomoon {
  Icomoon._();
  /// A private constructor to prevent instantiation of this utility class.
  ///
  /// This class only contains static constants and should not be instantiated.
  static const String _fontFamily = 'icomoon';
  /// The font family name used for all Icomoon icons.
  ///
  /// This constant defines the font family that Flutter should use when rendering
  /// these custom icons. It should match the font family name defined in pubspec.yaml.

  /// Icon representing a mosquito (bottom view).
  ///
  /// This icon shows a mosquito from the bottom perspective and is commonly
  /// used in entomology or insect-related contexts.
  static const IconData mosquitoB = IconData(0xe900, fontFamily: _fontFamily);

  /// Icon representing a mosquito (top view).
  ///
  /// This icon shows a mosquito from the top perspective and is commonly
  /// used in entomology or insect-related contexts.
  static const IconData mosquitoT = IconData(0xe901, fontFamily: _fontFamily);
}
