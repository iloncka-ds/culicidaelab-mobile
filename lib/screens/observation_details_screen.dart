import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/mosquito_model.dart';
import '../view_models/classification_view_model.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

class ObservationDetailsScreen extends StatefulWidget {
  final ClassificationResult classificationResult;
  const ObservationDetailsScreen({Key? key, required this.classificationResult}) : super(key: key);

  @override
  _ObservationDetailsScreenState createState() => _ObservationDetailsScreenState();
}

class _ObservationDetailsScreenState extends State<ObservationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final TextEditingController _notesController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isLoadingLocation = true;
  LatLng _initialCenter = const LatLng(20.0, 0.0);

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    // This logic remains the same
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _isLoadingLocation = false; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() { _isLoadingLocation = false; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _isLoadingLocation = false; });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialCenter = LatLng(position.latitude, position.longitude);
          _selectedLocation = _initialCenter;
          _isLoadingLocation = false;
          _mapController.move(_initialCenter, 13.0);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoadingLocation = false; });
      }
    }
  }

  void _updateLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _mapController.move(location, _mapController.zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<ClassificationViewModel>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.observationDetailsTitle)),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(localizations.locationSectionTitle, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(localizations.locationInstruction),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _initialCenter,
                            initialZoom: _isLoadingLocation ? 2.0 : 13.0,
                            onTap: (_, latlng) => _updateLocation(latlng),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.culicidaelab.app',
                            ),
                            if (_selectedLocation != null)
                              MarkerLayer(markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  child: Icon(Icons.location_on, color: Colors.red.shade700, size: 40),
                                ),
                              ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: localizations.notesLabel,
                        hintText: localizations.notesHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),

                    Consumer<ClassificationViewModel>(
                      builder: (context, vm, child) {
                        // State 1: Loading (either fetching or submitting)
                        if (vm.isFetchingWebPrediction || vm.isSubmitting) {
                          return Center(
                            child: Column(
                              children: [
                                const CircularProgressIndicator(),
                                const SizedBox(height: 16),
                                Text(
                                  vm.isSubmitting
                                      ? localizations.submittingObservation
                                      : localizations.fetchingWebPrediction,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          );
                        }

                        // State 2: Error has occurred
                        if (vm.errorMessage != null) {
                          return Column(
                            children: [
                              Card(
                                color: Colors.red.shade50,
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text(
                                    vm.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.red.shade900),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // --- THIS IS THE NEW "RETRY" BUTTON ---
                              // It only shows when there's an error.
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh),
                                label: Text(localizations.retryButtonLabel), // Add "Retry" to your .arb files
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade400,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // Simply call the fetch function again.
                                  vm.fetchWebPrediction(localizations);
                                },
                              ),
                            ],
                          );
                        }

                        // State 3: Success. Show the active submit button.
                        return ElevatedButton.icon(
                          icon: const Icon(Icons.cloud_upload),
                          label: Text(localizations.submitObservationButton),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: _selectedLocation == null
                            ? null
                            : () async {
                                final submissionResult = await viewModel.submitObservation(
                                  localResult: widget.classificationResult,
                                  webPrediction: vm.webPredictionResult,
                                  latitude: _selectedLocation!.latitude,
                                  longitude: _selectedLocation!.longitude,
                                  notes: _notesController.text,
                                  localizations: localizations,
                                );

                                if (submissionResult != null && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                        );
                      },
                    )

                  ],
                ),
              ),
            ),
    );
  }
}