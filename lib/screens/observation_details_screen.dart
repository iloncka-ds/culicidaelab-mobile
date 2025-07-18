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
  // State for loading and initial position
  bool _isLoadingLocation = true;
  LatLng _initialCenter = const LatLng(20.0, 0.0); // Default fallback

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  /// Determines the current position of the device.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle the case where location services are disabled
      setState(() { _isLoadingLocation = false; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where permissions are denied
        setState(() { _isLoadingLocation = false; });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case where permissions are permanently denied
      setState(() { _isLoadingLocation = false; });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialCenter = LatLng(position.latitude, position.longitude);
        _selectedLocation = _initialCenter; // Pre-select the current location
        _isLoadingLocation = false;
        _mapController.move(_initialCenter, 13.0);
      });
    } catch (e) {
      // Handle any other errors
      setState(() { _isLoadingLocation = false; });
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
    final viewModel = Provider.of<ClassificationViewModel>(context, listen: false);
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
                    Container(
                      height: 350,
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
                            userAgentPackageName: 'com.example.culicidaelab', // Use your package name
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(markers: [
                              Marker(
                                point: _selectedLocation!,
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            ]),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: localizations.notesLabel,
                        hintText: localizations.notesHint,
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    Consumer<ClassificationViewModel>(
                      builder: (context, vm, child) {
                        if (vm.isSubmitting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return ElevatedButton.icon(
                          icon: Icon(Icons.cloud_upload),
                          label: Text(localizations.submitObservationButton),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (_selectedLocation == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations.locationRequiredError)));
                              return;
                            }

                            final submissionResult = await viewModel.submitObservation(
                              result: widget.classificationResult,
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