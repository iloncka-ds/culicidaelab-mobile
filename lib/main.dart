import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';
import 'widgets/custom_empty_widget.dart';
import 'widgets/icomoon_icons.dart';
import 'package:provider/provider.dart';

import 'package:flutter/foundation.dart'; // Needed for defaultTargetPlatform
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Needed for desktop factory
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

// Import app screens
import 'screens/classification_screen.dart';
import 'screens/mosquito_gallery_screen.dart';
import 'screens/disease_info_screen.dart';
import 'screens/webview_screen.dart'; // Import WebViewScreen
import 'models/mosquito_model.dart';
import 'services/classification_service.dart';
import 'services/database_service.dart';
import 'view_models/classification_view_model.dart';
import 'view_models/mosquito_gallery_view_model.dart';
import 'view_models/disease_info_view_model.dart';
import 'repositories/classification_repository.dart';
import 'repositories/mosquito_repository.dart';

// Add these imports for localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:culicidaelab/l10n/app_localizations.dart'; // Updated import path

// Import LocaleProvider
import 'providers/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  // Conditional initialization for different platforms
  // if (kIsWeb) {
  //   databaseFactory = databaseFactoryFfiWeb;
  //   print("Sqflite initialized for web using FFI Web.");
  // } else if (defaultTargetPlatform == TargetPlatform.windows ||
  //     defaultTargetPlatform == TargetPlatform.macOS ||
  //     defaultTargetPlatform == TargetPlatform.linux) {
  //   sqfliteFfiInit();
  //   databaseFactory = databaseFactoryFfi;
  //   print("Sqflite initialized for desktop using FFI.");
  // }
  runApp(const MosquitoClassifierApp());
}

class MosquitoClassifierApp extends StatelessWidget {
  const MosquitoClassifierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
        Provider<MosquitoRepository>(create: (_) => MosquitoRepository()),
        Provider<ClassificationRepository>(
          create:
              (context) => ClassificationRepository(
                mosquitoRepository: context.read<MosquitoRepository>(),
              ),
        ),
        ChangeNotifierProvider<ClassificationViewModel>(
          create:
              (context) => ClassificationViewModel(
                repository: context.read<ClassificationRepository>(),
              ),
        ),
        ChangeNotifierProvider<MosquitoGalleryViewModel>(
          create:
              (context) => MosquitoGalleryViewModel(
                repository: context.read<MosquitoRepository>(),
              ),
        ),
        ChangeNotifierProvider<DiseaseInfoViewModel>(
          create:
              (context) => DiseaseInfoViewModel(
                repository: context.read<MosquitoRepository>(),
              ),
        ),
      ],
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

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isModelLoaded = false;

  // Define your target URL for the mosquito activity map
  // Replace with your actual URL
  final String _mosquitoActivityMapUrl = "https://map.mosquitoalert.com/en";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadModel();
      }
    });
  }

  Future<void> _loadModel() async {
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    try {
      await Provider.of<ClassificationViewModel>(
        context,
        listen: false,
      ).initModel(localizations);
      if (mounted) {
        setState(() {
          _isModelLoaded = true;
        });
      }
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.homePageTitle),
        centerTitle: true,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: localizations.tooltipSelectLanguage,
            onSelected: (Locale newLocale) {
              localeProvider.setLocale(newLocale);
            },
            itemBuilder: (BuildContext context) {
              return localeProvider.supportedLocales.map((Locale locale) {
                return PopupMenuItem<Locale>(
                  value: locale,
                  child: Text(localeProvider.getLanguageName(locale, context)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icomoon.mosquitoT,
                    size: 80,
                    color: Colors.teal.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.homePageBannerTitle,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.homePageBannerSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 32),

            Column(
              children: [
                _buildNavigationButton(
                  icon: Icons.camera_alt,
                  title: localizations.classifyMosquitoButtonTitle,
                  subtitle: localizations.classifyMosquitoButtonSubtitle,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ClassificationScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  icon: Icomoon.mosquitoB,
                  title: localizations.mosquitoGalleryButtonTitle,
                  subtitle: localizations.mosquitoGalleryButtonSubtitle,
                  color: Color(0xFFF0BB78),
                  onTap: () {
                    final currentLocalizations = AppLocalizations.of(context)!;
                    Provider.of<MosquitoGalleryViewModel>(
                      context,
                      listen: false,
                    ).loadMosquitoSpecies(currentLocalizations);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MosquitoGalleryScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _buildNavigationButton(
                  icon: Icons.local_hospital,
                  title: localizations.diseasesInfoButtonTitle,
                  subtitle: localizations.diseasesInfoButtonSubtitle,
                  color: Color(0xFFF38C79),
                  onTap: () {
                    final currentLocalizations = AppLocalizations.of(context)!;
                    Provider.of<DiseaseInfoViewModel>(
                      context,
                      listen: false,
                    ).loadDiseases(currentLocalizations);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiseaseInfoScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16), // Added space
                _buildNavigationButton(
                  // New Card for WebView
                  icon: Icons.map_outlined,
                  title: localizations.homePageMosquitoActivityMapButtonTitle,
                  subtitle:
                      localizations.homePageMosquitoActivityMapButtonSubtitle,
                  color: Colors.blueAccent, // Different color for distinction
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => WebViewScreen(
                              title:
                                  localizations.webViewScreenTitleMosquitoMap,
                              url: _mosquitoActivityMapUrl,
                            ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
              ), // Relies on ListView's horizontal padding
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.5,
                  ), // Base style
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          localizations
                              .appDisclaimerTitle, // "Отказ от ответственности:" or "Disclaimer:"
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text:
                          ' ${localizations.appDisclaimerBody}', // The rest of the disclaimer text
                    ),
                  ],
                ),
              ),
            ),

            // Footer Section with Divider and Grant Info
            const SizedBox(height: 8), // Space before the divider
            const Divider(
              height:
                  20, // Total vertical space taken by divider (includes padding)
              thickness: 0.5,
              indent: 50, // Indentation from left
              endIndent: 50, // Indentation from right
              color: Colors.grey,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                8.0,
                0,
                16.0,
              ), // Top padding 8, bottom padding 16. Relies on ListView's horizontal padding.
              child: Linkify(
                onOpen: (link) async {
                  final uri = Uri.parse(link.url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    throw 'Could not launch $link';
                  }
                },
                text:
                    localizations.appFooterGrantInfo, // New key for grant info
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  height: 1.5,
                ),
                linkStyle: TextStyle(
                  color: Colors.teal.shade700,
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      Colors.teal.shade700, // Explicitly set underline color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _showModelLoadingDialog() {
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.loadingModelDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(localizations.loadingModelDialogContent),
            ],
          ),
        );
      },
    );
  }
}
