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
import 'view_models/classification_view_model.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';

/// The main home page of the CulicidaeLab application.
///
/// This stateful widget represents the primary interface that users see when
/// opening the app. It provides a tabbed interface with five main sections:
/// - Home: Welcome screen with feature overview
/// - Classification: Camera-based mosquito identification
/// - Gallery: Mosquito species information
/// - Diseases: Disease information related to mosquitoes
/// - Map: Interactive mosquito activity map
///
/// The widget manages navigation state and handles initial model loading
/// for the classification feature. It also provides language selection
/// through the app bar.
///
/// Key features:
/// - Bottom navigation bar for section switching
/// - Language selection menu in app bar
/// - Automatic model initialization on startup
/// - Responsive design with gradient background
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final String _mosquitoActivityMapUrl = "https://culicidealab.ru/map";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadModel();
      }
    });
  }

/// Asynchronously loads the mosquito classification model.
///
/// This method initializes the classification view model with the current
/// localizations context. The model loading is performed asynchronously
/// to avoid blocking the UI thread. Any errors during model loading
/// are caught and logged to the console.
///
/// Throws:
/// - Exceptions from [ClassificationViewModel.initModel] if model loading fails
  Future<void> _loadModel() async {
    if (!mounted) return;
    final localizations = AppLocalizations.of(context)!;
    try {
      await locator<ClassificationViewModel>().initModel(localizations);
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    final List<Widget> _widgetOptions = <Widget>[
      _buildHomeScreen(localizations),
      const ClassificationScreen(),
      const MosquitoGalleryScreen(),
      const DiseaseInfoScreen(),
      WebViewScreen(
        title: localizations.webViewScreenTitleMosquitoMap,
        url: _mosquitoActivityMapUrl,
      ),
    ];

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
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home,  key: const Key('bottom_nav_home')),
            label: localizations.homePageTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt,  key: const Key('bottom_nav_camera')),
            label: localizations.classifyMosquitoButtonTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icomoon.mosquitoB,  key: const Key('bottom_nav_mosquito')),
            label: localizations.mosquitoGalleryButtonTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.local_hospital,  key: const Key('bottom_nav_hospital')),
            label: localizations.diseasesInfoButtonTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined,  key: const Key('bottom_nav_map')),
            label: localizations.homePageMosquitoActivityMapButtonTitle,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }

/// Builds the welcome screen UI for the home tab.
///
/// Creates a scrollable list view with a gradient background containing:
/// - App logo/title section with mosquito icon
/// - Navigation buttons for each main feature
/// - Disclaimer text and footer information
/// - Interactive links for grant information
///
/// Parameters:
/// - [localizations]: The current app localizations for text content
///
/// Returns:
///   A [Container] widget with gradient background and scrollable content
  Widget _buildHomeScreen(AppLocalizations localizations) {
    return Container(
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
                  _onItemTapped(1);
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: Icomoon.mosquitoB,
                title: localizations.mosquitoGalleryButtonTitle,
                subtitle: localizations.mosquitoGalleryButtonSubtitle,
                color: const Color(0xFFF0BB78),
                onTap: () {
                  _onItemTapped(2);
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: Icons.local_hospital,
                title: localizations.diseasesInfoButtonTitle,
                subtitle: localizations.diseasesInfoButtonSubtitle,
                color: const Color(0xFFF38C79),
                onTap: () {
                  _onItemTapped(3);
                },
              ),
              const SizedBox(height: 16),
              _buildNavigationButton(
                icon: Icons.map_outlined,
                title: localizations.homePageMosquitoActivityMapButtonTitle,
                subtitle:
                    localizations.homePageMosquitoActivityMapButtonSubtitle,
                color: Colors.blueAccent,
                onTap: () {
                  _onItemTapped(4);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
            ),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: localizations.appDisclaimerTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' ${localizations.appDisclaimerBody}',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(
            height: 20,
            thickness: 0.5,
            indent: 50,
            endIndent: 50,
            color: Colors.grey,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              0,
              8.0,
              0,
              16.0,
            ),
            child: Linkify(
              onOpen: (link) async {
                final uri = Uri.parse(link.url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                } else {
                  throw 'Could not launch $link';
                }
              },
              text: localizations.appFooterGrantInfo,
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
                decorationColor: Colors.teal.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

/// Builds a styled navigation button for feature sections.
///
/// Creates a Material Design card with elevation and rounded corners
/// containing an icon, title, subtitle, and arrow indicator. The button
/// responds to tap gestures and provides visual feedback.
///
/// Parameters:
/// - [icon]: The icon to display in the button
/// - [title]: The main text title of the button
/// - [subtitle]: The descriptive subtitle text
/// - [color]: The theme color for the button styling
/// - [onTap]: The callback function to execute when tapped
///
/// Returns:
///   A [Material] widget with [InkWell] for tap detection and styling
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
