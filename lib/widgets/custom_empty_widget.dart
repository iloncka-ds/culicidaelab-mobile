import 'package:flutter/material.dart';

/// {@template custom_empty_widget}
/// A highly customizable empty state widget for displaying "no content" scenarios.
///
/// This widget provides a flexible solution for showing empty states throughout
/// the CulicidaeLab application. It supports various customization options including
/// custom images, text styling, and complete widget replacement for maximum flexibility.
///
/// ## Design Philosophy
///
/// Empty states are crucial for user experience as they:
/// - Provide clear feedback when no content is available
/// - Guide users on what actions they can take
/// - Maintain visual consistency across the application
/// - Prevent confusion and improve usability
///
/// ## Usage Scenarios
///
/// - **Search Results**: When no mosquito species match search criteria
/// - **Gallery Loading**: While species data is being fetched
/// - **Classification**: When no image has been selected yet
/// - **Disease Information**: When no diseases are associated with a species
/// - **Network Errors**: When data cannot be loaded from remote sources
///
/// ## Customization Options
///
/// The widget supports multiple levels of customization:
/// - **Standard**: Use predefined image, title, and subtitle
/// - **Styled**: Apply custom text styles and formatting
/// - **Widget-based**: Replace image with custom widget (icons, illustrations)
/// - **Complete Override**: Use entirely custom widget for unique layouts
///
/// ## Example Usage
///
/// ```dart
/// // Basic usage with text only
/// CustomEmptyWidget(
///   title: 'No mosquito species found',
///   subtitle: 'Try adjusting your search criteria',
/// )
///
/// // With custom image and styling
/// CustomEmptyWidget(
///   title: 'No classification results',
///   subtitle: 'Please select an image to analyze',
///   image: 'assets/images/empty_classification.png',
///   titleTextStyle: TextStyle(fontSize: 20, color: Colors.teal),
/// )
///
/// // With custom icon widget
/// CustomEmptyWidget(
///   title: 'No diseases found',
///   imageWidget: Icon(Icons.health_and_safety, size: 64, color: Colors.grey),
/// )
/// ```
///
/// ## Accessibility
///
/// The widget follows accessibility best practices:
/// - Proper semantic structure for screen readers
/// - Sufficient color contrast for text elements
/// - Scalable text that respects user font size preferences
/// - Meaningful content descriptions
///
/// See also:
/// - [CustomEmptyWidgetHelper] for utility functions
/// - Material Design guidelines for empty states
/// {@endtemplate}
class CustomEmptyWidget extends StatelessWidget {
  /// The title text to display in the empty state.
  ///
  /// If null, no title will be shown unless [hideTitle] is false.
  final String? title;

  /// The subtitle text to display in the empty state.
  ///
  /// If null, no subtitle will be shown unless [hideSubTitle] is false.
  final String? subtitle;

  /// The path to the image asset to display in the empty state.
  ///
  /// This should be a path to an image file in your assets folder.
  /// If null, no image will be shown unless [imageWidget] is provided.
  final String? image;

  /// The package name if the image is from a package.
  ///
  /// This is used when the image asset is defined in a different package.
  /// Leave null if the image is from the current package's assets.
  final String? packageImage;

  /// A custom widget to display instead of the default content.
  ///
  /// When provided, this widget will be displayed instead of the standard
  /// image, title, and subtitle layout. This allows for complete customization
  /// of the empty state appearance.
  final Widget? customWidget;

  /// A custom widget to display in place of the default image.
  ///
  /// When provided, this widget will be used instead of loading an image
  /// from [image] or [packageImage]. This allows for custom illustrations
  /// or icons to be displayed.
  final Widget? imageWidget;

  /// Whether to hide the title text.
  ///
  /// When true, the title will not be displayed even if [title] is provided.
  /// Defaults to false.
  final bool hideTitle;

  /// Whether to hide the subtitle text.
  ///
  /// When true, the subtitle will not be displayed even if [subtitle] is provided.
  /// Defaults to false.
  final bool hideSubTitle;

  /// The text style to apply to the title text.
  ///
  /// If null, the default style will be used which applies
  /// [Theme.of(context).textTheme.headlineSmall] with bold weight and black color.
  final TextStyle? titleTextStyle;

  /// The text style to apply to the subtitle text.
  ///
  /// If null, the default style will be used which applies
  /// [Theme.of(context).textTheme.bodyMedium] with black color.
  final TextStyle? subtitleTextStyle;

/// {@macro custom_empty_widget}
  const CustomEmptyWidget({
    Key? key,
    this.title,
    this.subtitle,
    this.image,
    this.packageImage,
    this.customWidget,
    this.imageWidget,
    this.hideTitle = false,
    this.hideSubTitle = false,
    this.titleTextStyle,
    this.subtitleTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (customWidget != null) {
      return customWidget!;
    }

    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Image or image widget
          if (imageWidget != null) imageWidget!,
          if (imageWidget == null && image != null)
            packageImage != null
                ? Image.asset(
                    image!,
                    package: packageImage,
                    width: 230,
                    height: 230,
                  )
                : Image.asset(
                    image!,
                    width: 230,
                    height: 230,
                  ),

          // Title
          if (!hideTitle && title != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: titleTextStyle ??
                    Theme.of(context).textTheme.headlineSmall!.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
              ),
            ),

          // Subtitle
          if (!hideSubTitle && subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: subtitleTextStyle ??
                    Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black,
                        ),
              ),
            ),
        ],
      ),
    );
  }
}

/// {@template custom_empty_widget_helper}
/// A utility class providing helper functions for [CustomEmptyWidget] styling and theming.
///
/// This class contains static methods that assist in maintaining consistent
/// typography and styling across empty state widgets throughout the CulicidaeLab
/// application. It helps ensure visual consistency and proper theme integration.
///
/// ## Purpose
///
/// - **Typography Consistency**: Standardize font sizes across empty states
/// - **Theme Integration**: Ensure empty states respect app-wide theme settings
/// - **Accessibility Support**: Provide font sizes that scale with user preferences
/// - **Maintenance**: Centralize styling logic for easier updates
///
/// ## Usage Example
///
/// ```dart
/// final fontSize = CustomEmptyWidgetHelper.getFontSize(context);
/// final customStyle = TextStyle(
///   fontSize: fontSize,
///   color: Colors.grey.shade600,
/// );
/// 
/// CustomEmptyWidget(
///   title: 'No results',
///   titleTextStyle: customStyle,
/// )
/// ```
/// {@endtemplate}
class CustomEmptyWidgetHelper {
  /// Prevents instantiation of this utility class.
  CustomEmptyWidgetHelper._();

  /// Retrieves the font size from the current theme's body medium text style.
  ///
  /// This method extracts the font size value from the app's current theme,
  /// specifically from [Theme.of(context).textTheme.bodyMedium]. This ensures
  /// that empty state widgets use consistent typography that matches the
  /// overall application design.
  ///
  /// ## Theme Integration
  ///
  /// The method respects:
  /// - **System Font Scaling**: Adapts to user's accessibility font size settings
  /// - **App Theme**: Uses the application's defined text theme
  /// - **Material Design**: Follows Material Design typography guidelines
  /// - **Platform Conventions**: Respects platform-specific text sizing
  ///
  /// ## Return Value
  ///
  /// Returns the font size as a [double], or null if the theme doesn't specify
  /// a font size for the body medium text style. In practice, this should
  /// rarely be null as Material themes provide default values.
  ///
  /// [context] The build context to access the current theme.
  ///
  /// Example:
  /// ```dart
  /// final fontSize = CustomEmptyWidgetHelper.getFontSize(context);
  /// if (fontSize != null) {
  ///   // Use the theme-consistent font size
  ///   print('Using font size: $fontSize');
  /// }
  /// ```
  static double? getFontSize(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.fontSize;
  }
}