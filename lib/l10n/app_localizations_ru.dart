// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'CulicidaeLab';

  @override
  String get homePageTitle => 'CulicidaeLab';

  @override
  String get homePageBannerTitle => 'Классификация комаров';

  @override
  String get homePageBannerSubtitle => 'Приложение поможет определить виды комаров и узнать информацию о потенциальных переносчиках болезней';

  @override
  String get classifyMosquitoButtonTitle => 'Определите вид комара';

  @override
  String get classifyMosquitoButtonSubtitle => 'Сделайте или загрузите фото для определения вида комара';

  @override
  String get mosquitoGalleryButtonTitle => 'Информация об опасных видах комаров';

  @override
  String get mosquitoGalleryButtonSubtitle => 'Узнайте больше информации об эпидемиологически опасных видах комаров';

  @override
  String get diseasesInfoButtonTitle => 'Информация о болезнях';

  @override
  String get diseasesInfoButtonSubtitle => 'Узнайте о болезнях, передаваемых комарами-переносчиками';

  @override
  String get appDisclaimerTitle => 'Отказ от ответственности:';

  @override
  String get appDisclaimerBody => 'Эта платформа предназначена только для образовательных и исследовательских целей. Она не заменяет профессиональную медицинскую консультацию или методические указания и приказы органов общественного здравоохранения.';

  @override
  String get appFooterGrantInfo => 'Разработка CulicidaeLab поддерживается грантом \nФонда содействия инновациям\nhttps://fasie.ru';

  @override
  String get loadingModelDialogTitle => 'Загрузка модели';

  @override
  String get loadingModelDialogContent => 'Пожалуйста, подождите, пока загружается модель классификации...';

  @override
  String get classificationScreenTitle => 'Классифицировать комара';

  @override
  String get uploadImageHint => 'Загрузите четкое изображение комара для идентификации';

  @override
  String get uploadImageSubHint => 'Более точные результаты можно получить только с хорошо освещенными, сфокусированными изображениями';

  @override
  String speciesLabel(String speciesName) {
    return 'Вид: $speciesName';
  }

  @override
  String commonNameLabel(String commonName) {
    return 'Обыденное название: $commonName';
  }

  @override
  String confidenceLabel(String confidenceValue) {
    return 'Точность: $confidenceValue%';
  }

  @override
  String inferenceTimeLabel(int timeValue) {
    return 'Время: $timeValue мс';
  }

  @override
  String get speciesInfoButton => 'Информация о виде';

  @override
  String get diseaseRisksButton => 'Риски заболеваний';

  @override
  String get noKnownDiseaseRisks => 'Для этого вида не известны риски заболеваний';

  @override
  String get potentialDiseaseRisksTitle => 'Потенциальные риски заболеваний';

  @override
  String get potentialDiseaseRisksSubtitle => 'Известно, что этот вид комаров передает следующие заболевания:';

  @override
  String get disclaimerEducationalUse => 'Заявление об ограничении ответственности: Это приложение предоставляет информацию только в образовательных целях. Всегда консультируйтесь с медицинскими работниками для правильной диагностики и лечения.';

  @override
  String get cameraButtonLabel => 'Камера';

  @override
  String get galleryButtonLabel => 'Галерея';

  @override
  String get resetButtonLabel => 'Сброс';

  @override
  String get analyzingImage => 'Подождите, пока происходит обработка и анализ изображения...';

  @override
  String get analyzeButton => 'Определить вид';

  @override
  String get noImageSelectedTitle => 'Изображение не выбрано';

  @override
  String get noImageSelectedSubtitle => 'Сделайте фото или выберите из галереи';

  @override
  String get unknownSpecies => 'Информация отсутствует';

  @override
  String errorFailedToPickImage(String error) {
    return 'Не удалось выбрать изображение: $error';
  }

  @override
  String get errorNoImageSelected => 'Изображение не выбрано';

  @override
  String errorClassificationFailed(String error) {
    return 'Ошибка классификации: $error';
  }

  @override
  String errorFailedToLoadModel(String error) {
    return 'Не удалось загрузить модель: $error';
  }

  @override
  String get mosquitoGalleryScreenTitle => 'Информация об эпидемиологически опасных видах комаров';

  @override
  String get searchMosquitoSpeciesHint => 'Поиск видов комаров...';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get retryButton => 'Повторить';

  @override
  String get noMosquitoSpeciesFound => 'Запрашиваемые виды комаров не найдены';

  @override
  String get tryDifferentSearchTerm => 'Попробуйте другой поисковый запрос';

  @override
  String habitatLabel(String habitat) {
    return 'Среда обитания: $habitat';
  }

  @override
  String diseaseVectorsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count переносчиков болезней',
      many: '$count переносчиков болезней',
      few: '$count переносчика болезней',
      one: '1 переносчик',
      zero: 'Информация о комарах, переносчиках данного заболевания: $count переносчиков болезней',
    );
    return '$_temp0';
  }

  @override
  String get noKnownDiseaseVectors => 'Переносчиков болезней не известно';

  @override
  String get diseaseDetailScreenDescription => 'Описание';

  @override
  String get diseaseDetailScreenSymptoms => 'Симптомы';

  @override
  String get diseaseDetailScreenTreatment => 'Лечение';

  @override
  String get diseaseDetailScreenPrevention => 'Профилактика';

  @override
  String get diseaseDetailScreenPrevalence => 'Распространенность';

  @override
  String get diseaseDetailScreenTransmittedBy => 'Передается через';

  @override
  String get diseaseDetailScreenUnknownVector => 'Неизвестный переносчик';

  @override
  String get diseaseDetailScreenInfoNotAvailable => 'Информация недоступна.';

  @override
  String get diseaseDetailScreenVectorsNotAvailable => 'Информация о переносчиках недоступна.';

  @override
  String get mosquitoDetailScreenDescription => 'Описание';

  @override
  String get mosquitoDetailScreenHabitat => 'Среда обитания';

  @override
  String get mosquitoDetailScreenDistribution => 'Распространение';

  @override
  String get mosquitoDetailScreenAssociatedDiseases => 'Связанные заболевания';

  @override
  String get mosquitoDetailScreenNoAssociatedDiseases => 'С этим видом не связаны известные заболевания.';

  @override
  String get diseaseInfoScreenTitle => 'Болезни, передаваемые комарами';

  @override
  String get searchDiseasesHint => 'Поиск болезней...';

  @override
  String get noDiseasesFound => 'Информация о заболеваниях отсутствует';

  @override
  String vectorsLabel(String vectors) {
    return 'Комары-переносчики: $vectors';
  }

  @override
  String prevalenceLabel(String prevalence) {
    return 'Распространенность: $prevalence';
  }

  @override
  String get classificationServiceUnknownSpeciesCommonName => 'Неизвестно';

  @override
  String get classificationServiceUnknownSpeciesDescription => 'Информация отсутствует.';

  @override
  String get classificationServiceUnknownSpeciesHabitat => 'Неизвестно';

  @override
  String get classificationServiceUnknownSpeciesDistribution => 'Неизвестно';

  @override
  String get classificationServiceErrorModelNotLoaded => 'Модель не загружена';

  @override
  String get classificationServiceErrorModelLoadingFailed => 'Ошибка загрузки модели - поддерживается только для Android/iOS';

  @override
  String viewModelErrorFailedToLoadDiseases(String error) {
    return 'Не удалось загрузить информацию о заболеваниях: $error';
  }

  @override
  String viewModelErrorFailedToLoadDisease(String error) {
    return 'Не удалось загрузить информацию о заболевании: $error';
  }

  @override
  String viewModelErrorFailedToLoadDiseasesForVector(String error) {
    return 'Не удалось загрузить заболевания, специфичные для переносчика: $error';
  }

  @override
  String viewModelErrorFailedToLoadMosquitoSpecies(String error) {
    return 'Не удалось загрузить виды комаров: $error';
  }

  @override
  String get homePageMosquitoActivityMapButtonTitle => 'Карта активности комаров';

  @override
  String get homePageMosquitoActivityMapButtonSubtitle => 'Просмотр интерактивной карты об активности и распространённости комаров';

  @override
  String get webViewScreenTitleMosquitoMap => 'Карта активности комаров';

  @override
  String get webViewFailedToLoad => 'Не удалось загрузить страницу';

  @override
  String get webViewRetryButton => 'Повторить';

  @override
  String get tooltipSelectLanguage => 'Выберите язык';

  @override
  String get addDetailsButton => 'Поделиться информацией о наблюдении';

  @override
  String get thankYouForParticipation => 'Спасибо за ваш вклад!';

  @override
  String submissionIdLabel(String id) {
    return 'ID отправки: $id';
  }

  @override
  String errorSubmissionFailed(String error) {
    return 'Ошибка отправки: $error';
  }

  @override
  String get observationDetailsTitle => 'Дополнительная информация';

  @override
  String get locationSectionTitle => 'Местоположение наблюдения';

  @override
  String get locationInstruction => 'Нажмите на карту, чтобы отметить точное местоположение вашего наблюдения.';

  @override
  String get fieldRequiredError => 'Это поле обязательно для заполнения';

  @override
  String get locationRequiredError => 'Пожалуйста, выберите местоположение на карте.';

  @override
  String get notesLabel => 'Примечания';

  @override
  String get notesHint => 'Добавьте любые важные детали (например, время суток, погода, окружение)...';

  @override
  String get submitObservationButton => 'Отправить';

  @override
  String get predictionSummaryTitle => 'Результаты';

  @override
  String get latitudeLabel => 'Широта';

  @override
  String get longitudeLabel => 'Долгота';
}
