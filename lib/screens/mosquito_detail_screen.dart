/// MosquitoDetailScreen displays comprehensive information about mosquito species.
///
/// This screen provides detailed information about a specific mosquito species including:
/// - Species identification and taxonomy
/// - Physical description and characteristics
/// - Habitat preferences and geographic distribution
/// - Disease transmission capabilities and associated diseases
/// - Navigation to detailed disease information
///
/// The screen uses asynchronous data loading for disease associations and provides
/// an intuitive interface for exploring mosquito-borne disease relationships.
///
/// {@category Screens}
/// {@subCategory Species Information}
import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:flutter/material.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import 'disease_detail_screen.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';

/// Detailed screen displaying comprehensive mosquito species information.
///
/// This screen provides in-depth information about a specific mosquito species,
/// serving as a reference for identification and understanding disease vectors.
/// Key information includes:
///
/// - **Species Overview**: Scientific and common names with visual identification
/// - **Description**: Physical characteristics and behavioral traits
/// - **Habitat**: Environmental preferences and breeding sites
/// - **Distribution**: Geographic range and regional presence
/// - **Disease Associations**: List of diseases transmitted by this species
///
/// The screen uses a [FutureBuilder] to asynchronously load associated diseases
/// and displays them in an interactive list with navigation to disease details.
/// Each disease entry shows the disease name, description, and provides tap
/// navigation to the [DiseaseDetailScreen] for comprehensive medical information.
///
/// **Key Features:**
/// - Visual species identification with image display
/// - Comprehensive species information sections
/// - Dynamic disease association loading
/// - Interactive disease list with navigation
/// - Error handling for missing images and data
/// - Consistent styling with proper information hierarchy
class MosquitoDetailScreen extends StatelessWidget {
  final MosquitoSpecies species;

  const MosquitoDetailScreen({Key? key, required this.species})
      : super(key: key);

  /// Builds the mosquito species detail screen with comprehensive information.
  ///
  /// Creates a scrollable layout displaying:
  /// - Species image with error handling for missing assets
  /// - Scientific and common names
  /// - Detailed sections for description, habitat, and distribution
  /// - Associated diseases list with interactive navigation
  /// - Proper loading states and error handling
  ///
  /// The layout uses a [FutureBuilder] to asynchronously load disease data
  /// associated with this mosquito species. During loading, a progress indicator
  /// is shown in the diseases section.
  ///
  /// [context] The build context for accessing theme and localization data.
  /// Returns a [Widget] representing the complete mosquito detail screen UI.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mosquitoRepository = locator<MosquitoRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(species.commonName),
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
                species.imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              species.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              species.commonName,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Divider(height: 32),
            Text(
              localizations.mosquitoDetailScreenDescription,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              species.description,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),
            Text(
              localizations.mosquitoDetailScreenHabitat,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              species.habitat,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),
            Text(
              localizations.mosquitoDetailScreenDistribution,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              species.distribution,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),
            Text(
              localizations.mosquitoDetailScreenAssociatedDiseases,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Disease>>(
              future: mosquitoRepository.getDiseasesByVector(
                  species.name, localizations.localeName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                final relatedDiseases = snapshot.data ?? [];
                if (relatedDiseases.isEmpty) {
                  return Text(
                    localizations.mosquitoDetailScreenNoAssociatedDiseases,
                    style:
                        TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: relatedDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = relatedDiseases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF38C79),
                          child: Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        title: Text(disease.name),
                        subtitle: Text(
                          disease.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
