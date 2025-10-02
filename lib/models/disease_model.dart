/// Represents a disease that can be transmitted by mosquitoes or other vectors.
///
/// This model contains comprehensive information about a specific disease including
/// its symptoms, treatment options, prevention methods, and associated vectors.
/// It's used throughout the application to display disease information to users
/// and provide context for mosquito identification results.
class Disease {
  final String id;
  final String name;
  final String description;
  final String symptoms;
  final String treatment;
  final String prevention;
  final List<String> vectors;
  final String prevalence;
  final String imageUrl;

  Disease({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.treatment,
    required this.prevention,
    required this.vectors,
    required this.prevalence,
    required this.imageUrl,
  });
}