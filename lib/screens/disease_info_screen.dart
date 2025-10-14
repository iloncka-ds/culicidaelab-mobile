/// DiseaseInfoScreen displays a searchable gallery of mosquito-borne diseases.
///
/// This screen provides users with a comprehensive, searchable collection of
/// disease information including:
/// - Searchable list with real-time filtering
/// - Disease cards with images, descriptions, and key information
/// - Vector species information for each disease
/// - Geographic prevalence data
/// - Navigation to detailed disease information screens
///
/// The screen uses a [DiseaseInfoViewModel] for state management and implements
/// a search-as-you-type functionality for improved user experience.
///
/// {@category Screens}
/// {@subCategory Disease Information}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:culicidaelab/models/disease_model.dart';
import 'package:culicidaelab/view_models/disease_info_view_model.dart';
import 'disease_detail_screen.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:culicidaelab/widgets/icomoon_icons.dart';
// import '../widgets/custom_empty_widget.dart'; // Not directly used, but available

// Add this import
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';

/// Searchable gallery screen for browsing mosquito-borne diseases.
///
/// This screen provides an interactive interface for exploring disease information:
///
/// - **Search Functionality**: Real-time search with query filtering
/// - **Disease Cards**: Visual cards showing disease images, names, and descriptions
/// - **Vector Information**: Display of mosquito species that transmit each disease
/// - **Prevalence Data**: Geographic distribution information
/// - **Error Handling**: Proper loading states and error recovery
/// - **Empty States**: Helpful messaging when no results are found
///
/// The screen uses the Provider pattern with [DiseaseInfoViewModel] for state
/// management. It loads disease data on initialization and provides search
/// functionality that filters results based on user input.
///
/// **Key Features:**
/// - Real-time search with debounced filtering
/// - Visual disease cards with images and key information
/// - Loading states and error handling
/// - Empty state messaging for better UX
/// - Navigation to detailed disease screens
class DiseaseInfoScreen extends StatelessWidget {
  const DiseaseInfoScreen({Key? key}) : super(key: key);

  /// Builds the main UI for the disease information screen.
  ///
  /// Creates a responsive layout with:
  /// - App bar with screen title
  /// - Search text field for filtering diseases
  /// - List/Grid view of disease cards based on search results
  /// - Loading, error, and empty state handling
  ///
  /// The layout uses [Consumer] widgets to react to state changes in the
  /// [DiseaseInfoViewModel] and updates the UI accordingly.
  ///
  /// [context] The build context for accessing theme and localization data.
  /// Returns a [Widget] representing the complete disease info screen UI.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final searchController = TextEditingController();

    return ChangeNotifierProvider<DiseaseInfoViewModel>.value(
      value: locator<DiseaseInfoViewModel>()..loadDiseases(localizations),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.diseaseInfoScreenTitle),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<DiseaseInfoViewModel>(
                builder: (context, viewModel, child) {
                  return TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: localizations.searchDiseasesHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                viewModel.updateSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      viewModel.updateSearchQuery(value);
                    },
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<DiseaseInfoViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (viewModel.state == DiseaseInfoState.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            viewModel.errorMessage ??
                                localizations.anErrorOccurred,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              viewModel.loadDiseases(localizations);
                            },
                            child: Text(localizations.retryButton),
                          ),
                        ],
                      ),
                    );
                  }

                  final filteredDiseases = viewModel.filteredDiseases;

                  if (filteredDiseases.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.noDiseasesFound,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (searchController.text.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                localizations.tryDifferentSearchTerm,
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredDiseases.length,
                    itemBuilder: (context, index) {
                      final disease = filteredDiseases[index];
                      return _buildDiseaseCard(context, disease, localizations);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a disease information card for the gallery view.
  ///
  /// Builds an interactive card displaying:
  /// - Disease image with error handling
  /// - Disease name and description
  /// - Vector species information
  /// - Geographic prevalence data
  /// - Tap navigation to disease detail screen
  ///
  /// The card uses proper styling with rounded corners, elevation,
  /// and appropriate spacing for a clean, professional appearance.
  ///
  /// [context] The build context for navigation and theme access.
  /// [disease] The disease model containing information to display.
  /// [localizations] Localization strings for UI text.
  /// Returns a [Widget] representing a single disease information card.
  Widget _buildDiseaseCard(
      BuildContext context, Disease disease, AppLocalizations localizations) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiseaseDetailScreen(disease: disease),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // Image.asset for local files
                child: Image.asset(
                  disease.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,

                  // errorBuilder to handle cases where the asset is not found
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.red.shade100,
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.red,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      disease.name, // From model
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      disease.description, // From model
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icomoon.mosquitoB,
                          size: 16,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            localizations.vectorsLabel(
                              disease.vectors.join(", "),
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.public, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            localizations.prevalenceLabel(disease.prevalence),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.teal, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
