import 'package:flutter/material.dart';
import '../models/disease_model.dart';
import '../models/mosquito_model.dart';
// import '../services/classification_service.dart';
import '../repositories/mosquito_repository.dart';
import 'mosquito_detail_screen.dart';
import '../widgets/icomoon_icons.dart';

import 'package:culicidaelab/l10n/app_localizations.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Disease disease;
  final MosquitoRepository _mosquitoRepository = MosquitoRepository();

  DiseaseDetailScreen({Key? key, required this.disease}) : super(key: key);

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
          appBar: AppBar(title: Text(disease.name)),
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
