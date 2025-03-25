import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_finder/services/api_services/auth_det.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String _errorMessage = '';
  final String baseUrl = AuthDet().baseUrl;

  // Default position (will be updated with user's location)
  CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0), // Default to AB2 but will be changed
    zoom: 18, // Updated from 20 to 18
  );

  @override
  void initState() {
    super.initState();
    // Request location permissions immediately when screen loads
    _requestLocationPermission();
  }

  // Separate method to request permissions
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _errorMessage =
            'Location services are disabled. Please enable GPS in settings.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _errorMessage = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _errorMessage =
            'Location permissions are permanently denied. Please enable in app settings.';
      });
      return;
    }

    // Once permission is granted, fetch location and buildings
    _getUserLocation();
    _fetchBuildings();
  }

  // Get user location
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 18, // Updated from 20 to 18
        );
      });

      // Update camera position if map is already created
      if (_controller.isCompleted) {
        final GoogleMapController controller = await _controller.future;
        controller
            .animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  Future<void> _fetchBuildings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/buildings'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> buildings = jsonDecode(response.body);
        _addMarkers(buildings);
      } else {
        setState(() {
          _errorMessage = 'Failed to load buildings: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _addMarkers(List<dynamic> buildings) {
    setState(() {
      for (var building in buildings) {
        final marker = Marker(
          markerId: MarkerId(building['_id']),
          position: LatLng(
            building['coordinates']['lat'],
            building['coordinates']['lng'],
          ),
          infoWindow: InfoWindow(
            title: building['name'],
            snippet: building['description'] ?? 'No description available',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerHue(building['type'] ?? 'academic')),
        );
        _markers.add(marker);
      }
      _isLoading = false;
    });
  }

  double _getMarkerHue(String type) {
    switch (type.toLowerCase()) {
      case 'academic':
        return BitmapDescriptor.hueBlue;
      case 'hostel':
        return BitmapDescriptor.hueOrange;
      case 'cafeteria':
        return BitmapDescriptor.hueRed;
      case 'sports':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _initialPosition,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled:
              false, // Disable default location button as we're using custom one
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
            // Attempt to get location again after map is created
            _getUserLocation();
          },
        ),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(),
          ),
        if (_errorMessage.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(224),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _markers.clear();
                        _errorMessage = '';
                      });
                      _fetchBuildings();
                    },
                  ),
                ],
              ),
            ),
          ),
        // Add a manual location button for testing
        Positioned(
          bottom: 30,
          right: 16,
          child: FloatingActionButton(
            heroTag: "locateMe",
            backgroundColor: Colors.white,
            onPressed: () {
              _getUserLocation();
            },
            child: Icon(
              Icons.my_location,
              color: Colors.blue[700],
            ),
          ),
        ),
      ],
    );
  }

  // Method that can be called from parent widget to center the map on user location
  Future<void> centerMap() async {
    await _getUserLocation();
  }
}
