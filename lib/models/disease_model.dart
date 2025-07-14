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