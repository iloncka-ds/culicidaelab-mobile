/// ClassificationScreen provides the main interface for mosquito species identification and classification.
///
/// This screen serves as the core feature of the CulicidaeLab application, enabling users to:
/// - **Image Capture**: Take photos using device camera or select from gallery
/// - **AI Classification**: Real-time species identification using PyTorch Lite models
/// - **Result Display**: Show confidence scores, inference time, and species information
/// - **Disease Information**: Access associated disease risks and detailed information
/// - **Observation Submission**: Submit findings with location data and notes to the research database
///
/// ## Architecture & State Management
///
/// The screen implements the MVVM pattern using:
/// - [ClassificationViewModel] for business logic and state management
/// - [Provider] pattern for reactive UI updates
/// - Service locator for dependency injection
/// - Asynchronous operations for image processing and API calls
///
/// ## User Workflow
///
/// ```
/// 1. User selects image source (camera/gallery)
/// 2. Image is captured/selected and displayed
/// 3. AI model processes image and returns prediction
/// 4. Results shown with species info and confidence
/// 5. User can view disease risks or submit observation
/// 6. Optional: Add location data and notes for research
/// ```
///
/// ## Key Features
///
/// - **Multi-source Image Input**: Camera capture and gallery selection
/// - **Real-time Processing**: On-device AI inference with progress indicators
/// - **Rich Results Display**: Species information, confidence scores, inference timing
/// - **Disease Risk Assessment**: Interactive disease list with detailed information
/// - **Research Integration**: Observation submission to CulicidaeLab database
/// - **Error Handling**: Graceful handling of classification and network errors
/// - **Responsive Design**: Adaptive layouts for different screen sizes
///
/// ## Performance Considerations
///
/// - **On-device Processing**: Uses PyTorch Lite for fast, offline classification
/// - **Image Optimization**: Automatic image resizing and preprocessing
/// - **Memory Management**: Efficient image handling and model caching
/// - **Background Processing**: Non-blocking UI during classification
///
/// {@category Screens}
/// {@subCategory Classification}
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../view_models/classification_view_model.dart';
import 'mosquito_detail_screen.dart';
import 'disease_detail_screen.dart';
import '../widgets/custom_empty_widget.dart';
import '../widgets/icomoon_icons.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';
import 'observation_details_screen.dart';

/// Main screen for mosquito species classification and identification.
///
/// This screen provides a comprehensive interface for users to:
/// - **Image Selection**: Choose images from camera or gallery for analysis
/// - **AI Processing**: Real-time classification with progress indicators
/// - **Results Display**: Show species information, confidence scores, and inference timing
/// - **Disease Assessment**: Access detailed information about associated disease risks
/// - **Research Contribution**: Submit observations with location data and notes
///
/// ## State Management Architecture
///
/// The screen uses the Provider pattern with [ClassificationViewModel] to manage
/// complex state transitions and business logic. State flow includes:
///
/// ```
/// Initial → Image Selected → Processing → Results → Submission
///    ↓           ↓             ↓          ↓          ↓
/// Empty UI → Preview → Loading → Species → Success
/// ```
///
/// ## UI State Handling
///
/// The screen dynamically adapts its interface based on current state:
/// - **Empty State**: Shows upload hints and action buttons
/// - **Image Preview**: Displays selected image with analyze button
/// - **Processing State**: Shows loading indicator with progress message
/// - **Results State**: Rich display of classification results and actions
/// - **Submission State**: Success confirmation with submission details
/// - **Error State**: User-friendly error messages with retry options
///
/// ## Interactive Elements
///
/// - **Action Buttons**: Camera, gallery, and reset functionality
/// - **Result Cards**: Expandable cards with species and disease information
/// - **Navigation**: Deep links to species and disease detail screens
/// - **Bottom Sheets**: Modal disease risk information display
/// - **Form Integration**: Observation submission with location and notes
///
/// **Key Features:**
/// - Responsive image capture and selection
/// - Real-time AI classification processing
/// - Comprehensive disease risk assessment
/// - Research-grade observation submission with metadata
class ClassificationScreen extends StatelessWidget {
  const ClassificationScreen({Key? key}) : super(key: key);

  /// Builds the main UI for the classification screen.
  ///
  /// This method creates a responsive layout that adapts to different states:
  /// - Shows upload hints when no image is selected
  /// - Displays image preview during processing
  /// - Shows classification results with species information
  /// - Provides action buttons for camera, gallery, and reset
  ///
  /// The layout uses a [Scaffold] with an [AppBar] and a scrollable body
  /// containing the main content area with image preview and action buttons.
  ///
  /// [context] The build context for accessing theme and localization data.
  /// Returns a [Widget] representing the complete classification screen UI.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<ClassificationViewModel>.value(
      value: locator<ClassificationViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.classificationScreenTitle),
          centerTitle: true,
        ),
        body: Consumer<ClassificationViewModel>(
          builder: (context, viewModel, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: !viewModel.hasImage,
                    maintainState: true,
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.teal,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              localizations.uploadImageHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.uploadImageSubHint,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (!viewModel.hasImage) const SizedBox(height: 16),
                  _buildImagePreview(context, viewModel, localizations),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        viewModel.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (viewModel.state == ClassificationState.success &&
                      viewModel.result != null)
                    _buildResultCard(context, viewModel, localizations)
                  else if (viewModel.state == ClassificationState.submitted &&
                      viewModel.submissionResult != null)
                    _buildSubmissionResult(context, viewModel, localizations),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        _buildActionButton(
                          icon: Icons.camera_alt,
                          label: localizations.cameraButtonLabel,
                          onPressed: () => _getImage(context, viewModel,
                              ImageSource.camera, localizations),
                        ),
                        _buildActionButton(
                          icon: Icons.photo_library,
                          label: localizations.galleryButtonLabel,
                          onPressed: () => _getImage(context, viewModel,
                              ImageSource.gallery, localizations),
                        ),

                        if (viewModel.hasImage)
                          _buildActionButton(
                            icon: Icons.refresh,
                            label: localizations.resetButtonLabel,
                            onPressed: () => viewModel.reset(),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }


  /// Builds the result card displaying classification results.
  ///
  /// Creates a visually appealing card that shows:
  /// - Species name and common name
  /// - Confidence score and inference time
  /// - Action buttons for species info and disease risks
  /// - Navigation to observation details
  ///
  /// The card includes proper styling with rounded corners, elevation,
  /// and color-coded elements for better user experience.
  ///
  /// [context] The build context for theme access.
  /// [viewModel] The classification view model containing result data.
  /// [localizations] Localization strings for UI text.
  /// Returns a [Widget] representing the result card.
Widget _buildResultCard(BuildContext context,
      ClassificationViewModel viewModel, AppLocalizations localizations) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icomoon.mosquitoB, color: Colors.teal, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.speciesLabel(viewModel.result!.species.name),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Text(
                localizations
                    .commonNameLabel(viewModel.result!.species.commonName),
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 4),
                Text(
                  localizations.confidenceLabel(
                      viewModel.result!.confidence.toStringAsFixed(1)),
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  localizations
                      .inferenceTimeLabel(viewModel.result!.inferenceTime),
                  style: const TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    // Changed to OutlinedButton
                    icon: const Icon(Icons.info_outline),
                    label: Text(
                      localizations.speciesInfoButton,
                      textAlign: TextAlign.center, // Center the text
                    ),

                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.teal.shade700, // Dark teal for text and icon
                      side: BorderSide(
                          color: Colors.teal.shade400,
                          width: 1.5), // Teal outline
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MosquitoDetailScreen(
                              species: viewModel.result!.species),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 8),
                if (viewModel.shouldShowDiseaseRiskButton)
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.warning_amber),

                      label: Text(
                        localizations.diseaseRisksButton,
                        textAlign: TextAlign.center, // Center the text
                      ),


                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF38C79),
                          foregroundColor: Colors.white),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.vertical(top: Radius.circular(20))),
                          builder: (context) => DraggableScrollableSheet(
                            initialChildSize: 0.6,
                            minChildSize: 0.3,
                            maxChildSize: 0.9,
                            expand: false,
                            builder: (context, scrollController) {
                              return SingleChildScrollView(
                                controller: scrollController,
                                child: _buildDiseasesList(
                                    context, viewModel, localizations),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt_outlined),

                label:  Text(
                  localizations.addDetailsButton,
                  textAlign: TextAlign.center,
                ),


                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white),
                onPressed: () {
                  viewModel.fetchWebPrediction(localizations);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ObservationDetailsScreen(
                        classificationResult: viewModel.result!,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(BuildContext context,
      ClassificationViewModel viewModel, AppLocalizations localizations) {
    Widget content;
    if (viewModel.isProcessing) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (viewModel.imageFile != null)
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(viewModel.imageFile!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.5),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(localizations.analyzingImage),
        ],
      );
    } else if (viewModel.imageFile != null) {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(viewModel.imageFile!, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          if (viewModel.result == null)
            ElevatedButton.icon(
              icon: const Icon(Icons.search),
              label: Text(localizations.analyzeButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              onPressed: () {
                viewModel.classifyImage(localizations);
              },
            ),
        ],
      );
    } else {
      content = CustomEmptyWidget(
        title: localizations.noImageSelectedTitle,
        subtitle: localizations.noImageSelectedSubtitle,
        titleTextStyle: const TextStyle(
          fontSize: 22,
          color: Color(0xff9da9c7),
          fontWeight: FontWeight.w500,
        ),
        subtitleTextStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xffabb8d6),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(child: content),
    );
  }

  /// Creates a styled action button with icon and label.
  ///
  /// This method generates a column containing a [FloatingActionButton]
  /// with an icon and a text label below it. The button uses a consistent
  /// teal color scheme for visual coherence across the application.
  ///
  /// [icon] The icon to display inside the button.
  /// [label] The text label to show below the button.
  /// [onPressed] The callback function to execute when the button is pressed.
  /// Returns a [Widget] representing the action button with label.
  Widget _buildActionButton(
      {required IconData icon,
      required String label,
      required VoidCallback onPressed}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: label,
          onPressed: onPressed,
          backgroundColor: Colors.teal,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


  /// Builds a list of diseases associated with the identified mosquito species.
  ///
  /// This method creates a scrollable bottom sheet that displays:
  /// - A warning icon and title indicating potential disease risks
  /// - A list of related diseases with descriptions and navigation to detail screens
  /// - A disclaimer about educational use
  ///
  /// Each disease item is displayed as a tappable card that navigates
  /// to the disease detail screen when selected.
  ///
  /// [context] The build context for theme access and navigation.
  /// [viewModel] The classification view model containing disease data.
  /// [localizations] Localization strings for UI text.
  /// Returns a [Widget] representing the diseases list in a scrollable container.
Widget _buildDiseasesList(BuildContext context,
      ClassificationViewModel viewModel, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFF38C79)),
              const SizedBox(width: 8),
              Text(
                localizations.potentialDiseaseRisksTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            localizations.potentialDiseaseRisksSubtitle,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: viewModel.result!.relatedDiseases.length,
            itemBuilder: (context, index) {
              final disease = viewModel.result!.relatedDiseases[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFFF38C79).withOpacity(0.2),
                    child: const Icon(
                      Icons.local_hospital_outlined,
                      color: Color(0xFFF38C79),
                    ),
                  ),
                  title: Text(
                    disease.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    disease.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            DiseaseDetailScreen(disease: disease),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            localizations.disclaimerEducationalUse,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// Handles image selection from camera or gallery.
  ///
  /// This method initiates the image picking process using the provided
  /// [ImageSource] (camera or gallery). After a successful image selection,
  /// it automatically triggers the classification process.
  ///
  /// The method uses a post-frame callback to ensure the image is properly
  /// loaded before starting classification to avoid UI conflicts.
  ///
  /// [context] The build context for UI operations.
  /// [viewModel] The classification view model to handle image processing.
  /// [source] The image source (camera or gallery).
  /// [localizations] Localization strings for potential error messages.
  void _getImage(BuildContext context, ClassificationViewModel viewModel,
      ImageSource source, AppLocalizations localizations) async {
    await viewModel.pickImage(source, localizations);
    if (viewModel.hasImage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (viewModel.hasImage) {
          viewModel.classifyImage(localizations);
        }
      });
    }
  }


  /// Builds the submission result display after successful observation submission.
  ///
  /// Creates a success card showing:
  /// - A checkmark icon indicating successful submission
  /// - Thank you message for participation
  /// - Submission details including ID, species, location, and notes
  /// - Proper styling with teal accent colors
  ///
  /// [context] The build context for theme access.
  /// [viewModel] The classification view model containing submission data.
  /// [localizations] Localization strings for UI text.
  /// Returns a [Widget] representing the submission success card.
Widget _buildSubmissionResult(BuildContext context,
      ClassificationViewModel viewModel, AppLocalizations localizations) {
    final result = viewModel.submissionResult!;
    return Card(
      elevation: 4,
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.teal, size: 50),
            const SizedBox(height: 16),
            Text(
              localizations.thankYouForParticipation,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Divider(),
            _buildInfoRow(
                localizations.submissionIdLabel(result.id), Icons.tag),
            _buildInfoRow(
                localizations.speciesLabel(result.speciesScientificName),
                Icons.bug_report),
            _buildInfoRow(
                "${result.location.lat.toStringAsFixed(4)}, ${result.location.lng.toStringAsFixed(4)}",
                Icons.location_on),
            if (result.notes != null && result.notes!.isNotEmpty)
              _buildInfoRow(result.notes!, Icons.notes),
          ],
        ),
      ),
    );
  }


  /// Creates a row displaying an icon and text for information display.
  ///
  /// This helper method creates a consistent layout for showing
  /// information with an icon and text. Used in the submission result
  /// display to show details like submission ID, species, and location.
  ///
  /// [text] The text content to display.
  /// [icon] The icon to show before the text.
  /// Returns a [Widget] representing a row with icon and text.
Widget _buildInfoRow(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 22),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}