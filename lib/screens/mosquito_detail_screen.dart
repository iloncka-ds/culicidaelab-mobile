import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import '../view_models/disease_info_view_model.dart';
import 'disease_detail_screen.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

class MosquitoDetailScreen extends StatefulWidget {
  final MosquitoSpecies species;

  const MosquitoDetailScreen({Key? key, required this.species})
    : super(key: key);

  @override
  _MosquitoDetailScreenState createState() => _MosquitoDetailScreenState();
}

class _MosquitoDetailScreenState extends State<MosquitoDetailScreen> {
  List<Disease> _relatedDiseases = [];
  bool _isLoading = true;
  // To store AppLocalizations instance once available
  AppLocalizations? _localizations;

  @override
  void initState() {
    super.initState();
    // Defer _loadRelatedDiseases until after the first frame when context is fully available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _localizations = AppLocalizations.of(context)!; // Initialize here
        _loadRelatedDiseases();
      }
    });
  }

  // Fallback or alternative initialization if initState timing is an issue
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_localizations == null) {
      _localizations = AppLocalizations.of(context)!;
      // If _loadRelatedDiseases hasn't run yet due to _localizations being null in initState
      if (_isLoading && widget.species != null) {
        // _loadRelatedDiseases(); // Be careful not to call multiple times
      }
    }
  }

  Future<void> _loadRelatedDiseases() async {
    // Ensure _localizations is initialized before use
    final localizations = _localizations ?? AppLocalizations.of(context)!;

    final viewModel = Provider.of<DiseaseInfoViewModel>(context, listen: false);

    if (viewModel.state != DiseaseInfoState.loaded) {
      await viewModel.loadDiseases(localizations); // Pass localizations
    }

    // Pass localizations for getDiseasesByVector as well
    final diseases = await viewModel.getDiseasesByVector(
      widget.species.name,
      localizations,
    );

    if (mounted) {
      setState(() {
        _relatedDiseases = diseases;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use the stored _localizations or get it fresh
    final localizations = _localizations ?? AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.species.commonName), // From model data
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),

              child: Image.asset(
                widget.species.imageUrl, 
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // This widget is shown if the asset path is wrong or the file is missing.
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
              widget.species.name, // From model
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              widget.species.commonName, // From model
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
              widget.species.description, // From model
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),

            Text(
              localizations.mosquitoDetailScreenHabitat,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.species.habitat, // From model
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),

            Text(
              localizations.mosquitoDetailScreenDistribution,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.species.distribution, // From model
              style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
            ),
            const Divider(height: 32),

            Text(
              localizations.mosquitoDetailScreenAssociatedDiseases,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),

            _isLoading
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
                : _relatedDiseases.isEmpty
                ? Text(
                  localizations.mosquitoDetailScreenNoAssociatedDiseases,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                )
                : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _relatedDiseases.length,
                  itemBuilder: (context, index) {
                    final disease = _relatedDiseases[index];
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
                        title: Text(disease.name), // From model
                        subtitle: Text(
                          disease.description, // From model
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      DiseaseDetailScreen(disease: disease),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
          ],
        ),
      ),
    );
  }
}
