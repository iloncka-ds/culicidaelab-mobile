import 'package:flutter/material.dart';

/// A custom implementation of the empty_widget package that uses the updated TextTheme API
class CustomEmptyWidget extends StatelessWidget {
  /// Title displayed in the empty widget
  final String? title;

  /// Subtitle displayed in the empty widget
  final String? subtitle;

  /// Image path to display
  final String? image;

  /// Package name if the image is from a package
  final String? packageImage;

  /// Custom widget to display instead of the default content
  final Widget? customWidget;

  /// Widget to display in place of the image
  final Widget? imageWidget;

  /// Hide the title
  final bool hideTitle;

  /// Hide the subtitle
  final bool hideSubTitle;

  /// Title text style
  final TextStyle? titleTextStyle;

  /// Subtitle text style
  final TextStyle? subtitleTextStyle;

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

/// Helper class for the CustomEmptyWidget
class CustomEmptyWidgetHelper {
  /// Get the font size from the theme
  static double? getFontSize(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.fontSize!;
  }
}