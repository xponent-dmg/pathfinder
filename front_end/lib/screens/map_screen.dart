import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

  // Update to your campus center coordinates from seedLocations.js
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
        Uri.parse('http://192.168.90.165:3000/api/buildings'),
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
          ),
        );
        _markers.add(marker);
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
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
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.red.withOpacity(0.8),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
