// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'CulicidaeLab';

  @override
  String get homePageTitle => 'CulicidaeLab';

  @override
  String get homePageBannerTitle => 'Clasificación de Mosquitos';

  @override
  String get homePageBannerSubtitle => 'Identifica especies de mosquitos y aprende sobre posibles vectores de enfermedades';

  @override
  String get classifyMosquitoButtonTitle => 'Clasificar Mosquito';

  @override
  String get classifyMosquitoButtonSubtitle => 'Toma o sube una foto para identificación';

  @override
  String get mosquitoGalleryButtonTitle => 'Galería de Mosquitos';

  @override
  String get mosquitoGalleryButtonSubtitle => 'Explora especies comunes de mosquitos';

  @override
  String get diseasesInfoButtonTitle => 'Información de Enfermedades';

  @override
  String get diseasesInfoButtonSubtitle => 'Aprende sobre enfermedades transmitidas por vectores';

  @override
  String get appDisclaimerTitle => 'Descargo de responsabilidad:';

  @override
  String get appDisclaimerBody => 'Esta plataforma es únicamente para fines educativos y de investigación. No reemplaza el asesoramiento médico profesional ni la orientación de las autoridades de salud pública.';

  @override
  String get appFooterGrantInfo => 'El desarrollo de CulicidaeLab cuenta con el apoyo de una subvención de la\nFundación para la Asistencia a Pequeñas Empresas Innovadoras (FASIE)\nhttps://fasie.ru';

  @override
  String get loadingModelDialogTitle => 'Cargando Modelo';

  @override
  String get loadingModelDialogContent => 'Por favor espera mientras se carga el modelo de clasificación...';

  @override
  String get classificationScreenTitle => 'Clasificar Mosquito';

  @override
  String get uploadImageHint => 'Sube una imagen clara de un mosquito para su identificación';

  @override
  String get uploadImageSubHint => 'Mejores resultados con imágenes bien iluminadas y enfocadas';

  @override
  String speciesLabel(String speciesName) {
    return 'Especie: $speciesName';
  }

  @override
  String commonNameLabel(String commonName) {
    return 'Nombre Común: $commonName';
  }

  @override
  String confidenceLabel(String confidenceValue) {
    return 'Confianza: $confidenceValue%';
  }

  @override
  String inferenceTimeLabel(int timeValue) {
    return 'Tiempo: $timeValue ms';
  }

  @override
  String get speciesInfoButton => 'Info de Especie';

  @override
  String get diseaseRisksButton => 'Riesgos de Enfermedad';

  @override
  String get noKnownDiseaseRisks => 'No se conocen riesgos de enfermedad para esta especie';

  @override
  String get potentialDiseaseRisksTitle => 'Riesgos Potenciales de Enfermedad';

  @override
  String get potentialDiseaseRisksSubtitle => 'Se sabe que esta especie de mosquito transmite las siguientes enfermedades:';

  @override
  String get disclaimerEducationalUse => 'Descargo de responsabilidad: Esta aplicación proporciona información únicamente con fines educativos. Siempre consulte a profesionales de la salud para un diagnóstico y tratamiento adecuados.';

  @override
  String get cameraButtonLabel => 'Cámara';

  @override
  String get galleryButtonLabel => 'Galería';

  @override
  String get resetButtonLabel => 'Reiniciar';

  @override
  String get analyzingImage => 'Analizando imagen...';

  @override
  String get analyzeButton => 'Analizar';

  @override
  String get noImageSelectedTitle => 'No Hay Imagen Seleccionada';

  @override
  String get noImageSelectedSubtitle => 'Toma una foto o selecciona de la galería';

  @override
  String get unknownSpecies => 'Desconocido';

  @override
  String errorFailedToPickImage(String error) {
    return 'Error al seleccionar imagen: $error';
  }

  @override
  String get errorNoImageSelected => 'No se ha seleccionado ninguna imagen';

  @override
  String errorClassificationFailed(String error) {
    return 'Falló la clasificación: $error';
  }

  @override
  String errorFailedToLoadModel(String error) {
    return 'Error al cargar el modelo: $error';
  }

  @override
  String get mosquitoGalleryScreenTitle => 'Galería de Especies de Mosquitos';

  @override
  String get searchMosquitoSpeciesHint => 'Buscar especies de mosquitos...';

  @override
  String get anErrorOccurred => 'Ocurrió un error';

  @override
  String get retryButton => 'Reintentar';

  @override
  String get noMosquitoSpeciesFound => 'No se encontraron especies de mosquitos';

  @override
  String get tryDifferentSearchTerm => 'Intenta un término de búsqueda diferente';

  @override
  String habitatLabel(String habitat) {
    return 'Hábitat: $habitat';
  }

  @override
  String diseaseVectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vectores de enfermedades',
      one: '1 vector de enfermedad',
      zero: 'No se conocen vectores de enfermedades',
    );
    return '$_temp0';
  }

  @override
  String get noKnownDiseaseVectors => 'No se conocen vectores de enfermedades';

  @override
  String get diseaseDetailScreenDescription => 'Descripción';

  @override
  String get diseaseDetailScreenSymptoms => 'Síntomas';

  @override
  String get diseaseDetailScreenTreatment => 'Tratamiento';

  @override
  String get diseaseDetailScreenPrevention => 'Prevención';

  @override
  String get diseaseDetailScreenPrevalence => 'Prevalencia';

  @override
  String get diseaseDetailScreenTransmittedBy => 'Transmitido por';

  @override
  String get diseaseDetailScreenUnknownVector => 'Vector Desconocido';

  @override
  String get diseaseDetailScreenInfoNotAvailable => 'Información no disponible.';

  @override
  String get diseaseDetailScreenVectorsNotAvailable => 'Información sobre vectores no disponible.';

  @override
  String get mosquitoDetailScreenDescription => 'Descripción';

  @override
  String get mosquitoDetailScreenHabitat => 'Hábitat';

  @override
  String get mosquitoDetailScreenDistribution => 'Distribución';

  @override
  String get mosquitoDetailScreenAssociatedDiseases => 'Enfermedades Asociadas';

  @override
  String get mosquitoDetailScreenNoAssociatedDiseases => 'No se conocen enfermedades asociadas con esta especie en nuestra base de datos.';

  @override
  String get diseaseInfoScreenTitle => 'Enfermedades Transmitidas por Mosquitos';

  @override
  String get searchDiseasesHint => 'Buscar enfermedades...';

  @override
  String get noDiseasesFound => 'No se encontraron enfermedades';

  @override
  String vectorsLabel(String vectors) {
    return 'Vectores: $vectors';
  }

  @override
  String prevalenceLabel(String prevalence) {
    return 'Prevalencia: $prevalence';
  }

  @override
  String get classificationServiceUnknownSpeciesCommonName => 'Especie Desconocida';

  @override
  String get classificationServiceUnknownSpeciesDescription => 'No hay información detallada disponible para esta especie.';

  @override
  String get classificationServiceUnknownSpeciesHabitat => 'Desconocido';

  @override
  String get classificationServiceUnknownSpeciesDistribution => 'Desconocido';

  @override
  String get classificationServiceErrorModelNotLoaded => 'Modelo no cargado';

  @override
  String get classificationServiceErrorModelLoadingFailed => 'Falló la carga del modelo - solo compatible con Android/iOS';

  @override
  String viewModelErrorFailedToLoadDiseases(String error) {
    return 'Error al cargar enfermedades: $error';
  }

  @override
  String viewModelErrorFailedToLoadDisease(String error) {
    return 'Error al cargar enfermedad: $error';
  }

  @override
  String viewModelErrorFailedToLoadDiseasesForVector(String error) {
    return 'Error al cargar enfermedades por vector: $error';
  }

  @override
  String viewModelErrorFailedToLoadMosquitoSpecies(String error) {
    return 'Error al cargar especies de mosquitos: $error';
  }

  @override
  String get homePageMosquitoActivityMapButtonTitle => 'Mapa de Actividad de Mosquitos';

  @override
  String get homePageMosquitoActivityMapButtonSubtitle => 'Ver mapa interactivo de reportes de mosquitos';

  @override
  String get webViewScreenTitleMosquitoMap => 'Mapa de Actividad de Mosquitos';

  @override
  String get webViewFailedToLoad => 'No se pudo cargar la página';

  @override
  String get webViewRetryButton => 'Reintentar';

  @override
  String get tooltipSelectLanguage => 'Seleccionar idioma';

  @override
  String get addDetailsButton => 'Agregar detalles de la observación';

  @override
  String get thankYouForParticipation => '¡Gracias por tu contribución!';

  @override
  String submissionIdLabel(String id) {
    return 'ID de envío: $id';
  }

  @override
  String errorSubmissionFailed(String error) {
    return 'Error en el envío: $error';
  }

  @override
  String get observationDetailsTitle => 'Detalles de la observación';

  @override
  String get locationSectionTitle => 'Ubicación de la observación';

  @override
  String get locationInstruction => 'Toca en el mapa para marcar la ubicación exacta de tu observación.';

  @override
  String get fieldRequiredError => 'Este campo es obligatorio';

  @override
  String get locationRequiredError => 'Por favor, selecciona una ubicación en el mapa.';

  @override
  String get notesLabel => 'Notas';

  @override
  String get notesHint => 'Añade cualquier detalle relevante (p. ej., hora del día, clima, entorno)...';

  @override
  String get submitObservationButton => 'Enviar observación';

  @override
  String get predictionSummaryTitle => 'Resumen de la predicción';

  @override
  String get latitudeLabel => 'Latitud';

  @override
  String get longitudeLabel => 'Longitud';
}
