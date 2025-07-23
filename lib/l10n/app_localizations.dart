import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru')
  ];

  /// The main title of the application
  ///
  /// In en, this message translates to:
  /// **'CulicidaeLab'**
  String get appTitle;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'CulicidaeLab'**
  String get homePageTitle;

  /// No description provided for @homePageBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Classification'**
  String get homePageBannerTitle;

  /// No description provided for @homePageBannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Identify mosquito species and learn about potential disease vectors'**
  String get homePageBannerSubtitle;

  /// No description provided for @classifyMosquitoButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Classify Mosquito'**
  String get classifyMosquitoButtonTitle;

  /// No description provided for @classifyMosquitoButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take or upload a photo for identification'**
  String get classifyMosquitoButtonSubtitle;

  /// No description provided for @mosquitoGalleryButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Gallery'**
  String get mosquitoGalleryButtonTitle;

  /// No description provided for @mosquitoGalleryButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse common mosquito species'**
  String get mosquitoGalleryButtonSubtitle;

  /// No description provided for @diseasesInfoButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Diseases Info'**
  String get diseasesInfoButtonTitle;

  /// No description provided for @diseasesInfoButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn about vector-borne diseases'**
  String get diseasesInfoButtonSubtitle;

  /// Title for the disclaimer section
  ///
  /// In en, this message translates to:
  /// **'Disclaimer:'**
  String get appDisclaimerTitle;

  /// Main text for the disclaimer section
  ///
  /// In en, this message translates to:
  /// **'This platform is for educational and research purposes only. It does not replace professional medical advice or guidance from public health authorities.'**
  String get appDisclaimerBody;

  /// Grant information for the app footer, includes a link
  ///
  /// In en, this message translates to:
  /// **'CulicidaeLab development is supported by a grant from the\nFoundation for Assistance to Small Innovative Enterprises (FASIE)\nhttps://fasie.ru'**
  String get appFooterGrantInfo;

  /// No description provided for @loadingModelDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading Model'**
  String get loadingModelDialogTitle;

  /// No description provided for @loadingModelDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Please wait while the classification model is loading...'**
  String get loadingModelDialogContent;

  /// No description provided for @classificationScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Classify Mosquito'**
  String get classificationScreenTitle;

  /// No description provided for @uploadImageHint.
  ///
  /// In en, this message translates to:
  /// **'Upload a clear image of a mosquito for identification'**
  String get uploadImageHint;

  /// No description provided for @uploadImageSubHint.
  ///
  /// In en, this message translates to:
  /// **'Best results with well-lit, focused images'**
  String get uploadImageSubHint;

  /// No description provided for @speciesLabel.
  ///
  /// In en, this message translates to:
  /// **'Species: {speciesName}'**
  String speciesLabel(String speciesName);

  /// No description provided for @commonNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Common Name: {commonName}'**
  String commonNameLabel(String commonName);

  /// No description provided for @confidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidenceValue}%'**
  String confidenceLabel(String confidenceValue);

  /// No description provided for @inferenceTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time: {timeValue} ms'**
  String inferenceTimeLabel(int timeValue);

  /// No description provided for @speciesInfoButton.
  ///
  /// In en, this message translates to:
  /// **'Species Info'**
  String get speciesInfoButton;

  /// No description provided for @diseaseRisksButton.
  ///
  /// In en, this message translates to:
  /// **'Disease Risks'**
  String get diseaseRisksButton;

  /// No description provided for @noKnownDiseaseRisks.
  ///
  /// In en, this message translates to:
  /// **'No known disease risks for this species'**
  String get noKnownDiseaseRisks;

  /// No description provided for @potentialDiseaseRisksTitle.
  ///
  /// In en, this message translates to:
  /// **'Potential Disease Risks'**
  String get potentialDiseaseRisksTitle;

  /// No description provided for @potentialDiseaseRisksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This mosquito species is known to transmit the following diseases:'**
  String get potentialDiseaseRisksSubtitle;

  /// No description provided for @disclaimerEducationalUse.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: This app provides information for educational purposes only. Always consult healthcare professionals for proper diagnosis and treatment.'**
  String get disclaimerEducationalUse;

  /// No description provided for @cameraButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get cameraButtonLabel;

  /// No description provided for @galleryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get galleryButtonLabel;

  /// No description provided for @resetButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetButtonLabel;

  /// No description provided for @analyzingImage.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get analyzingImage;

  /// No description provided for @analyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeButton;

  /// No description provided for @noImageSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'No Image Selected'**
  String get noImageSelectedTitle;

  /// No description provided for @noImageSelectedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or select from gallery'**
  String get noImageSelectedSubtitle;

  /// No description provided for @unknownSpecies.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownSpecies;

  /// No description provided for @errorFailedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String errorFailedToPickImage(String error);

  /// No description provided for @errorNoImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get errorNoImageSelected;

  /// No description provided for @errorClassificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Classification failed: {error}'**
  String errorClassificationFailed(String error);

  /// No description provided for @errorFailedToLoadModel.
  ///
  /// In en, this message translates to:
  /// **'Failed to load model: {error}'**
  String errorFailedToLoadModel(String error);

  /// No description provided for @mosquitoGalleryScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Species Gallery'**
  String get mosquitoGalleryScreenTitle;

  /// No description provided for @searchMosquitoSpeciesHint.
  ///
  /// In en, this message translates to:
  /// **'Search mosquito species...'**
  String get searchMosquitoSpeciesHint;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @noMosquitoSpeciesFound.
  ///
  /// In en, this message translates to:
  /// **'No mosquito species found'**
  String get noMosquitoSpeciesFound;

  /// No description provided for @tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// No description provided for @habitatLabel.
  ///
  /// In en, this message translates to:
  /// **'Habitat: {habitat}'**
  String habitatLabel(String habitat);

  /// No description provided for @diseaseVectorsCount.
  ///
  /// In en, this message translates to:
  /// **'{count,plural, =0{No known disease vectors} =1{1 disease vector} other{{count} disease vectors}}'**
  String diseaseVectorsCount(int count);

  /// No description provided for @noKnownDiseaseVectors.
  ///
  /// In en, this message translates to:
  /// **'No known disease vectors'**
  String get noKnownDiseaseVectors;

  /// No description provided for @diseaseDetailScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get diseaseDetailScreenDescription;

  /// No description provided for @diseaseDetailScreenSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get diseaseDetailScreenSymptoms;

  /// No description provided for @diseaseDetailScreenTreatment.
  ///
  /// In en, this message translates to:
  /// **'Treatment'**
  String get diseaseDetailScreenTreatment;

  /// No description provided for @diseaseDetailScreenPrevention.
  ///
  /// In en, this message translates to:
  /// **'Prevention'**
  String get diseaseDetailScreenPrevention;

  /// No description provided for @diseaseDetailScreenPrevalence.
  ///
  /// In en, this message translates to:
  /// **'Prevalence'**
  String get diseaseDetailScreenPrevalence;

  /// No description provided for @diseaseDetailScreenTransmittedBy.
  ///
  /// In en, this message translates to:
  /// **'Transmitted by'**
  String get diseaseDetailScreenTransmittedBy;

  /// No description provided for @diseaseDetailScreenUnknownVector.
  ///
  /// In en, this message translates to:
  /// **'Unknown Vector'**
  String get diseaseDetailScreenUnknownVector;

  /// No description provided for @diseaseDetailScreenInfoNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Information not available.'**
  String get diseaseDetailScreenInfoNotAvailable;

  /// No description provided for @diseaseDetailScreenVectorsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Information about vectors not available.'**
  String get diseaseDetailScreenVectorsNotAvailable;

  /// No description provided for @mosquitoDetailScreenDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get mosquitoDetailScreenDescription;

  /// No description provided for @mosquitoDetailScreenHabitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get mosquitoDetailScreenHabitat;

  /// No description provided for @mosquitoDetailScreenDistribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get mosquitoDetailScreenDistribution;

  /// No description provided for @mosquitoDetailScreenAssociatedDiseases.
  ///
  /// In en, this message translates to:
  /// **'Associated Diseases'**
  String get mosquitoDetailScreenAssociatedDiseases;

  /// No description provided for @mosquitoDetailScreenNoAssociatedDiseases.
  ///
  /// In en, this message translates to:
  /// **'No known diseases associated with this species in our database.'**
  String get mosquitoDetailScreenNoAssociatedDiseases;

  /// No description provided for @diseaseInfoScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosquito-borne Diseases'**
  String get diseaseInfoScreenTitle;

  /// No description provided for @searchDiseasesHint.
  ///
  /// In en, this message translates to:
  /// **'Search diseases...'**
  String get searchDiseasesHint;

  /// No description provided for @noDiseasesFound.
  ///
  /// In en, this message translates to:
  /// **'No diseases found'**
  String get noDiseasesFound;

  /// No description provided for @vectorsLabel.
  ///
  /// In en, this message translates to:
  /// **'Vectors: {vectors}'**
  String vectorsLabel(String vectors);

  /// No description provided for @prevalenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Prevalence: {prevalence}'**
  String prevalenceLabel(String prevalence);

  /// No description provided for @classificationServiceUnknownSpeciesCommonName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Species'**
  String get classificationServiceUnknownSpeciesCommonName;

  /// No description provided for @classificationServiceUnknownSpeciesDescription.
  ///
  /// In en, this message translates to:
  /// **'No detailed information available for this species.'**
  String get classificationServiceUnknownSpeciesDescription;

  /// No description provided for @classificationServiceUnknownSpeciesHabitat.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get classificationServiceUnknownSpeciesHabitat;

  /// No description provided for @classificationServiceUnknownSpeciesDistribution.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get classificationServiceUnknownSpeciesDistribution;

  /// No description provided for @classificationServiceErrorModelNotLoaded.
  ///
  /// In en, this message translates to:
  /// **'Model not loaded'**
  String get classificationServiceErrorModelNotLoaded;

  /// No description provided for @classificationServiceErrorModelLoadingFailed.
  ///
  /// In en, this message translates to:
  /// **'Model loading failed - only supported for Android/iOS'**
  String get classificationServiceErrorModelLoadingFailed;

  /// No description provided for @viewModelErrorFailedToLoadDiseases.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diseases: {error}'**
  String viewModelErrorFailedToLoadDiseases(String error);

  /// No description provided for @viewModelErrorFailedToLoadDisease.
  ///
  /// In en, this message translates to:
  /// **'Failed to load disease: {error}'**
  String viewModelErrorFailedToLoadDisease(String error);

  /// No description provided for @viewModelErrorFailedToLoadDiseasesForVector.
  ///
  /// In en, this message translates to:
  /// **'Failed to load diseases for vector: {error}'**
  String viewModelErrorFailedToLoadDiseasesForVector(String error);

  /// No description provided for @viewModelErrorFailedToLoadMosquitoSpecies.
  ///
  /// In en, this message translates to:
  /// **'Failed to load mosquito species: {error}'**
  String viewModelErrorFailedToLoadMosquitoSpecies(String error);

  /// No description provided for @homePageMosquitoActivityMapButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Activity Map'**
  String get homePageMosquitoActivityMapButtonTitle;

  /// No description provided for @homePageMosquitoActivityMapButtonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View interactive map of mosquito reports'**
  String get homePageMosquitoActivityMapButtonSubtitle;

  /// No description provided for @webViewScreenTitleMosquitoMap.
  ///
  /// In en, this message translates to:
  /// **'Mosquito Activity Map'**
  String get webViewScreenTitleMosquitoMap;

  /// No description provided for @webViewFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load page'**
  String get webViewFailedToLoad;

  /// No description provided for @webViewRetryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get webViewRetryButton;

  /// No description provided for @tooltipSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get tooltipSelectLanguage;

  /// No description provided for @addDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Add Observation Details'**
  String get addDetailsButton;

  /// No description provided for @thankYouForParticipation.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your contribution!'**
  String get thankYouForParticipation;

  /// Label showing the ID of the submitted observation.
  ///
  /// In en, this message translates to:
  /// **'Submission ID: {id}'**
  String submissionIdLabel(String id);

  /// Error message when submission fails.
  ///
  /// In en, this message translates to:
  /// **'Submission Failed: {error}'**
  String errorSubmissionFailed(String error);

  /// No description provided for @observationDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation Details'**
  String get observationDetailsTitle;

  /// No description provided for @locationSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Observation Location'**
  String get locationSectionTitle;

  /// No description provided for @locationInstruction.
  ///
  /// In en, this message translates to:
  /// **'Tap on the map to mark the exact location of your observation.'**
  String get locationInstruction;

  /// No description provided for @fieldRequiredError.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequiredError;

  /// No description provided for @locationRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Please select a location on the map.'**
  String get locationRequiredError;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Add any relevant details (e.g., time of day, weather, environment)...'**
  String get notesHint;

  /// No description provided for @submitObservationButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Observation'**
  String get submitObservationButton;

  /// No description provided for @predictionSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Prediction Summary'**
  String get predictionSummaryTitle;

  /// No description provided for @latitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitudeLabel;

  /// No description provided for @longitudeLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitudeLabel;

  /// No description provided for @submittingObservation.
  ///
  /// In en, this message translates to:
  /// **'Submitting Observation...'**
  String get submittingObservation;

  /// No description provided for @fetchingWebPrediction.
  ///
  /// In en, this message translates to:
  /// **'Fetching Web Prediction...'**
  String get fetchingWebPrediction;

  /// No description provided for @errorFailedWebPrediction.
  ///
  /// In en, this message translates to:
  /// **'Failed to get web prediction. Please try again.'**
  String get errorFailedWebPrediction;

  /// No description provided for @speciesNotDefinedWebPrediction.
  ///
  /// In en, this message translates to:
  /// **'Species not defined'**
  String get speciesNotDefinedWebPrediction;

  /// No description provided for @retryButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButtonLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
