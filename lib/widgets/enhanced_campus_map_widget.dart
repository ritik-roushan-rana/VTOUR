import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';

class EnhancedCampusMapWidget extends StatefulWidget {
  final Function(Location)? onLocationTapped;

  const EnhancedCampusMapWidget({
    super.key,
    this.onLocationTapped,
  });

  @override
  State<EnhancedCampusMapWidget> createState() => _EnhancedCampusMapWidgetState();
}

class _EnhancedCampusMapWidgetState extends State<EnhancedCampusMapWidget>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Location? _selectedLocation;
  bool _isMapLoaded = false;
  bool _isLoadingLocations = true;
  String _selectedCategory = 'All';
  String? _errorMessage;
  MapType _currentMapType = MapType.normal;
  
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  late LocationService _locationService;
  
  List<Location> _locations = [];

  static const String _mapStyle = '''
  [
    {
      "featureType": "poi.business",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels",
      "stylers": [{"visibility": "simplified"}]
    },
    {
      "featureType": "transit",
      "stylers": [{"visibility": "off"}]
    },
    {
      "featureType": "poi.medical",
      "stylers": [{"visibility": "off"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _locationService = LocationService(Supabase.instance.client);
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _loadLocations();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadLocations() async {
    try {
      setState(() {
        _isLoadingLocations = true;
        _errorMessage = null;
      });
      
      final locations = await _locationService.getLocations();
      
      setState(() {
        _locations = locations;
        _isLoadingLocations = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to load locations: $error';
        _isLoadingLocations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingLocations) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue[50]!,
                Colors.white,
              ],
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 24),
                Text(
                  'Loading Campus Locations...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Fetching data from Supabase',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red[50]!,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loadLocations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
            mapType: _currentMapType,
            style: _currentMapType == MapType.normal ? _mapStyle : null,
            onMapCreated: (controller) async {
              _mapController = controller;
              if (_currentMapType == MapType.normal) {
                await _mapController!.setMapStyle(_mapStyle);
              }
              
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted && _locations.isNotEmpty) {
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

          // Category filter with enhanced design
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildCategoryFilter(),
          ),

          // Refresh button with enhanced design
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _loadLocations,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.refresh,
                      color: Colors.blue[700],
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Enhanced control buttons
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
                      _buildControlButton(
                        icon: Icons.center_focus_strong,
                        onPressed: _recenterMap,
                        heroTag: "recenter",
                        tooltip: "Recenter Map",
                      ),
                      const SizedBox(height: 12),
                      _buildControlButton(
                        icon: Icons.my_location,
                        onPressed: _goToMyLocation,
                        heroTag: "location",
                        tooltip: "My Location",
                      ),
                      const SizedBox(height: 12),
                      _buildControlButton(
                        icon: _currentMapType == MapType.normal 
                            ? Icons.satellite_alt 
                            : Icons.map,
                        onPressed: _toggleMapType,
                        heroTag: "toggle",
                        tooltip: _currentMapType == MapType.normal 
                            ? "Satellite View" 
                            : "Map View",
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

          if (!_isMapLoaded && !_isLoadingLocations)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Initializing Map...',
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

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                color: Colors.blue[700],
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ..._locations.map((l) => l.category).toSet()];
    
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                  fontSize: 13,
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
              elevation: isSelected ? 6 : 3,
              shadowColor: Colors.blue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Location info with enhanced design
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(_selectedLocation!.category).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getCategoryColor(_selectedLocation!.category).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(_selectedLocation!.category),
                    color: _getCategoryColor(_selectedLocation!.category),
                    size: 28,
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
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(_selectedLocation!.category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedLocation!.category,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getCategoryColor(_selectedLocation!.category),
                          ),
                        ),
                      ),
                      if (_selectedLocation!.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _selectedLocation!.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocation = null;
                      });
                    },
                    icon: const Icon(Icons.close, size: 20),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Enhanced action buttons
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
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (widget.onLocationTapped != null) {
                        widget.onLocationTapped!(_selectedLocation!);
                      }
                    },
                    icon: const Icon(Icons.info_outline, size: 20),
                    label: const Text('More Info'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.blue[600]!, width: 1.5),
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
    if (_locations.isEmpty) {
      return const LatLng(28.6139, 77.2090); // fallback coordinates
    }
    final avgLat = _locations
            .map((l) => l.latitude)
            .reduce((a, b) => a + b) /
        _locations.length;
    final avgLng = _locations
            .map((l) => l.longitude)
            .reduce((a, b) => a + b) /
        _locations.length;
    return LatLng(avgLat, avgLng);
  }

  LatLngBounds _getCampusBounds() {
    if (_locations.isEmpty) {
      final center = _getCampusCenter();
      const delta = 0.027;
      return LatLngBounds(
        southwest: LatLng(center.latitude - delta, center.longitude - delta),
        northeast: LatLng(center.latitude + delta, center.longitude + delta),
      );
    }

    double minLat = _locations.first.latitude;
    double maxLat = _locations.first.latitude;
    double minLng = _locations.first.longitude;
    double maxLng = _locations.first.longitude;

    for (final location in _locations) {
      minLat = minLat < location.latitude ? minLat : location.latitude;
      maxLat = maxLat > location.latitude ? maxLat : location.latitude;
      minLng = minLng < location.longitude ? minLng : location.longitude;
      maxLng = maxLng > location.longitude ? maxLng : location.longitude;
    }

    // Add some padding
    const padding = 0.005;
    return LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
  }

  Set<Marker> _buildMarkers() {
    final filteredLocations = _selectedCategory == 'All'
        ? _locations
        : _locations.where((l) => l.category == _selectedCategory).toList();

    return filteredLocations.map((location) {
      return Marker(
        markerId: MarkerId(location.id ?? location.name),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: location.name,
          snippet: location.category,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerColorHue(location.category),
        ),
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
      );
    }).toSet();
  }

  double _getMarkerColorHue(String category) {
    switch (category) {
      case 'Academic Block':
        return BitmapDescriptor.hueBlue;
      case 'Hostel':
        return BitmapDescriptor.hueOrange;
      case 'Cafeteria':
        return BitmapDescriptor.hueRed;
      case 'Library':
        return BitmapDescriptor.hueViolet;
      case 'Laboratory':
        return BitmapDescriptor.hueGreen;
      case 'Sports Ground':
        return BitmapDescriptor.hueCyan;
      default:
        return BitmapDescriptor.hueAzure;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Academic Block':
        return Colors.blue;
      case 'Hostel':
        return Colors.orange;
      case 'Cafeteria':
        return Colors.red;
      case 'Library':
        return Colors.purple;
      case 'Laboratory':
        return Colors.green;
      case 'Sports Ground':
        return Colors.cyan;
      default:
        return Colors.grey;
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
      default:
        return Icons.place;
    }
  }

  void _recenterMap() {
    if (_locations.isNotEmpty) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getCampusBounds(),
          100.0,
        ),
      );
    }
  }

  void _goToMyLocation() {
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(_getCampusCenter()),
    );
  }

  void _toggleMapType() async {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal 
          ? MapType.satellite 
          : MapType.normal;
    });
    
    // Apply or remove custom style based on map type
    if (_currentMapType == MapType.normal) {
      await _mapController?.setMapStyle(_mapStyle);
    } else {
      await _mapController?.setMapStyle(null);
    }
  }

  void _openGoogleMaps(double lat, double lng) async {
    final url = Uri.parse(
        "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=walking");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
