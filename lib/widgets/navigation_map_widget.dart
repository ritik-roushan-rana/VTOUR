import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math';

// You will need to import the file that contains the global googleMapsApiKey
import 'package:flutter_dotenv/flutter_dotenv.dart';

// The global key is now used directly, so we can remove the constructor parameter.
class NavigationMapWidget extends StatefulWidget {
  const NavigationMapWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<NavigationMapWidget> createState() => _NavigationMapWidgetState();
}

class _NavigationMapWidgetState extends State<NavigationMapWidget> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  Position? _currentPosition;
  LatLng? _searchedLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;

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
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
        _isLoading = false;
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your Location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      List<geocoding.Location> locations = await geocoding.locationFromAddress(query, localeIdentifier: 'en');
      if (locations.isNotEmpty) {
        geocoding.Location location = locations.first;
        LatLng searchedLatLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _searchedLocation = searchedLatLng;
          _markers.clear();
          if (_currentPosition != null) {
             _markers.add(
              Marker(
                markerId: const MarkerId('current_location'),
                position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                infoWindow: const InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              ),
            );
          }
          _markers.add(
            Marker(
              markerId: const MarkerId('searched_location'),
              position: searchedLatLng,
              infoWindow: InfoWindow(title: query),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        });

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(searchedLatLng),
        );

        if (_currentPosition != null) {
          await _getDirections();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location not found: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  Future<void> _getDirections() async {
    if (_currentPosition == null || _searchedLocation == null) return;

    try {
      final String url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_currentPosition!.latitude},${_currentPosition!.longitude}&'
          'destination=${_searchedLocation!.latitude},${_searchedLocation!.longitude}&'
          'key=${dotenv.env['GOOGLE_MAPS_API_KEY']!}';

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final route = data['routes'][0];
        final polylineString = route['overview_polyline']['points'];
        
        if (polylineString != null) {
          List<LatLng> polylineLatLngs = _decodePolyline(polylineString);

          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylineLatLngs,
                color: Colors.blue,
                width: 5,
                patterns: [],
              ),
            );
          });

          if (_currentPosition != null && _searchedLocation != null) {
             LatLngBounds bounds = LatLngBounds(
              southwest: LatLng(
                [_currentPosition!.latitude, _searchedLocation!.latitude].reduce((a, b) => a < b ? a : b),
                [_currentPosition!.longitude, _searchedLocation!.longitude].reduce((a, b) => a < b ? a : b),
              ),
              northeast: LatLng(
                [_currentPosition!.latitude, _searchedLocation!.latitude].reduce((a, b) => a > b ? a : b),
                [_currentPosition!.longitude, _searchedLocation!.longitude].reduce((a, b) => a > b ? a : b),
              ),
            );

            _mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 100),
            );
          }
        }
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Directions not found: ${data['error_message'] ?? 'Unknown error'}')),
         );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get directions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : const LatLng(37.7749, -122.4194),
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) async {
              _mapController = controller;
              await controller.setMapStyle(_mapStyle);
              if (_currentPosition != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                  ),
                );
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            markers: _markers,
            polylines: _polylines,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for a location...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _markers.clear();
                              _polylines.clear();
                              _searchedLocation = null;
                            });
                          },
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
          ),

          Positioned(
            bottom: 32,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}