import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:path_finder/services/supabase_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:path_finder/providers/event_provider.dart';

class OpenMapPage extends StatefulWidget {
  const OpenMapPage({super.key});

  @override
  State<OpenMapPage> createState() => _OpenMapPageState();
}

class _OpenMapPageState extends State<OpenMapPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;
  String _errorMessage = '';

  Map<String, dynamic>? _selectedLocation;
  bool _showLocationDetails = false;
  List<Map<String, dynamic>> _locationEvents = [];
  bool _loadingEvents = false;

  double _bottomSheetHeight = 0.0;
  final double _initialBottomSheetHeight = 300.0;

  final List<String> _categories = [
    "All",
    "Academics",
    "Hostel",
    "Sports",
    "Eateries",
    "Shopping",
    "Others",
  ];

  String _selectedCategory = 'Academics';

  latlong.LatLng _initialPosition =
      const latlong.LatLng(12.84401131611071, 80.15341209566053);
  latlong.LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _bottomSheetHeight = _initialBottomSheetHeight;

    _requestLocationPermission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      if (eventProvider.eventList.isEmpty) {
        eventProvider.fetchAllEvents();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted)
        setState(() {
          _errorMessage = 'Location services disabled.';
        });
      _fetchBuildings('All');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted)
          setState(() {
            _errorMessage = 'Location permissions denied.';
          });
        _fetchBuildings('All');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        setState(() {
          _errorMessage = 'Location permissions permanently denied.';
        });
      _fetchBuildings('All');
      return;
    }

    _getUserLocation();
    _fetchBuildings('All');
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _userLocation = latlong.LatLng(position.latitude, position.longitude);
          _initialPosition = _userLocation!;
        });
        _mapController.move(_initialPosition, 18.0);
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _errorMessage = 'Error getting location: $e';
        });
    }
  }

  Future<void> _fetchBuildings(String category) async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final buildings =
          await SupabaseService().getBuildings(category: category);
      _addMarkers(List<Map<String, dynamic>>.from(buildings));
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _addMarkers(List<Map<String, dynamic>> buildings) {
    if (!mounted) return;
    setState(() {
      _markers.clear();
      for (var building in buildings) {
        if (_selectedCategory != 'All' &&
            building['category']?.toLowerCase() !=
                _selectedCategory.toLowerCase()) {
          continue;
        }

        final latValue = building['lat'];
        final lngValue = building['lng'];
        final lat = latValue is String
            ? double.tryParse(latValue) ?? 0.0
            : (latValue as num?)?.toDouble() ?? 0.0;
        final lng = lngValue is String
            ? double.tryParse(lngValue) ?? 0.0
            : (lngValue as num?)?.toDouble() ?? 0.0;

        final marker = Marker(
          point: latlong.LatLng(lat, lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              _onMarkerTapped(building);
            },
            child: Icon(
              Icons.location_on,
              color: _getMarkerColor(building['category'] ?? 'others'),
              size: 40,
            ),
          ),
        );
        _markers.add(marker);
      }
      _isLoading = false;
    });
  }

  Color _getMarkerColor(String type) {
    switch (type.toLowerCase()) {
      case 'academics':
        return Colors.red;
      case 'hostel':
        return Colors.orange;
      case 'sports':
        return Colors.green;
      case 'eateries':
        return Colors.cyan;
      case 'shopping':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  void _onMarkerTapped(Map<String, dynamic> location) {
    setState(() {
      _selectedLocation = location;
      _showLocationDetails = true;
      _loadingEvents = true;
      _locationEvents = [];
      _bottomSheetHeight = _initialBottomSheetHeight;
    });

    _fetchLocationEvents(location['name']);
  }

  Future<void> _fetchLocationEvents(String locationName) async {
    if (!mounted) return;
    setState(() => _loadingEvents = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final eventProvider = Provider.of<EventProvider>(context, listen: false);

      if (eventProvider.eventList.isEmpty) {
        await eventProvider.fetchAllEvents();
      }

      final locationEvents = eventProvider.eventList.where((event) {
        return event['location']?.toString().toLowerCase() ==
                locationName.toLowerCase() ||
            event['roomno']?.toString().toLowerCase() ==
                locationName.toLowerCase();
      }).toList();

      if (mounted) {
        setState(() {
          _locationEvents = locationEvents;
          _loadingEvents = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationEvents = [];
          _loadingEvents = false;
        });
      }
    }
  }

  void _filterMarkersByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _markers.clear();
      _isLoading = true;
      _showLocationDetails = false;
    });

    _fetchBuildings(category);
  }

  void _onViewEventButtonPressed(Map<String, dynamic> event) {
    Navigator.pushNamed(context, '/event_page', arguments: event);
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialPosition,
              initialZoom: 18.0,
              onTap: (tapPosition, point) {
                setState(() => _showLocationDetails = false);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.path_finder',
              ),
              MarkerLayer(
                markers: [
                  ..._markers,
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4)
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Icon(Icons.search,
                            color: Colors.blue[700], size: 24),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for places...',
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () =>
                              setState(() => _searchController.clear()),
                        ),
                    ],
                  ),
                ),

                // Categories
                Container(
                  height: 50,
                  margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      return GestureDetector(
                        onTap: () => _filterMarkersByCategory(category),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[700] : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(_errorMessage,
                            style: const TextStyle(color: Colors.white))),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _isLoading = true;
                          _markers.clear();
                          _errorMessage = '';
                        });
                        _requestLocationPermission();
                      },
                    ),
                  ],
                ),
              ),
            ),
          if (_showLocationDetails && _selectedLocation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    double newHeight = _bottomSheetHeight - details.delta.dy;
                    _bottomSheetHeight = newHeight.clamp(
                        _initialBottomSheetHeight,
                        MediaQuery.of(context).size.height * 0.7);
                  });
                },
                onVerticalDragEnd: (details) {
                  setState(() {
                    final double smallHeight = _initialBottomSheetHeight;
                    final double largeHeight =
                        MediaQuery.of(context).size.height * 0.6;
                    _bottomSheetHeight = _bottomSheetHeight > smallHeight
                        ? largeHeight
                        : smallHeight;
                  });
                },
                child: Container(
                  height: _bottomSheetHeight,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -2))
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              radius: 24,
                              child: Icon(Icons.place,
                                  color: Colors.blue[700], size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_selectedLocation!['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  if (_selectedLocation!['category'] != null)
                                    Text(
                                        _capitalizeFirstLetter(
                                            _selectedLocation!['category']),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => setState(
                                    () => _showLocationDetails = false)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Divider(
                          thickness: 1,
                          height: 1,
                          color: Colors.grey[200],
                          indent: 35,
                          endIndent: 35),
                      const SizedBox(height: 10),
                      _loadingEvents
                          ? Container(
                              height: 150,
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator())
                          : _locationEvents.isEmpty
                              ? Container(
                                  height: 150,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.event_busy,
                                          size: 48, color: Colors.grey[400]),
                                      const SizedBox(height: 12),
                                      Text('No events at this location',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16)),
                                    ],
                                  ),
                                )
                              : Expanded(
                                  child: ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    itemCount: _locationEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = _locationEvents[index];
                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 6),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.all(12),
                                          title: Text(
                                              event['name'] ?? "no name",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Text(
                                                  '${event['date']} • ${event['time']}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600])),
                                              const SizedBox(height: 2),
                                              Text(
                                                  'Organized by ${event['clubName']}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600])),
                                            ],
                                          ),
                                          trailing: ElevatedButton(
                                            onPressed: () =>
                                                _onViewEventButtonPressed(
                                                    event),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue[700],
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                            child: const Text('View'),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
