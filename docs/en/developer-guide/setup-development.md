# Development Environment Setup

## Overview

This guide provides comprehensive instructions for setting up a development environment for the CulicidaeLab Flutter mobile application. The project supports both containerized development using VS Code Dev Containers and manual local setup.

## Prerequisites

### System Requirements

- **Operating System**: Windows 10/11, macOS 10.14+, or Ubuntu 18.04+
- **RAM**: Minimum 8GB, recommended 16GB
- **Storage**: At least 10GB free space for development tools and dependencies
- **Network**: Stable internet connection for downloading dependencies

### Required Tools

- **Git**: Version control system
- **VS Code**: Recommended IDE with Flutter extensions
- **Docker**: For containerized development (optional but recommended)

## Option 1: Dev Container Setup (Recommended)

The easiest way to get started is using the provided Dev Container configuration, which provides a consistent development environment across all platforms.

### Prerequisites for Dev Container

1. **Install Docker Desktop**
   - **Windows**: Download from [Docker Desktop for Windows](https://docs.docker.com/desktop/windows/install/)
   - **macOS**: Download from [Docker Desktop for Mac](https://docs.docker.com/desktop/mac/install/)
   - **Linux**: Follow [Docker Engine installation guide](https://docs.docker.com/engine/install/)

2. **Install VS Code**
   - Download from [Visual Studio Code](https://code.visualstudio.com/)

3. **Install Dev Containers Extension**
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Dev Containers" by Microsoft
   - Install the extension

### Setting Up Dev Container

1. **Clone the Repository**
   ```bash
   git clone https://github.com/your-org/culicidaelab.git
   cd culicidaelab
   ```

2. **Open in Dev Container**
   - Open VS Code
   - Open the project folder
   - VS Code should detect the `.devcontainer` configuration
   - Click "Reopen in Container" when prompted, or:
     - Press `Ctrl+Shift+P` (Cmd+Shift+P on Mac)
     - Type "Dev Containers: Reopen in Container"
     - Select the command

3. **Wait for Container Build**
   - The first build may take 10-15 minutes
   - Subsequent starts will be much faster
   - The container includes:
     - Flutter SDK 3.29.3
     - Android SDK with Platform 35
     - Android Build Tools 34.0.0
     - Android NDK 27.0.12077973
     - Java 17
     - All necessary development tools

4. **Verify Installation**
   ```bash
   flutter doctor
   ```
   - This should show all checkmarks for Android development
   - iOS development will show as unavailable (expected on Linux container)

### Dev Container Features

The dev container includes:

- **Pre-configured Flutter SDK**: Latest stable version with Android support
- **Android Development Tools**: Complete Android SDK, NDK, and build tools
- **VS Code Extensions**: Flutter, Dart, and helpful development extensions
- **USB Device Support**: Physical device debugging capabilities
- **Port Forwarding**: Automatic port forwarding for development servers

## Option 2: Manual Local Setup

If you prefer to set up the development environment manually or cannot use Docker, follow these platform-specific instructions.

### Windows Setup

1. **Install Git**
   - Download from [Git for Windows](https://git-scm.com/download/win)
   - Use default installation options

2. **Install Flutter SDK**
   ```powershell
   # Download Flutter SDK
   Invoke-WebRequest -Uri "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.29.3-stable.zip" -OutFile "flutter_sdk.zip"
   
   # Extract to C:\flutter
   Expand-Archive -Path "flutter_sdk.zip" -DestinationPath "C:\"
   
   # Add to PATH
   $env:PATH += ";C:\flutter\bin"
   [Environment]::SetEnvironmentVariable("PATH", $env:PATH, [EnvironmentVariableTarget]::User)
   ```

3. **Install Android Studio**
   - Download from [Android Studio](https://developer.android.com/studio)
   - Install with default options
   - Open Android Studio and complete the setup wizard
   - Install Android SDK Platform 35 and Build Tools 34.0.0

4. **Configure Android SDK**
   ```powershell
   # Set environment variables
   [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "$env:LOCALAPPDATA\Android\Sdk", [EnvironmentVariableTarget]::User)
   [Environment]::SetEnvironmentVariable("ANDROID_HOME", "$env:LOCALAPPDATA\Android\Sdk", [EnvironmentVariableTarget]::User)
   ```

5. **Install VS Code and Extensions**
   - Download VS Code from [code.visualstudio.com](https://code.visualstudio.com/)
   - Install Flutter and Dart extensions

### macOS Setup

1. **Install Homebrew** (if not already installed)
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Install Git**
   ```bash
   brew install git
   ```

3. **Install Flutter SDK**
   ```bash
   # Download and extract Flutter
   cd ~/development
   curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.29.3-stable.zip
   unzip flutter_macos_3.29.3-stable.zip
   
   # Add to PATH
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
   source ~/.zshrc
   ```

4. **Install Android Studio**
   - Download from [Android Studio](https://developer.android.com/studio)
   - Install and complete setup wizard
   - Install required SDK components

5. **Install Xcode** (for iOS development)
   ```bash
   # Install Xcode from App Store
   # Install Xcode command line tools
   sudo xcode-select --install
   ```

6. **Configure Environment**
   ```bash
   # Add Android SDK to PATH
   echo 'export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk' >> ~/.zshrc
   echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.zshrc
   source ~/.zshrc
   ```

### Linux (Ubuntu) Setup

1. **Update System**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Dependencies**
   ```bash
   sudo apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk
   ```

3. **Install Flutter SDK**
   ```bash
   # Download Flutter
   cd ~/development
   wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.29.3-stable.tar.xz
   tar xf flutter_linux_3.29.3-stable.tar.xz
   
   # Add to PATH
   echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Install Android Studio**
   ```bash
   # Download Android Studio
   wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2023.1.1.28/android-studio-2023.1.1.28-linux.tar.gz
   tar -xzf android-studio-*-linux.tar.gz -C ~/development/
   
   # Run Android Studio
   ~/development/android-studio/bin/studio.sh
   ```

5. **Configure Environment**
   ```bash
   # Set environment variables
   echo 'export ANDROID_SDK_ROOT=$HOME/Android/Sdk' >> ~/.bashrc
   echo 'export PATH=$PATH:$ANDROID_SDK_ROOT/platform-tools' >> ~/.bashrc
   source ~/.bashrc
   ```

## Project Setup

### Clone and Initialize

1. **Clone Repository**
   ```bash
   git clone https://github.com/your-org/culicidaelab.git
   cd culicidaelab
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Setup**
   ```bash
   flutter doctor
   ```
   - Resolve any issues shown by flutter doctor
   - Ensure Android toolchain shows green checkmark

### IDE Configuration

#### VS Code Setup

1. **Install Extensions**
   - Flutter (Dart-Code.flutter)
   - Dart (Dart-Code.dart-code)
   - EditorConfig (EditorConfig.EditorConfig)
   - VSCode Icons (vscode-icons-team.vscode-icons)

2. **Configure Settings**
   Create `.vscode/settings.json`:
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

#### Android Studio Setup

1. **Install Flutter Plugin**
   - Go to File → Settings → Plugins
   - Search for "Flutter" and install
   - Restart Android Studio

2. **Configure SDK Paths**
   - Go to File → Project Structure
   - Verify Android SDK path
   - Set Flutter SDK path

## Device Setup

### Android Device Setup

#### Physical Device

1. **Enable Developer Options**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options

2. **Enable USB Debugging**
   - In Developer Options, enable "USB Debugging"
   - Connect device via USB
   - Accept debugging authorization on device

3. **Verify Connection**
   ```bash
   flutter devices
   ```

#### Android Emulator

1. **Create AVD**
   - Open Android Studio
   - Go to Tools → AVD Manager
   - Create Virtual Device
   - Choose Pixel 4 or similar
   - Select API Level 35 (Android 14)
   - Finish setup

2. **Start Emulator**
   ```bash
   flutter emulators --launch <emulator_id>
   ```

### iOS Device Setup (macOS only)

#### Physical Device

1. **Install iOS Development Certificate**
   - Open Xcode
   - Go to Preferences → Accounts
   - Add Apple ID
   - Download development certificates

2. **Configure Device**
   - Connect iOS device
   - Trust computer on device
   - Enable Developer Mode in Settings

#### iOS Simulator

1. **Install Simulator**
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   open -a Simulator
   ```

2. **Verify Setup**
   ```bash
   flutter devices
   ```

## Running the Application

### Development Mode

1. **Start Application**
   ```bash
   # Run on connected device/emulator
   flutter run
   
   # Run on specific device
   flutter run -d <device_id>
   
   # Run with hot reload
   flutter run --hot
   ```

2. **Debug Mode Features**
   - Hot reload: Press `r` in terminal or save files
   - Hot restart: Press `R` in terminal
   - Debug inspector: Press `w` in terminal

### Build Modes

1. **Debug Build**
   ```bash
   flutter build apk --debug
   ```

2. **Release Build**
   ```bash
   flutter build apk --release
   ```

3. **Profile Build**
   ```bash
   flutter build apk --profile
   ```

## Troubleshooting

### Common Issues

#### Flutter Doctor Issues

1. **Android License Issues**
   ```bash
   flutter doctor --android-licenses
   ```
   Accept all licenses when prompted.

2. **Android SDK Not Found**
   - Verify ANDROID_SDK_ROOT environment variable
   - Ensure Android SDK is installed in correct location

3. **Flutter SDK Issues**
   ```bash
   flutter channel stable
   flutter upgrade
   flutter doctor
   ```

#### Build Issues

1. **Gradle Build Failures**
   ```bash
   cd android
   ./gradlew clean
   cd ..
   flutter clean
   flutter pub get
   ```

2. **Dependency Conflicts**
   ```bash
   flutter pub deps
   flutter pub upgrade
   ```

#### Device Connection Issues

1. **ADB Issues**
   ```bash
   adb kill-server
   adb start-server
   flutter devices
   ```

2. **USB Debugging Not Working**
   - Try different USB cable
   - Enable "File Transfer" mode on device
   - Revoke USB debugging authorizations and reconnect

### Performance Issues

1. **Slow Build Times**
   - Increase Gradle memory: Add `org.gradle.jvmargs=-Xmx4g` to `android/gradle.properties`
   - Use `--no-sound-null-safety` flag if needed
   - Clear build cache: `flutter clean`

2. **Hot Reload Not Working**
   - Ensure you're in debug mode
   - Check for syntax errors
   - Restart debug session

## Development Workflow

### Recommended Workflow

1. **Start Development Session**
   ```bash
   # Open project in VS Code
   code .
   
   # Start device/emulator
   flutter devices
   flutter run
   ```

2. **Development Cycle**
   - Make code changes
   - Save files (auto hot reload)
   - Test changes on device
   - Commit changes with meaningful messages

3. **Testing**
   ```bash
   # Run unit tests
   flutter test
   
   # Run integration tests
   flutter test integration_test/
   
   # Run specific test file
   flutter test test/unit/services/classification_service_test.dart
   ```

4. **Code Quality**
   ```bash
   # Format code
   flutter format .
   
   # Analyze code
   flutter analyze
   
   # Check for outdated dependencies
   flutter pub outdated
   ```

## Next Steps

After completing the development environment setup:

1. **Read the Architecture Documentation**: Understand the app's structure and patterns
2. **Review the Project Structure Guide**: Learn about directory organization and conventions
3. **Check the Contributing Guidelines**: Understand the development workflow and standards
4. **Run the Test Suite**: Ensure everything is working correctly
5. **Start with Small Changes**: Make a minor change to familiarize yourself with the codebase

## Getting Help

If you encounter issues during setup:

1. **Check Flutter Doctor**: Run `flutter doctor -v` for detailed diagnostics
2. **Review Logs**: Check console output for specific error messages
3. **Search Documentation**: Flutter and Android documentation often have solutions
4. **Ask for Help**: Create an issue in the project repository with:
   - Your operating system and version
   - Flutter doctor output
   - Complete error messages
   - Steps you've already tried

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Android Developer Documentation](https://developer.android.com/docs)
- [VS Code Flutter Extension](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [Flutter Dev Tools](https://docs.flutter.dev/development/tools/devtools/overview)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)