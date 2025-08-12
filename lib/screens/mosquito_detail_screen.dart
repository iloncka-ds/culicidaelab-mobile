import 'package:culicidaelab/repositories/mosquito_repository.dart';
import 'package:flutter/material.dart';
import '../models/mosquito_model.dart';
import '../models/disease_model.dart';
import 'disease_detail_screen.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:culicidaelab/locator.dart';

class MosquitoDetailScreen extends StatelessWidget {
  final MosquitoSpecies species;

  const MosquitoDetailScreen({Key? key, required this.species})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final mosquitoRepository = locator<MosquitoRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(species.commonName),
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
