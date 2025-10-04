/// Main entry point for the CulicidaeLab mobile application.
///
/// This file contains the root widget and main application configuration
/// for the mosquito classification and information app. It handles:
/// - Application initialization and dependency injection setup
/// - Multi-language support through localization
/// - Main app theme and navigation structure
/// - Home screen with feature navigation buttons
/// - Integration with various screens (classification, gallery, disease info, map)
///
/// The app uses Provider for state management and supports multiple locales
/// including English and Spanish.

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/icomoon_icons.dart';
import 'package:provider/provider.dart';
import 'providers/locale_provider.dart';

// Import app screens
import 'screens/classification_screen.dart';
import 'screens/mosquito_gallery_screen.dart';
import 'screens/disease_info_screen.dart';
import 'screens/webview_screen.dart';
import 'screens/home_screen.dart';
import 'view_models/classification_view_model.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';




/// The main entry point of the CulicidaeLab application.
///
/// Initializes Flutter bindings, sets up dependency injection through the locator,
/// and starts the application with the root widget [MosquitoClassifierApp].
/// This function ensures all necessary services are initialized before the UI loads.
Future<void> main()  async{

  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MosquitoClassifierApp());
}

/// Root widget for the CulicidaeLab application.
///
/// This stateless widget serves as the main application widget that configures
/// the overall app behavior including theming, localization, and routing.
/// It provides the [MaterialApp] with proper locale support and sets up
/// the home page navigation structure.
///
/// Key features:
/// - Multi-language support through [LocaleProvider]
/// - Consistent teal-based theming
/// - Integration with localization delegates
/// - Navigation to the main [HomePage]
class MosquitoClassifierApp extends StatelessWidget {
  const MosquitoClassifierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleProvider>.value(
      value: locator<LocaleProvider>()..init(),
      child: Consumer<LocaleProvider>(
        builder: (context, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle:
                (BuildContext context) =>
                    AppLocalizations.of(context)!.appTitle,
            theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: const AppBarTheme(
                elevation: 0,
                backgroundColor: Colors.teal,
                iconTheme: IconThemeData(color: Colors.white),
                titleTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
