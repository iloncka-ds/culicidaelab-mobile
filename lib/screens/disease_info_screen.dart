import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/disease_model.dart';
import '../view_models/disease_info_view_model.dart';
import 'disease_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/icomoon_icons.dart';
// import '../widgets/custom_empty_widget.dart'; // Not directly used, but available

// Add this import
import 'package:culicidaelab/l10n/app_localizations.dart';

class DiseaseInfoScreen extends StatefulWidget {
  const DiseaseInfoScreen({Key? key}) : super(key: key);

  @override
  _DiseaseInfoScreenState createState() => _DiseaseInfoScreenState();
}

class _DiseaseInfoScreenState extends State<DiseaseInfoScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _localizations = AppLocalizations.of(context)!;
        Provider.of<DiseaseInfoViewModel>(
          context,
          listen: false,
        ).loadDiseases(_localizations!);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizations == null && mounted) {
      _localizations = AppLocalizations.of(context)!;
      // Provider.of<DiseaseInfoViewModel>(context, listen: false).loadDiseases(_localizations!);
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
      appBar: AppBar(title: Text(localizations.diseaseInfoScreenTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
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
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            Provider.of<DiseaseInfoViewModel>(
                              context,
                              listen: false,
                            ).updateSearchQuery('');
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                Provider.of<DiseaseInfoViewModel>(
                  context,
                  listen: false,
                ).updateSearchQuery(value);
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = filteredDiseases[index];
                    return _buildDiseaseCard(disease, localizations);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(Disease disease, AppLocalizations localizations) {
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

              const Icon(Icons.arrow_forward_ios, color: Colors.teal, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
