import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_finder/services/api_services/auth_det.dart';

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

  // Update to your campus center coordinates
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(12.84401131611071, 80.15341209566053), // Center at AB1
    zoom: 17, // Set closer zoom for campus view
  );

  @override
  void initState() {
    super.initState();
    _fetchBuildings();
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
              false, // We'll handle this in the parent widget
          zoomControlsEnabled: false,
          compassEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
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
      ],
    );
  }

  // Method that can be called from parent widget to center the map
  Future<void> centerMap() async {
    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
  }
}
