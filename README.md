# CulicidaeLab

CulicidaeLab is a cross-platform Flutter application designed to help users identify mosquito species and learn about mosquito-borne diseases. The app provides educational information, a gallery of epidemiologically significant mosquito species, and details about diseases transmitted by mosquitoes.

## Features

- **Mosquito Classification:** Take or upload a photo to identify mosquito species using an AI-powered model.
- **Mosquito Gallery:** Browse information and images of dangerous mosquito species.
- **Disease Information:** Learn about diseases transmitted by mosquitoes, including symptoms, prevention, and prevalence.
- **Localization:** Supports English, Spanish, and Russian languages.
- **Interactive Map:** View a map of mosquito activity reports (Android/iOS only).
- **Educational Use:** The app is intended for educational and research purposes only.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Dart SDK (included with Flutter)
- Android Studio or Xcode for mobile development

### Installation

1. **Clone the repository:**
   ```sh
   git clone https://gitlab.com/culicidaelab/culicidaelab-app.git
   cd culicidaelab
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Run the app:**
   ```sh
   flutter run
   ```

## Project Structure

- main.dart – Application entry point
- l10n – Localization files (`.arb`)
- models – Data models
- providers – State management providers
- repositories – Data repositories
- screens – UI screens
- services – Business logic and platform services
- view_models – View models for stateful widgets
- widgets – Reusable UI components

## Localization

The app supports multiple languages. To add or update translations, edit the `.arb` files in l10n.

## Disclaimer

This platform is for educational and research purposes only. It does not replace professional medical advice or guidance from public health authorities.

## License

MIT License

---

**Development supported by a grant from the Foundation for Assistance to Small Innovative Enterprises (FASIE):**
https://fasie.ru

---

For more information, see the project documentation or contact the development team.