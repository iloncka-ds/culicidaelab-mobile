# Настройка среды разработки

## Обзор

Это руководство предоставляет комплексные инструкции по настройке среды разработки для мобильного приложения CulicidaeLab Flutter. Проект поддерживает как контейнеризованную разработку с использованием VS Code Dev Containers, так и ручную локальную настройку.

## Предварительные требования

### Системные требования

- **Операционная система**: Windows 10/11, macOS 10.14+ или Ubuntu 18.04+
- **ОЗУ**: Минимум 8ГБ, рекомендуется 16ГБ
- **Хранилище**: Не менее 10ГБ свободного места для инструментов разработки и зависимостей
- **Сеть**: Стабильное интернет-соединение для загрузки зависимостей

### Необходимые инструменты

- **Git**: Система контроля версий
- **VS Code**: Рекомендуемая IDE с расширениями Flutter
- **Docker**: Для контейнеризованной разработки (опционально, но рекомендуется)

## Вариант 1: Настройка Dev Container (Рекомендуется)

Самый простой способ начать — использовать предоставленную конфигурацию Dev Container, которая обеспечивает согласованную среду разработки на всех платформах.

### Предварительные требования для Dev Container

1. **Установите Docker Desktop**
   - **Windows**: Загрузите с [Docker Desktop для Windows](https://docs.docker.com/desktop/windows/install/)
   - **macOS**: Загрузите с [Docker Desktop для Mac](https://docs.docker.com/desktop/mac/install/)
   - **Linux**: Следуйте [руководству по установке Docker Engine](https://docs.docker.com/engine/install/)

2. **Установите VS Code**
   - Загрузите с [Visual Studio Code](https://code.visualstudio.com/)

3. **Установите расширение Dev Containers**
   - Откройте VS Code
   - Перейдите в Расширения (Ctrl+Shift+X)
   - Найдите "Dev Containers" от Microsoft
   - Установите расширение

### Настройка Dev Container

1. **Клонируйте репозиторий**
   ```bash
   git clone https://github.com/your-org/culicidaelab.git
   cd culicidaelab
   ```

2. **Откройте в Dev Container**
   - Откройте VS Code
   - Откройте папку проекта
   - VS Code должен обнаружить конфигурацию `.devcontainer`
   - Нажмите "Reopen in Container" при появлении запроса, или:
     - Нажмите `Ctrl+Shift+P` (Cmd+Shift+P на Mac)
     - Введите "Dev Containers: Reopen in Container"
     - Выберите команду

3. **Дождитесь сборки контейнера**
   - Первая сборка может занять 10-15 минут
   - Последующие запуски будут намного быстрее
   - Контейнер включает:
     - Flutter SDK 3.29.3
     - Android SDK с Platform 35
     - Android Build Tools 34.0.0
     - Android NDK 27.0.12077973
     - Java 17
     - Все необходимые инструменты разработки

4. **Проверьте установку**
   ```bash
   flutter doctor
   ```
   - Это должно показать все галочки для разработки Android
   - Разработка iOS будет показана как недоступная (ожидаемо в Linux контейнере)

### Функции Dev Container

Dev container включает:

- **Предварительно настроенный Flutter SDK**: Последняя стабильная версия с поддержкой Android
- **Инструменты разработки Android**: Полный Android SDK, NDK и инструменты сборки
- **Расширения VS Code**: Flutter, Dart и полезные расширения для разработки
- **Поддержка USB устройств**: Возможности отладки физических устройств
- **Перенаправление портов**: Автоматическое перенаправление портов для серверов разработки

## Вариант 2: Ручная локальная настройка

Если вы предпочитаете настроить среду разработки вручную или не можете использовать Docker, следуйте этим платформо-специфическим инструкциям.

### Настройка Windows

1. **Установите Git**
   - Загрузите с [Git для Windows](https://git-scm.com/download/win)
   - Используйте опции установки по умолчанию

2. **Установите Flutter SDK**
   ```powershell
   # Загрузите Flutter SDK
   Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.3-stable.zip" -OutFile "flutter_sdk.zip"
   
   # Извлеките в C:\flutter
   Expand-Archive -Path "flutter_sdk.zip" -DestinationPath "C:\"
   
   # Добавьте в PATH
   $env:PATH += ";C:\flutter\bin"
   [Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::User)
   ```

3. **Установите Android Studio**
   - Загрузите с [Android Studio](https://developer.android.com/studio)
   - Установите с опциями по умолчанию
   - Откройте Android Studio и завершите мастер настройки
   - Установите Android SDK Platform 35 и Build Tools 34.0.0

4. **Настройте Android SDK**
   ```powershell
   # Установите переменные окружения
   [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$env:LOCALAPPDATA\Android\Sdk", [EnvironmentVariableTarget]::User)
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", [EnvironmentVariableTarget]::User)
   ```

5. **Установите VS Code и расширения**
   - Загрузите VS Code с [code.visualstudio.com](https://code.visualstudio.com/)
   - Установите расширения Flutter и Dart

### Настройка macOS

1. **Установите Homebrew** (если еще не установлен)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Установите Git**
   ```bash
   brew install git
   ```

3. **Установите Flutter SDK**
   ```bash
   # Загрузите и извлеките Flutter
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.3-stable.zip
   unzip flutter_macos_3.29.3-stable.zip
   
   # Добавьте в PATH
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Установите Android Studio**
   - Загрузите с [Android Studio](https://developer.android.com/studio)
   - Установите и завершите мастер настройки
   - Установите необходимые компоненты SDK

5. **Установите Xcode** (для разработки iOS)
   ```bash
   # Установите Xcode из App Store
   # Установите инструменты командной строки Xcode
   sudo xcode-select --install
   ```

6. **Настройте окружение**
   ```bash
   # Добавьте Android SDK в PATH
   echo 'export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```

### Настройка Linux (Ubuntu)

1. **Обновите систему**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Установите зависимости**
   ```bash
   sudo apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk
   ```

3. **Установите Flutter SDK**
   ```bash
   # Загрузите Flutter
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz
   tar xf flutter_linux_3.29.3-stable.tar.xz
   
   # Добавьте в PATH
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Установите Android Studio**
   ```bash
   # Загрузите Android Studio
   wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz
   tar -xzf android-studio-*-linux.tar.gz -C ~/development/
   
   # Запустите Android Studio
   ~/development/android-studio/bin/studio.sh
   ```

5. **Настройте окружение**
   ```bash
   # Установите переменные окружения
   echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc
   source ~/.bashrc
   ```

## Настройка проекта

### Клонирование и инициализация

1. **Клонируйте репозиторий**
   ```bash
   git clone https://github.com/your-org/culicidaelab.git
   cd culicidaelab
   ```

2. **Установите зависимости**
   ```bash
   flutter pub get
   ```

3. **Проверьте настройку**
   ```bash
   flutter doctor
   ```
   - Решите любые проблемы, показанные flutter doctor
   - Убедитесь, что Android toolchain показывает зеленую галочку

### Конфигурация IDE

#### Настройка VS Code

1. **Установите расширения**
   - Flutter (Dart-Code.flutter)
   - Dart (Dart-Code.dart-code)
   - EditorConfig (EditorConfig.EditorConfig)
   - VSCode Icons (vscode-icons-team.vscode-icons)

2. **Настройте параметры**
   Создайте `.vscode/settings.json`:
   ```json
   {
     "dart.flutterSdkPath": "/path/to/flutter",
     "dart.lineLength": 120,
     "editor.formatOnSave": true,
     "editor.tabSize": 2,
     "editor.insertSpaces": true,
     "editor.detectIndentation": false,
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true,
     "dart.debugExternalLibraries": false,
     "dart.debugSdkLibraries": false,
     "files.autoSave": "afterDelay"
   }
   ```

#### Настройка Android Studio

1. **Установите плагин Flutter**
   - Перейдите в File → Settings → Plugins
   - Найдите "Flutter" и установите
   - Перезапустите Android Studio

2. **Настройте пути SDK**
   - Перейдите в File → Project Structure
   - Проверьте путь Android SDK
   - Установите путь Flutter SDK

## Настройка устройства

### Настройка устройства Android

#### Физическое устройство

1. **Включите параметры разработчика**
   - Перейдите в Настройки → О телефоне
   - Нажмите "Номер сборки" 7 раз
   - Вернитесь в Настройки → Параметры разработчика

2. **Включите отладку по USB**
   - В параметрах разработчика включите "Отладка по USB"
   - Подключите устройство через USB
   - Примите авторизацию отладки на устройстве

3. **Проверьте соединение**
   ```bash
   flutter devices
   ```

#### Эмулятор Android

1. **Создайте AVD**
   - Откройте Android Studio
   - Перейдите в Tools → AVD Manager
   - Создайте виртуальное устройство
   - Выберите Pixel 4 или аналогичный
   - Выберите API Level 35 (Android 14)
   - Завершите настройку

2. **Запустите эмулятор**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

### Настройка устройства iOS (только macOS)

#### Физическое устройство

1. **Установите сертификат разработки iOS**
   - Откройте Xcode
   - Перейдите в Preferences → Accounts
   - Добавьте Apple ID
   - Загрузите сертификаты разработки

2. **Настройте устройство**
   - Подключите iOS устройство
   - Доверьтесь компьютеру на устройстве
   - Включите режим разработчика в настройках

#### Симулятор iOS

1. **Установите симулятор**
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   open -a Simulator
   ```

2. **Проверьте настройку**
   ```bash
   flutter devices
   ```

## Запуск приложения

### Режим разработки

1. **Запустите приложение**
   ```bash
   # Запуск на подключенном устройстве/эмуляторе
   flutter run
   
   # Запуск на конкретном устройстве
   flutter run -d <device_id>
   
   # Запуск с горячей перезагрузкой
   flutter run --hot
   ```

2. **Функции режима отладки**
   - Горячая перезагрузка: Нажмите `r` в терминале или сохраните файлы
   - Горячий перезапуск: Нажмите `R` в терминале
   - Инспектор отладки: Нажмите `w` в терминале

### Режимы сборки

1. **Отладочная сборка**
   ```bash
   flutter build apk --debug
   ```

2. **Релизная сборка**
   ```bash
   flutter build apk --release
   ```

3. **Профильная сборка**
   ```bash
   flutter build apk --profile
   ```

## Устранение неполадок

### Распространенные проблемы

#### Проблемы Flutter Doctor

1. **Проблемы с лицензиями Android**
   ```bash
   flutter doctor --android-licenses
   ```
   Примите все лицензии при запросе.

2. **Android SDK не найден**
   - Проверьте переменную окружения ANDROID_SDK_ROOT
   - Убедитесь, что Android SDK установлен в правильном месте

3. **Проблемы Flutter SDK**
   ```bash
   flutter channel stable
   flutter upgrade
   flutter doctor
   ```

#### Проблемы сборки

1. **Ошибки сборки Gradle**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **Конфликты зависимостей**
   ```bash
   flutter pub deps
   flutter pub upgrade
   ```

#### Проблемы подключения устройства

1. **Проблемы ADB**
   ```bash
   adb kill-server
   adb start-server
   flutter devices
   ```

2. **Отладка по USB не работает**
   - Попробуйте другой USB кабель
   - Включите режим "Передача файлов" на устройстве
   - Отзовите авторизации отладки по USB и переподключитесь

### Проблемы производительности

1. **Медленное время сборки**
   - Увеличьте память Gradle: Добавьте `org.gradle.jvmargs=-Xmx4g` в `android/gradle.properties`
   - Используйте флаг `--no-sound-null-safety` если нужно
   - Очистите кэш сборки: `flutter clean`

2. **Горячая перезагрузка не работает**
   - Убедитесь, что вы в режиме отладки
   - Проверьте синтаксические ошибки
   - Перезапустите сессию отладки

## Рабочий процесс разработки

### Рекомендуемый рабочий процесс

1. **Начните сессию разработки**
   ```bash
   # Откройте проект в VS Code
   code .
   
   # Запустите устройство/эмулятор
   flutter devices
   flutter run
   ```

2. **Цикл разработки**
   - Внесите изменения в код
   - Сохраните файлы (автоматическая горячая перезагрузка)
   - Протестируйте изменения на устройстве
   - Зафиксируйте изменения с осмысленными сообщениями

3. **Тестирование**
   ```bash
   # Запустите модульные тесты
   flutter test
   
   # Запустите интеграционные тесты
   flutter test integration_test/
   
   # Запустите конкретный тестовый файл
   flutter test test/unit/services/classification_service_test.dart
   ```

4. **Качество кода**
   ```bash
   # Форматируйте код
   flutter format .
   
   # Анализируйте код
   flutter analyze
   
   # Проверьте устаревшие зависимости
   flutter pub outdated
   ```

## Следующие шаги

После завершения настройки среды разработки:

1. **Прочитайте документацию по архитектуре**: Поймите структуру и паттерны приложения
2. **Просмотрите руководство по структуре проекта**: Изучите организацию директорий и соглашения
3. **Проверьте руководящие принципы участия**: Поймите рабочий процесс разработки и стандарты
4. **Запустите набор тестов**: Убедитесь, что все работает правильно
5. **Начните с небольших изменений**: Внесите незначительное изменение, чтобы ознакомиться с кодовой базой

## Получение помощи

Если вы столкнулись с проблемами во время настройки:

1. **Проверьте Flutter Doctor**: Запустите `flutter doctor -v` для подробной диагностики
2. **Просмотрите логи**: Проверьте вывод консоли на предмет конкретных сообщений об ошибках
3. **Поищите в документации**: Документация Flutter и Android часто содержит решения
4. **Попросите помощи**: Создайте задачу в репозитории проекта с:
   - Вашей операционной системой и версией
   - Выводом flutter doctor
   - Полными сообщениями об ошибках
   - Шагами, которые вы уже попробовали

## Дополнительные ресурсы

- [Документация Flutter](https://docs.flutter.dev/)
- [Документация разработчика Android](https://developer.android.com/docs)
- [Расширение VS Code Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Flutter Dev Tools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Тур по языку Dart](https://dart.dev/guides/language/language-tour)