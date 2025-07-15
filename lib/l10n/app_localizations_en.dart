// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CulicidaeLab';

  @override
  String get homePageTitle => 'CulicidaeLab';

  @override
  String get homePageBannerTitle => 'Mosquito Classification';

  @override
  String get homePageBannerSubtitle => 'Identify mosquito species and learn about potential disease vectors';

  @override
  String get classifyMosquitoButtonTitle => 'Classify Mosquito';

  @override
  String get classifyMosquitoButtonSubtitle => 'Take or upload a photo for identification';

  @override
  String get mosquitoGalleryButtonTitle => 'Mosquito Gallery';

  @override
  String get mosquitoGalleryButtonSubtitle => 'Browse common mosquito species';

  @override
  String get diseasesInfoButtonTitle => 'Diseases Info';

  @override
  String get diseasesInfoButtonSubtitle => 'Learn about vector-borne diseases';

  @override
  String get appDisclaimerTitle => 'Disclaimer:';

  @override
  String get appDisclaimerBody => 'This platform is for educational and research purposes only. It does not replace professional medical advice or guidance from public health authorities.';

  @override
  String get appFooterGrantInfo => 'CulicidaeLab development is supported by a grant from the\nFoundation for Assistance to Small Innovative Enterprises (FASIE)\nhttps://fasie.ru';

  @override
  String get loadingModelDialogTitle => 'Loading Model';

  @override
  String get loadingModelDialogContent => 'Please wait while the classification model is loading...';

  @override
  String get classificationScreenTitle => 'Classify Mosquito';

  @override
  String get uploadImageHint => 'Upload a clear image of a mosquito for identification';

  @override
  String get uploadImageSubHint => 'Best results with well-lit, focused images';

  @override
  String speciesLabel(String speciesName) {
    return 'Species: $speciesName';
  }

  @override
  String commonNameLabel(String commonName) {
    return 'Common Name: $commonName';
  }

  @override
  String confidenceLabel(String confidenceValue) {
    return 'Confidence: $confidenceValue%';
  }

  @override
  String inferenceTimeLabel(int timeValue) {
    return 'Time: $timeValue ms';
  }

  @override
  String get speciesInfoButton => 'Species Info';

  @override
  String get diseaseRisksButton => 'Disease Risks';

  @override
  String get noKnownDiseaseRisks => 'No known disease risks for this species';

  @override
  String get potentialDiseaseRisksTitle => 'Potential Disease Risks';

  @override
  String get potentialDiseaseRisksSubtitle => 'This mosquito species is known to transmit the following diseases:';

  @override
  String get disclaimerEducationalUse => 'Disclaimer: This app provides information for educational purposes only. Always consult healthcare professionals for proper diagnosis and treatment.';

  @override
  String get cameraButtonLabel => 'Camera';

  @override
  String get galleryButtonLabel => 'Gallery';

  @override
  String get resetButtonLabel => 'Reset';

  @override
  String get analyzingImage => 'Analyzing image...';

  @override
  String get analyzeButton => 'Analyze';

  @override
  String get noImageSelectedTitle => 'No Image Selected';

  @override
  String get noImageSelectedSubtitle => 'Take a photo or select from gallery';

  @override
  String get unknownSpecies => 'Unknown';

  @override
  String errorFailedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get errorNoImageSelected => 'No image selected';

  @override
  String errorClassificationFailed(String error) {
    return 'Classification failed: $error';
  }

  @override
  String errorFailedToLoadModel(String error) {
    return 'Failed to load model: $error';
  }

  @override
  String get mosquitoGalleryScreenTitle => 'Mosquito Species Gallery';

  @override
  String get searchMosquitoSpeciesHint => 'Search mosquito species...';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get retryButton => 'Retry';

  @override
  String get noMosquitoSpeciesFound => 'No mosquito species found';

  @override
  String get tryDifferentSearchTerm => 'Try a different search term';

  @override
  String habitatLabel(String habitat) {
    return 'Habitat: $habitat';
  }

  @override
  String diseaseVectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count disease vectors',
      one: '1 disease vector',
      zero: 'No known disease vectors',
    );
    return '$_temp0';
  }

  @override
  String get noKnownDiseaseVectors => 'No known disease vectors';

  @override
  String get diseaseDetailScreenDescription => 'Description';

  @override
  String get diseaseDetailScreenSymptoms => 'Symptoms';

  @override
  String get diseaseDetailScreenTreatment => 'Treatment';

  @override
  String get diseaseDetailScreenPrevention => 'Prevention';

  @override
  String get diseaseDetailScreenPrevalence => 'Prevalence';

  @override
  String get diseaseDetailScreenTransmittedBy => 'Transmitted by';

  @override
  String get diseaseDetailScreenUnknownVector => 'Unknown Vector';

  @override
  String get diseaseDetailScreenInfoNotAvailable => 'Information not available.';

  @override
  String get diseaseDetailScreenVectorsNotAvailable => 'Information about vectors not available.';

  @override
  String get mosquitoDetailScreenDescription => 'Description';

  @override
  String get mosquitoDetailScreenHabitat => 'Habitat';

  @override
  String get mosquitoDetailScreenDistribution => 'Distribution';

  @override
  String get mosquitoDetailScreenAssociatedDiseases => 'Associated Diseases';

  @override
  String get mosquitoDetailScreenNoAssociatedDiseases => 'No known diseases associated with this species in our database.';

  @override
  String get diseaseInfoScreenTitle => 'Mosquito-borne Diseases';

  @override
  String get searchDiseasesHint => 'Search diseases...';

  @override
  String get noDiseasesFound => 'No diseases found';

  @override
  String vectorsLabel(String vectors) {
    return 'Vectors: $vectors';
  }

  @override
  String prevalenceLabel(String prevalence) {
    return 'Prevalence: $prevalence';
  }

  @override
  String get classificationServiceUnknownSpeciesCommonName => 'Unknown Species';

  @override
  String get classificationServiceUnknownSpeciesDescription => 'No detailed information available for this species.';

  @override
  String get classificationServiceUnknownSpeciesHabitat => 'Unknown';

  @override
  String get classificationServiceUnknownSpeciesDistribution => 'Unknown';

  @override
  String get classificationServiceErrorModelNotLoaded => 'Model not loaded';

  @override
  String get classificationServiceErrorModelLoadingFailed => 'Model loading failed - only supported for Android/iOS';

  @override
  String viewModelErrorFailedToLoadDiseases(String error) {
    return 'Failed to load diseases: $error';
  }

  @override
  String viewModelErrorFailedToLoadDisease(String error) {
    return 'Failed to load disease: $error';
  }

  @override
  String viewModelErrorFailedToLoadDiseasesForVector(String error) {
    return 'Failed to load diseases for vector: $error';
  }

  @override
  String viewModelErrorFailedToLoadMosquitoSpecies(String error) {
    return 'Failed to load mosquito species: $error';
  }

  @override
  String get homePageMosquitoActivityMapButtonTitle => 'Mosquito Activity Map';

  @override
  String get homePageMosquitoActivityMapButtonSubtitle => 'View interactive map of mosquito reports';

  @override
  String get webViewScreenTitleMosquitoMap => 'Mosquito Activity Map';

  @override
  String get webViewFailedToLoad => 'Failed to load page';

  @override
  String get webViewRetryButton => 'Retry';

  @override
  String get tooltipSelectLanguage => 'Select language';

  @override
  String get addDetailsButton => 'Add Observation Details';

  @override
  String get thankYouForParticipation => 'Thank you for your contribution!';

  @override
  String submissionIdLabel(String id) {
    return 'Submission ID: $id';
  }

  @override
  String errorSubmissionFailed(String error) {
    return 'Submission Failed: $error';
  }

  @override
  String get observationDetailsTitle => 'Observation Details';

  @override
  String get locationSectionTitle => 'Observation Location';

  @override
  String get locationInstruction => 'Tap on the map to mark the exact location of your observation.';

  @override
  String get fieldRequiredError => 'This field is required';

  @override
  String get locationRequiredError => 'Please select a location on the map.';

  @override
  String get notesLabel => 'Notes';

  @override
  String get notesHint => 'Add any relevant details (e.g., time of day, weather, environment)...';

  @override
  String get submitObservationButton => 'Submit Observation';

  @override
  String get predictionSummaryTitle => 'Prediction Summary';

  @override
  String get latitudeLabel => 'Latitude';

  @override
  String get longitudeLabel => 'Longitude';
}
