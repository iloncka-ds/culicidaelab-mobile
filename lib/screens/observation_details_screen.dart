/// ObservationDetailsScreen allows users to submit mosquito observation data.
///
/// This screen enables users to contribute to the mosquito surveillance database by:
/// - Selecting observation location using an interactive map
/// - Adding optional notes about the observation
/// - Submitting classification results with location data
/// - Handling location permissions and GPS functionality
///
/// The screen uses geolocation services to get the user's current position and
/// provides an interactive map interface for precise location selection.
///
/// {@category Screens}
/// {@subCategory Observation Management}
import 'package:culicidaelab/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/mosquito_model.dart';
import '../view_models/classification_view_model.dart';
import 'package:culicidaelab/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

/// Screen for collecting and submitting mosquito observation details.
///
/// This stateful screen provides a comprehensive interface for users to:
///
/// - **Location Selection**: Interactive map with current location detection
/// - **Observation Notes**: Optional text field for additional context
/// - **Data Submission**: Integration with classification results for database storage
/// - **Permission Handling**: Location services permission management
/// - **Error Handling**: Graceful handling of location and submission errors
///
/// The screen uses the [ClassificationViewModel] to manage submission state and
/// integrates with geolocation services for precise positioning. It features a
/// map interface built with [flutter_map] for location selection and includes
/// proper loading states during submission processes.
///
/// **Key Features:**
/// - Interactive map interface for location selection
/// - GPS location detection and permission handling
/// - Optional notes field for observation context
/// - Integration with classification results
/// - Loading states during web prediction and submission
/// - Error handling with retry functionality
/// - Responsive form validation and submission
class ObservationDetailsScreen extends StatefulWidget {
  final ClassificationResult classificationResult;
  const ObservationDetailsScreen({Key? key, required this.classificationResult}) : super(key: key);

  @override
  _ObservationDetailsScreenState createState() => _ObservationDetailsScreenState();
}

/// State class managing the observation details screen functionality.
///
/// Handles location services, map interactions, form validation, and
/// observation submission. Manages the complex state transitions between
/// location detection, web prediction fetching, and final submission.
class _ObservationDetailsScreenState extends State<ObservationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final TextEditingController _notesController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isLoadingLocation = true;
  LatLng _initialCenter = const LatLng(12.6392, -8.0028); // Bamako, Mali

  /// Initializes the screen state and begins location detection.
  ///
  /// This method is called when the screen is first created and starts
  /// the location permission and positioning process. It handles the
  /// initial setup of location services and map positioning.

  /// Determines the user's current position using geolocation services.
  ///
  /// This method handles the complete location permission and positioning workflow:
  /// - Checks if location services are enabled
  /// - Requests location permissions if needed
  /// - Gets current position and updates map center
  /// - Handles permission denials and service unavailability
  ///
  /// Uses the Geolocator package to access device GPS capabilities and
  /// updates the UI state accordingly. Falls back to default coordinates
  /// if location services are unavailable.
  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
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

  /// Updates the selected location when user taps on the map.
  ///
  /// This method handles map tap interactions, updating both the selected
  /// location state and the map camera position to center on the tapped point.
  /// It ensures the map stays synchronized with user selections.
  ///
  /// [location] The LatLng coordinates of the tapped map position.
  void _updateLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _mapController.move(location, _mapController.camera.zoom);
    });
  }

  /// Builds the observation details form with map and submission interface.
  ///
  /// Creates a comprehensive form interface featuring:
  /// - Interactive map for location selection
  /// - Current location detection and display
  /// - Optional notes field for observation context
  /// - Submission button with loading states
  /// - Error handling and retry functionality
  ///
  /// The layout uses a scrollable form with proper validation and state
  /// management through the ClassificationViewModel. It handles complex
  /// state transitions between location detection, web prediction, and submission.
  ///
  /// [context] The build context for accessing theme and localization data.
  /// Returns a [Widget] representing the complete observation form UI.
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return ChangeNotifierProvider<ClassificationViewModel>.value(
      value: locator<ClassificationViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(localizations.observationDetailsTitle),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
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
                    child: _isLoadingLocation
                        ? const Center(child: CircularProgressIndicator())
                        : FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _initialCenter,
                              initialZoom: _isLoadingLocation ? 2.0 : 13.0,
                              onTap: (_, latlng) => _updateLocation(latlng),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.culicidaelab.app',
                              ),
                              if (_selectedLocation != null)
                                MarkerLayer(markers: [
                                  Marker(
                                    point: _selectedLocation!,
                                    child: Icon(Icons.location_on,
                                        color: Colors.red.shade700, size: 40),
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
                                style:
                                    TextStyle(color: Colors.red.shade900),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          ElevatedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: Text(localizations
                                .retryButtonLabel), // Add "Retry" to your .arb files
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade400,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              // Call the fetch function again.
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _selectedLocation == null
                          ? null
                          : () async {
                              final submissionResult =
                                  await vm.submitObservation(
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
      ),
    );
  }
}
