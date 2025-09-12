// lib/screens/navigation_screen.dart

import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// No longer need geocoding_service.dart import as we get coordinates directly

class NavigationScreen extends StatefulWidget {
  final double destinationLat;
  final double destinationLng;
  final String destinationName;

  const NavigationScreen({
    Key? key,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationName,
  }) : super(key: key);

  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Position? currentLocation;
  bool _isNavigating = false;
  MapType _currentMapType = MapType.normal;
  final AudioPlayer _audioPlayer = AudioPlayer();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final String googleApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  String _currentInstruction = "Getting route...";
  double _distanceToNextTurn = 0.0;
  List<dynamic> _steps = [];
  int _currentStepIndex = 0;
  String _currentStreetName = "Unknown Road";
  String _eta = "Calculating...";
  String _totalDistance = "Calculating...";

  @override
  void initState() {
    super.initState();
    _checkLocationServices();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkLocationServices() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    _getCurrentLocation();
  }

  void _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
      .then((position) {
        currentLocation = position;
        _updateMarkers();
        _getPolylineAndDirections();
        setState(() {});
      }).catchError((e) {
        print('Error getting initial location: $e');
      });

    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) async {
      currentLocation = position;
      _updateMarkers();

      if (_isNavigating) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18,
              tilt: 60,
              bearing: position.heading,
            ),
          ),
        );
        _updateNavigationUI(position);
      }
      
      setState(() {});
    });
  }

  void _updateMarkers() {
    _markers.clear();
    
    if (currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          position: LatLng(currentLocation!.latitude, currentLocation!.longitude),
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(title: "You are here"),
        ),
      );
    }
    
    _markers.add(
      Marker(
        markerId: const MarkerId("destination"),
        position: LatLng(widget.destinationLat, widget.destinationLng),
        infoWindow: InfoWindow(title: widget.destinationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
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

  Future<void> _getPolylineAndDirections() async {
    if (currentLocation == null) {
      print("Current location is null. Cannot get directions.");
      return;
    }

    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${currentLocation!.latitude},${currentLocation!.longitude}',
        'destination': '${widget.destinationLat},${widget.destinationLng}',
        'mode': 'walking',
        'key': googleApiKey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          _steps = leg['steps'] ?? [];

          final points = route['overview_polyline']['points'] ?? '';
          final polylineCoordinates = _decodePolyline(points);
          
          setState(() {
            _polylines.clear();
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.blue,
                width: 8,
                points: polylineCoordinates,
              ),
            );
            _totalDistance = leg['distance']['text'] ?? '0 km';
            int durationSeconds = leg['duration']['value'] ?? 0;
            _eta = _formatDuration(durationSeconds);
            if (currentLocation != null) {
              _updateNavigationUI(currentLocation!);
            }
          });
        }
      }
    } catch (e) {
      print("❌ Error fetching directions: $e");
    }
  }

  void _updateNavigationUI(Position newLoc) {
    if (_steps.isEmpty || _currentStepIndex >= _steps.length) {
      setState(() {
        _currentInstruction = "You have arrived!";
        _distanceToNextTurn = 0;
      });
      _playArrivedSound();
      return;
    }

    final currentStep = _steps[_currentStepIndex];
    final nextTurnLatLng = LatLng(
      currentStep['end_location']['lat'] ?? 0,
      currentStep['end_location']['lng'] ?? 0,
    );
    double distance = Geolocator.distanceBetween(
      newLoc.latitude,
      newLoc.longitude,
      nextTurnLatLng.latitude,
      nextTurnLatLng.longitude,
    );

    setState(() {
      _distanceToNextTurn = distance;
      String instruction = currentStep['html_instructions'].toString() ?? '';
      _currentInstruction = instruction.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
      final regex = RegExp(r'onto (.*?)(?:<)');
      final match = regex.firstMatch(instruction);
      _currentStreetName = match?.group(1) ?? "Unnamed Road";
    });

    if (distance < 30 && _currentStepIndex + 1 < _steps.length) {
      _currentStepIndex++;
      _updateNavigationUI(newLoc);
    } else if (distance < 30 && _currentStepIndex + 1 == _steps.length) {
      setState(() {
        _currentInstruction = "You have arrived at your destination!";
        _distanceToNextTurn = 0;
        _isNavigating = false;
      });
    }
  }

  Future<void> _playArrivedSound() async {
    await _audioPlayer.play(AssetSource('audio/arrived.mp3'));
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return "$seconds sec";
    int minutes = seconds ~/ 60;
    if (minutes < 60) return "$minutes min";
    int hours = minutes ~/ 60;
    minutes = minutes % 60;
    return "$hours hr $minutes min";
  }

  IconData _getTurnIcon(String? maneuver) {
    if (maneuver == null) {
      return Icons.navigation;
    }
    switch (maneuver) {
      case 'turn-right':
      case 'fork-right':
      case 'ramp-right':
        return Icons.turn_right;
      case 'turn-left':
      case 'fork-left':
      case 'ramp-left':
        return Icons.turn_left;
      case 'turn-sharp-right':
        return Icons.turn_sharp_right;
      case 'turn-sharp-left':
        return Icons.turn_sharp_left;
      case 'straight':
        return Icons.arrow_upward;
      default:
        return Icons.navigation;
    }
  }

  void _toggleNavigation() async {
    setState(() {
      _isNavigating = !_isNavigating;
    });

    if (_isNavigating) {
      _currentStepIndex = 0;
      if (currentLocation != null) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
              zoom: 18,
              tilt: 60,
              bearing: currentLocation!.heading,
            ),
          ),
        );
      }
      await _getPolylineAndDirections();
    } else {
      if (currentLocation != null) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(currentLocation!.latitude, currentLocation!.longitude),
              zoom: 15,
              tilt: 0,
              bearing: 0,
            ),
          ),
        );
      }
    }
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Navigate to ${widget.destinationName}"),
        actions: [
          IconButton(
            icon: Icon(
              _currentMapType == MapType.normal ? Icons.satellite : Icons.map,
            ),
            onPressed: _toggleMapType,
            tooltip: 'Toggle Map Type',
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: Text(
                "Fetching location...\nMake sure GPS is ON and permission is granted.",
                textAlign: TextAlign.center,
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.destinationLat, widget.destinationLng),
                    zoom: 15,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  mapType: _currentMapType,
                  buildingsEnabled: true,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) _controller.complete(controller);
                  },
                  padding: EdgeInsets.only(
                    top: _isNavigating ? 150 : 0,
                    bottom: _isNavigating ? 150 : 0,
                  ),
                ),

                if (_isNavigating)
                  Positioned(
                    top: 10,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                _currentStepIndex < _steps.length
                                  ? _getTurnIcon(_steps[_currentStepIndex]['maneuver'] as String?)
                                  : Icons.directions_walk,
                                color: Colors.white,
                                size: 40,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _currentInstruction,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    Text(
                                      "${_distanceToNextTurn.toStringAsFixed(0)} m",
                                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white54, height: 16),
                          Text(
                            _currentStreetName,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_isNavigating)
                  Positioned(
                    bottom: 20,
                    left: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.search, color: Colors.white, size: 30),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _totalDistance,
                                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  Text(
                                    "$_eta left",
                                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 30),
                            onPressed: _toggleNavigation,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: currentLocation != null && !_isNavigating
          ? FloatingActionButton.extended(
              onPressed: _toggleNavigation,
              label: const Text("Start Navigation"),
              icon: const Icon(Icons.navigation),
              backgroundColor: Colors.blue,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}