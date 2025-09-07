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




Future<void> main()  async{
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const MosquitoClassifierApp());
}

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
