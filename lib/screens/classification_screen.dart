import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../view_models/classification_view_model.dart';
import '../models/mosquito_model.dart';
import 'mosquito_detail_screen.dart';
import 'disease_detail_screen.dart';
import '../widgets/custom_empty_widget.dart';
import '../widgets/icomoon_icons.dart';

// Add this import
import 'package:culicidaelab/l10n/app_localizations.dart';

class ClassificationScreen extends StatefulWidget {
  const ClassificationScreen({Key? key}) : super(key: key);

  @override
  _ClassificationScreenState createState() => _ClassificationScreenState();
}

class _ClassificationScreenState extends State<ClassificationScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.classificationScreenTitle)),
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

                _buildImagePreview(viewModel, localizations),

                if (viewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (viewModel.result != null)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icomoon.mosquitoB, color: Colors.teal),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  localizations.speciesLabel(
                                    viewModel.result?.species.name ??
                                        localizations.unknownSpecies,
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.commonNameLabel(
                              viewModel.result?.species.commonName ??
                                  localizations.unknownSpecies,
                            ),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                localizations.confidenceLabel(
                                  viewModel.result?.confidence.toStringAsFixed(
                                        1,
                                      ) ??
                                      "0.0",
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(
                                Icons.timer,
                                color: Colors.blue,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                localizations.inferenceTimeLabel(
                                  viewModel.result?.inferenceTime ?? 0,
                                ),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.info_outline),
                                  label: Text(localizations.speciesInfoButton),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => MosquitoDetailScreen(
                                              species:
                                                  viewModel.result!.species,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (viewModel.shouldShowDiseaseRiskButton)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(
                                      Icons.warning_amber,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      localizations.diseaseRisksButton,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF38C79),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                    onPressed: () {
                                      if (viewModel
                                          .result!
                                          .relatedDiseases
                                          .isNotEmpty) {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                          ),
                                          builder:
                                              (
                                                context,
                                              ) => DraggableScrollableSheet(
                                                initialChildSize: 0.6,
                                                minChildSize: 0.3,
                                                maxChildSize: 0.9,
                                                expand: false,
                                                builder: (
                                                  context,
                                                  scrollController,
                                                ) {
                                                  return SingleChildScrollView(
                                                    controller:
                                                        scrollController,
                                                    child: _buildDiseasesList(
                                                      viewModel,
                                                      localizations,
                                                    ),
                                                  );
                                                },
                                              ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              localizations.noKnownDiseaseRisks,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        label: localizations.cameraButtonLabel,
                        onPressed:
                            () => _getImage(
                              viewModel,
                              ImageSource.camera,
                              localizations,
                            ),
                      ),
                      _buildActionButton(
                        icon: Icons.photo_library,
                        label: localizations.galleryButtonLabel,
                        onPressed:
                            () => _getImage(
                              viewModel,
                              ImageSource.gallery,
                              localizations,
                            ),
                      ),
                      if (viewModel.hasImage)
                        _buildActionButton(
                          icon: Icons.refresh,
                          label: localizations.resetButtonLabel,
                          onPressed: () {
                            viewModel.reset();
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePreview(
    ClassificationViewModel viewModel,
    AppLocalizations localizations,
  ) {
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
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
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDiseasesList(
    ClassificationViewModel viewModel,
    AppLocalizations localizations,
  ) {
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.black87),
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
                    backgroundColor: const Color(0xFFF38C79).withOpacity(0.2),
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
                        builder:
                            (context) => DiseaseDetailScreen(disease: disease),
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

  void _getImage(
    ClassificationViewModel viewModel,
    ImageSource source,
    AppLocalizations localizations,
  ) async {
    await viewModel.pickImage(source, localizations);

    if (viewModel.hasImage && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && viewModel.hasImage) {
          viewModel.classifyImage(localizations);
        }
      });
    }
  }
}
