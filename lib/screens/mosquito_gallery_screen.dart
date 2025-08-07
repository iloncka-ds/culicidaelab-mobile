import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../view_models/mosquito_gallery_view_model.dart';
import '../models/mosquito_model.dart';
import 'mosquito_detail_screen.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

class MosquitoGalleryScreen extends StatefulWidget {
  const MosquitoGalleryScreen({Key? key}) : super(key: key);

  @override
  _MosquitoGalleryScreenState createState() => _MosquitoGalleryScreenState();
}

class _MosquitoGalleryScreenState extends State<MosquitoGalleryScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _localizations = AppLocalizations.of(context)!;
        Provider.of<MosquitoGalleryViewModel>(
          context,
          listen: false,
        ).loadMosquitoSpecies(_localizations!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Fallback if context wasn't ready in initState's post frame callback for some reason
    if (_localizations == null && mounted) {
      _localizations = AppLocalizations.of(context)!;
      // Optionally re-trigger load if it depends on _localizations and might not have run
      // This needs careful handling to avoid multiple calls.
      // Provider.of<MosquitoGalleryViewModel>(context, listen: false).loadMosquitoSpecies(_localizations!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = _localizations ?? AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.mosquitoGalleryScreenTitle),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: localizations.searchMosquitoSpeciesHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<MosquitoGalleryViewModel>(
                              context,
                              listen: false,
                            ).updateSearchQuery('');
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                Provider.of<MosquitoGalleryViewModel>(
                  context,
                  listen: false,
                ).updateSearchQuery(value);
              },
            ),
          ),

          Expanded(
            child: Consumer<MosquitoGalleryViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (viewModel.state == GalleryState.error) {
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
                            viewModel.loadMosquitoSpecies(localizations);
                          },
                          child: Text(localizations.retryButton),
                        ),
                      ],
                    ),
                  );
                }

                final filteredSpecies = viewModel.filteredSpecies;

                if (filteredSpecies.isEmpty) {
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
                          localizations.noMosquitoSpeciesFound,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
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

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredSpecies.length,
                  itemBuilder: (context, index) {
                    final species = filteredSpecies[index];
                    return _buildMosquitoCard(species, localizations);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMosquitoCard(
    MosquitoSpecies species,
    AppLocalizations localizations,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MosquitoDetailScreen(species: species),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    species.imageUrl, // The path from your model, e.g., "assets/images/species/aedes_aegypti.jpg"
                    fit: BoxFit.cover,

                    // Optional - an error handler for missing assets
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.black.withOpacity(0.5),
                      child: Text(
                        species.name, // From model
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonName, // From model
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.habitatLabel(species.habitat),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber,
                        size: 16,
                        color:
                            species.diseases.isNotEmpty
                                ? Colors.red.shade300
                                : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          localizations.diseaseVectorsCount(
                            species.diseases.length,
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                species.diseases.isNotEmpty
                                    ? Colors.red.shade300
                                    : Colors.grey,
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
          ],
        ),
      ),
    );
  }
}
