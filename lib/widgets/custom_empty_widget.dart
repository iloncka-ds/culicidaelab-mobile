import 'package:flutter/material.dart';

/// {@template custom_empty_widget}
/// A custom implementation of an empty state widget that uses the updated TextTheme API.
///
/// This widget displays an empty state with optional image, title, and subtitle.
/// It provides flexibility to customize the appearance and content according to
/// different use cases in the application.
///
/// Example usage:
/// ```dart
/// CustomEmptyWidget(
///   title: 'No items found',
///   subtitle: 'Try adjusting your search criteria',
///   image: 'assets/images/empty_state.png',
/// )
/// ```
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
/// A helper class that provides utility functions for the [CustomEmptyWidget].
///
/// This class contains static methods that assist in styling and theme management
/// for empty state widgets throughout the application.
/// {@endtemplate}
class CustomEmptyWidgetHelper {
  /// Gets the font size from the current theme's body medium text style.
  ///
  /// This method retrieves the font size value from [Theme.of(context).textTheme.bodyMedium]
  /// which can be useful for maintaining consistent typography across the application.
  ///
  /// Returns the font size as a double, or null if the theme doesn't specify one.
  static double? getFontSize(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.fontSize!;
  }
}