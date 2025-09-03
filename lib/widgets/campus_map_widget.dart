import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart'; // Added for MissingPluginException
import 'package:flutter/foundation.dart'; // Added for gesture recognizers
import 'package:flutter/gestures.dart'; // Added for gesture recognizers
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../models/location_model.dart';

class CampusMapWidget extends StatefulWidget {
  final List<Location> locations;
  final Function(Location) onLocationTapped;
  final String? googleMapsApiKey;
  final String searchQuery;

  const CampusMapWidget({
    super.key,
    required this.locations,
    required this.onLocationTapped,
    this.googleMapsApiKey,
    this.searchQuery = '',
  });

  @override
  State<CampusMapWidget> createState() => _CampusMapWidgetState();
}

class _CampusMapWidgetState extends State<CampusMapWidget>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Location? _selectedLocation;
  bool _isMapLoaded = false;
  String _selectedCategory = 'All';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  MapType _currentMapType = MapType.normal;

  static const String _mapStyle = '''
  [
    {
      "featureType": "poi",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.business",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.government",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.medical",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.park",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.place_of_worship",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.school",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.sports_complex",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels",
      "stylers": [{"visibility": "simplified"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _getCampusCenter(),
              zoom: 16,
            ),
            markers: _buildMarkers(),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            rotateGesturesEnabled: true,
            minMaxZoomPreference: const MinMaxZoomPreference(8.0, 25.0),
            mapType: _currentMapType,
            style: _mapStyle,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            onCameraMoveStarted: () {
              // Camera movement started - can be used for feedback
            },
            onCameraMove: (CameraPosition position) {
              // Camera is moving - ensures smooth gesture tracking
            },
            onCameraIdle: () {
              // Camera movement finished - can be used for cleanup
            },
            onMapCreated: (controller) async {
              _mapController = controller;
              await _mapController!.setMapStyle(_mapStyle);
              
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  _mapController!.animateCamera(
                    CameraUpdate.newLatLngBounds(
                      _getCampusBounds(),
                      100.0,
                    ),
                  );
                  setState(() {
                    _isMapLoaded = true;
                  });
                  _fabAnimationController.forward();
                }
              });
            },
            onTap: (LatLng position) {
              setState(() {
                _selectedLocation = null;
              });
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: _buildCategoryFilter(),
          ),

          Positioned(
            bottom: 100,
            right: 16,
            child: AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _fabAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: "recenter",
                        mini: true,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[700],
                        elevation: 4,
                        onPressed: _recenterMap,
                        child: const Icon(Icons.center_focus_strong),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: "location",
                        mini: true,
                        backgroundColor: _isLoadingLocation ? Colors.grey[300] : Colors.white,
                        foregroundColor: _isLoadingLocation ? Colors.grey[600] : Colors.blue[700],
                        elevation: 4,
                        onPressed: _isLoadingLocation ? null : _goToMyLocation,
                        child: _isLoadingLocation 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                              ),
                            )
                          : const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 12),
                      FloatingActionButton(
                        heroTag: "toggle",
                        mini: true,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[700],
                        elevation: 4,
                        onPressed: _toggleMapType,
                        child: const Icon(Icons.layers),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (_selectedLocation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildLocationDetailsSheet(),
            ),

          if (!_isMapLoaded)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading Campus Map...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...widget.locations.map((l) => l.category).toSet()];
    
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories.elementAt(index);
          final isSelected = _selectedCategory == category;
          
          return Padding(
            padding: EdgeInsets.only(right: 8, left: index == 0 ? 0 : 0),
            child: FilterChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.blue[600],
              elevation: isSelected ? 4 : 2,
              shadowColor: Colors.blue.withOpacity(0.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationDetailsSheet() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_selectedLocation!.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(_selectedLocation!.category),
                    color: _getCategoryColor(_selectedLocation!.category),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation!.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedLocation!.category,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedLocation = null;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _openGoogleMaps(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      );
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      widget.onLocationTapped(_selectedLocation!);
                    },
                    icon: const Icon(Icons.info_outline),
                    label: const Text('More Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LatLng _getCampusCenter() {
    if (widget.locations.isEmpty) {
      return LatLng(12.9716, 79.1628);
    }
    final avgLat = widget.locations
            .map((l) => l.latitude)
            .reduce((a, b) => a + b) /
        widget.locations.length;
    final avgLng = widget.locations
            .map((l) => l.longitude)
            .reduce((a, b) => a + b) /
        widget.locations.length;
    return LatLng(avgLat, avgLng);
  }

  LatLngBounds _getCampusBounds() {
    final center = _getCampusCenter();
    const delta = 0.027;
    return LatLngBounds(
      southwest: LatLng(center.latitude - delta, center.longitude - delta),
      northeast: LatLng(center.latitude + delta, center.longitude + delta),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    
    bool shouldShowMarkers = _selectedCategory != 'All' || widget.searchQuery.trim().isNotEmpty;
    
    if (shouldShowMarkers) {
      List<Location> filteredLocations = widget.locations;
      
      // Apply category filter if not "All"
      if (_selectedCategory != 'All') {
        filteredLocations = filteredLocations.where((l) => l.category == _selectedCategory).toList();
      }
      
      if (widget.searchQuery.trim().isNotEmpty) {
        final searchQuery = widget.searchQuery.trim().toLowerCase();
        print('[v0] Searching for: "$searchQuery"'); // Debug log
        
        filteredLocations = filteredLocations.where((location) {
          final locationName = location.name.toLowerCase().trim();
          final locationCategory = location.category.toLowerCase().trim();
          
          // Check if search query matches name or category (partial match)
          final nameMatch = locationName.contains(searchQuery);
          final categoryMatch = locationCategory.contains(searchQuery);
          
          print('[v0] Location: ${location.name}, Name match: $nameMatch, Category match: $categoryMatch'); // Debug log
          
          return nameMatch || categoryMatch;
        }).toList();
        
        print('[v0] Filtered locations count: ${filteredLocations.length}'); // Debug log
      }
      
      for (final location in filteredLocations) {
        markers.add(
          Marker(
            markerId: MarkerId(location.name),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: location.name,
              snippet: location.category,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getEnhancedMarkerColorHue(location.category)),
            onTap: () {
              setState(() {
                _selectedLocation = location;
              });
              
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(
                  LatLng(location.latitude, location.longitude),
                ),
              );
            },
          ),
        );
      }
    }

    // Always show current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Current Location',
            snippet: 'Live location',
          ),
          zIndex: 1000,
        ),
      );
    }

    return markers;
  }

  BitmapDescriptor _createCustomCircularMarker(String category) {
    // For now using enhanced default markers with better colors
    return BitmapDescriptor.defaultMarkerWithHue(_getEnhancedMarkerColorHue(category));
  }

  BitmapDescriptor _createCurrentLocationMarker() {
    return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
  }

  double _getEnhancedMarkerColorHue(String category) {
    switch (category) {
      case 'Academic Block':
        return 240.0; // Deep blue
      case 'Hostel':
        return 30.0;  // Orange-red
      case 'Cafeteria':
        return 0.0;   // Pure red
      case 'Library':
        return 270.0; // Purple
      case 'Laboratory':
        return 120.0; // Green
      case 'Sports Ground':
        return 180.0; // Cyan
      case 'Other':
        return 60.0;  // Yellow
      default:
        return 300.0; // Magenta
    }
  }

  void _recenterMap() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        _getCampusBounds(),
        100.0,
      ),
    );
  }

  void _goToMyLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }
    
    if (_currentPosition != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          22.0,
        ),
      );
    } else {
      _showLocationError('Unable to get current location. Please try again.');
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : MapType.normal;
    });
  }

  void _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });
    } on MissingPluginException catch (e) {
      _showLocationError('Location services not available. Using campus center instead.');
      setState(() {
        _currentPosition = Position(
          latitude: _getCampusCenter().latitude,
          longitude: _getCampusCenter().longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
    } catch (e) {
      _showLocationError('Location not available. Please ensure location services are enabled and try again.');
      setState(() {
        _currentPosition = Position(
          latitude: _getCampusCenter().latitude,
          longitude: _getCampusCenter().longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      });
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic Block':
        return Colors.blue[600]!;
      case 'Hostel':
        return Colors.orange[600]!;
      case 'Cafeteria':
        return Colors.red[600]!;
      case 'Library':
        return Colors.purple[600]!;
      case 'Laboratory':
        return Colors.green[600]!;
      case 'Sports Ground':
        return Colors.cyan[600]!;
      case 'Other':
        return Colors.amber[600]!;
      default:
        return Colors.pink[600]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Academic Block':
        return Icons.school;
      case 'Hostel':
        return Icons.home;
      case 'Cafeteria':
        return Icons.restaurant;
      case 'Library':
        return Icons.local_library;
      case 'Laboratory':
        return Icons.science;
      case 'Sports Ground':
        return Icons.sports_soccer;
      case 'Other':
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }
}
