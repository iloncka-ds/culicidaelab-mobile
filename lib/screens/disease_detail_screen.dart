/// DiseaseDetailScreen provides comprehensive information about mosquito-borne diseases.
///
/// This screen displays detailed information about a specific disease including:
/// - Disease overview and description
/// - Symptoms and clinical presentation
/// - Treatment options and medical interventions
/// - Prevention strategies and public health measures
/// - Geographic prevalence and distribution
/// - Vector species that transmit the disease
///
/// The screen fetches related mosquito species data and provides navigation
/// to individual species detail screens for further information.
///
/// {@category Screens}
/// {@subCategory Disease Information}
import 'package:flutter/material.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/models/mosquito_model.dart';

import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'mosquito_detail_screen.dart';
import 'package:culicidaelab/widgets/icomoon_icons.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

import 'package:culicidaelab/locator.dart';

/// Detailed screen displaying comprehensive information about a mosquito-borne disease.
///
/// This screen provides in-depth information about a specific disease, including
/// medical details, transmission vectors, and prevention strategies. It features:
///
/// - **Disease Overview**: Description and background information
/// - **Symptoms**: Clinical presentation and warning signs
/// - **Treatment**: Medical interventions and therapies
/// - **Prevention**: Public health measures and personal protection
/// - **Prevalence**: Geographic distribution and epidemiology
/// - **Vectors**: List of mosquito species that transmit the disease
///
/// The screen uses a [FutureBuilder] to asynchronously load mosquito species
/// data and displays vector information with navigation to species details.
/// Each vector entry shows the species name and provides tap navigation to
/// the [MosquitoDetailScreen] for comprehensive species information.
///
/// **Key Features:**
/// - Comprehensive disease information display
/// - Dynamic vector species loading and display
/// - Interactive navigation to species details
/// - Error handling for missing species data
/// - Responsive layout with proper information hierarchy
class DiseaseDetailScreen extends StatelessWidget {
  final Disease disease;
  final MosquitoRepository _mosquitoRepository = locator<MosquitoRepository>();

  DiseaseDetailScreen({Key? key, required this.disease}) : super(key: key);

  /// Builds the disease detail screen with comprehensive information display.
  ///
  /// This method creates a scrollable layout that includes:
  /// - Disease image with error handling for missing assets
  /// - Detailed sections for description, symptoms, treatment, and prevention
  /// - Geographic prevalence information
  /// - Interactive vector species list with navigation
  /// - Educational use disclaimer
  ///
  /// The layout uses a [FutureBuilder] to asynchronously load mosquito species
  /// data required for the vectors section. During loading, a progress indicator
  /// is shown. The screen includes proper error handling for missing images
  /// and species data.
  ///
  /// [context] The build context for accessing theme and localization data.
  /// Returns a [Widget] representing the complete disease detail screen UI.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return FutureBuilder<List<MosquitoSpecies>>(
      future: _mosquitoRepository.getAllMosquitoSpecies(
        localizations.localeName,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final allSpecies = snapshot.data ?? [];
        final List<MosquitoSpecies> vectors =
            disease.vectors.map((vectorName) {
              final found =
                  allSpecies
                      .where((species) => species.name == vectorName)
                      .toList();
              if (found.isNotEmpty) {
                return found.first;
              } else {
                return MosquitoSpecies(
                  id: 'unknown',
                  name: vectorName,
                  commonName: localizations.diseaseDetailScreenUnknownVector,
                  description:
                      localizations.diseaseDetailScreenInfoNotAvailable,
                  habitat: localizations.unknownSpecies,
                  distribution: localizations.unknownSpecies,
                  imageUrl: 'assets/images/unknown_mosquito.jpg',
                  diseases: [],
                );
              }
            }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(disease.name),
            centerTitle: true,
          ),

          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    disease.imageUrl,
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.red.shade100,
                          child: const Icon(
                            Icons.local_hospital_outlined,
                            size: 80,
                            color: Color(0xFFF38C79),
                          ),
                        ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  localizations.diseaseDetailScreenDescription,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  disease.description,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const Divider(height: 32),

                Text(
                  localizations.diseaseDetailScreenSymptoms,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  disease.symptoms,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const Divider(height: 32),

                Text(
                  localizations.diseaseDetailScreenTreatment,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  disease.treatment,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const Divider(height: 32),

                Text(
                  localizations.diseaseDetailScreenPrevention,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  disease.prevention,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const Divider(height: 32),

                Text(
                  localizations.diseaseDetailScreenPrevalence,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  disease.prevalence,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
                const Divider(height: 32),

                Text(
                  localizations.diseaseDetailScreenTransmittedBy,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                vectors.isEmpty
                    ? Text(
                      localizations.diseaseDetailScreenVectorsNotAvailable,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vectors.length,
                      itemBuilder: (context, index) {
                        final vector = vectors[index];
                        final displayName =
                            vector.commonName ==
                                    localizations
                                        .diseaseDetailScreenUnknownVector
                                ? vector.name
                                : vector.commonName;
                        return ListTile(
                          leading: const Icon(
                            Icomoon.mosquitoB,
                            color: Colors.teal,
                          ),
                          title: Text(displayName),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            final MosquitoSpecies speciesForDetail = allSpecies
                                .firstWhere(
                                  (s) => s.name == vector.name,
                                  orElse: () => vector,
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MosquitoDetailScreen(
                                      species: speciesForDetail,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                const Divider(height: 32),

                Text(
                  localizations.disclaimerEducationalUse,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
