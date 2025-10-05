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
/// A comprehensive collection of custom icons from the Icomoon font package for CulicidaeLab.
///
/// This class provides static constant definitions for custom icons specifically
/// designed for the CulicidaeLab application. All icons are vector-based, scalable,
/// and optimized for the entomology and disease research domain.
///
/// ## Icon Design Philosophy
///
/// The custom icons in this collection are designed to:
/// - **Domain-Specific**: Represent mosquitoes and related concepts accurately
/// - **Scalable**: Work well at different sizes from 16px to 64px+
/// - **Consistent**: Maintain visual consistency with Material Design principles
/// - **Accessible**: Provide clear visual representation for all users
/// - **Professional**: Suitable for scientific and educational contexts
///
/// ## Font Configuration
///
/// To use these icons, ensure the Icomoon font is properly configured in `pubspec.yaml`:
///
/// ```yaml
/// flutter:
///   fonts:
///     - family: icomoon
///       fonts:
///         - asset: assets/fonts/icomoon.ttf
/// ```
///
/// ## Usage Examples
///
/// ```dart
/// // Basic icon usage
/// Icon(Icomoon.mosquitoB)
/// 
/// // Styled icon with size and color
/// Icon(
///   Icomoon.mosquitoT, 
///   size: 32.0, 
///   color: Colors.teal,
/// )
/// 
/// // In navigation or buttons
/// BottomNavigationBarItem(
///   icon: Icon(Icomoon.mosquitoB),
///   label: 'Gallery',
/// )
/// 
/// // As decorative elements
/// CircleAvatar(
///   backgroundColor: Colors.teal.shade100,
///   child: Icon(
///     Icomoon.mosquitoT,
///     color: Colors.teal.shade800,
///   ),
/// )
/// ```
///
/// ## Performance Considerations
///
/// - **Vector-based**: Icons scale without quality loss
/// - **Font-based**: Efficient rendering and caching
/// - **Single Font File**: Minimal app size impact
/// - **GPU Accelerated**: Smooth rendering on all devices
///
/// ## Accessibility
///
/// When using these icons, consider:
/// - Providing semantic labels for screen readers
/// - Ensuring sufficient color contrast
/// - Using appropriate sizes for touch targets
/// - Adding tooltips for icon-only buttons
///
/// See also:
/// - [IconData] for the underlying Flutter icon implementation
/// - Material Design icon guidelines
/// - Icomoon.io for icon font generation
/// {@endtemplate}
class Icomoon {
  /// Private constructor to prevent instantiation of this utility class.
  ///
  /// This class serves as a namespace for icon constants and should never
  /// be instantiated. All members are static constants.
  Icomoon._();

  /// The font family name used for all Icomoon icons.
  ///
  /// This constant defines the font family that Flutter should use when rendering
  /// these custom icons. It must match exactly the font family name defined in
  /// the `pubspec.yaml` file under the fonts section.
  ///
  /// **Important**: If this value doesn't match the pubspec.yaml configuration,
  /// the icons will not render correctly and may show as empty squares or
  /// fallback characters.
  static const String _fontFamily = 'icomoon';

  /// Icon representing a mosquito from the bottom/ventral view.
  ///
  /// This icon displays a mosquito as viewed from below, showing the ventral
  /// (bottom) anatomy. It's particularly useful for:
  /// - **Species Gallery**: Representing mosquito collections and browsing
  /// - **Navigation**: Bottom navigation bar icons for mosquito-related sections
  /// - **Cards and Lists**: Visual indicators for mosquito species entries
  /// - **Educational Content**: Illustrating mosquito anatomy and identification
  ///
  /// The icon is designed with scientific accuracy while maintaining visual
  /// clarity at various sizes. It works well in both light and dark themes.
  ///
  /// **Unicode**: U+E900
  /// **Recommended Sizes**: 16px - 48px for UI elements, up to 64px for headers
  /// **Color Compatibility**: Works with any color, recommended: teal, dark gray
  ///
  /// Example usage:
  /// ```dart
  /// // In navigation
  /// BottomNavigationBarItem(
  ///   icon: Icon(Icomoon.mosquitoB),
  ///   label: 'Gallery',
  /// )
  /// 
  /// // In species cards
  /// ListTile(
  ///   leading: Icon(Icomoon.mosquitoB, color: Colors.teal),
  ///   title: Text('Aedes aegypti'),
  /// )
  /// ```
  static const IconData mosquitoB = IconData(0xe900, fontFamily: _fontFamily);

  /// Icon representing a mosquito from the top/dorsal view.
  ///
  /// This icon displays a mosquito as viewed from above, showing the dorsal
  /// (top) anatomy with wings spread. It's particularly effective for:
  /// - **App Branding**: Logo and header elements
  /// - **Welcome Screens**: Large decorative icons on home/splash screens
  /// - **Classification Results**: Indicating successful species identification
  /// - **Scientific Illustrations**: Representing mosquito morphology
  ///
  /// The dorsal view provides a classic, recognizable mosquito silhouette
  /// that users immediately associate with the insect. The design emphasizes
  /// the characteristic wing structure and body proportions.
  ///
  /// **Unicode**: U+E901
  /// **Recommended Sizes**: 24px - 80px for prominent display elements
  /// **Color Compatibility**: Excellent with brand colors (teal) and neutral tones
  ///
  /// Example usage:
  /// ```dart
  /// // As app logo
  /// CircleAvatar(
  ///   radius: 50,
  ///   backgroundColor: Colors.teal.shade100,
  ///   child: Icon(
  ///     Icomoon.mosquitoT,
  ///     size: 60,
  ///     color: Colors.teal.shade800,
  ///   ),
  /// )
  /// 
  /// // In headers
  /// AppBar(
  ///   title: Row(
  ///     children: [
  ///       Icon(Icomoon.mosquitoT),
  ///       SizedBox(width: 8),
  ///       Text('CulicidaeLab'),
  ///     ],
  ///   ),
  /// )
  /// ```
  static const IconData mosquitoT = IconData(0xe901, fontFamily: _fontFamily);
}
