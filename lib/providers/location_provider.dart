// lib/providers/location_provider.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../models/hostel_room_model.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService _locationService;
  List<Location> _locations = [];
  List<Location> _filteredLocations = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Location? _selectedLocation;
  bool _isLoading = false;
  String? _errorMessage;

  List<Location> get locations => _locations;
  List<Location> get filteredLocations => _filteredLocations;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Location? get selectedLocation => _selectedLocation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Location> get hostels => _locations
      .where((location) => location.category == LocationCategory.hostel.displayName)
      .toList();

  List<String> get categories => ['All', ...LocationCategory.values.map((e) => e.displayName)];

  LocationProvider(SupabaseClient supabaseClient)
      : _locationService = LocationService(supabaseClient) {
    fetchLocations();
  }

  Future<List<HostelRoom>> getHostelRooms(String locationId) async {
    return await _locationService.getHostelRooms(locationId);
  }

  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _locations = await _locationService.getLocations();
      _filterLocations();
    } on PostgrestException catch (error) {
      _errorMessage = 'Database error: ${error.message}';
      print(_errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to fetch locations: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    _filterLocations();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterLocations();
    notifyListeners();
  }

  void _filterLocations() {
    _filteredLocations = _locations.where((location) {
      final matchesCategory = _selectedCategory == 'All' || location.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          location.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          location.description.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void setSelectedLocation(Location location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearSelectedLocation() {
    _selectedLocation = null;
    notifyListeners();
  }

  List<Location> getLocationsByCategory(String category) {
    if (category == 'All') return _locations;
    return _locations.where((location) => location.category == category).toList();
  }

  Location? getLocationById(String id) {
    try {
      return _locations.firstWhere((location) => location.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addLocation(Location location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _locationService.addLocation(location);
      await fetchLocations();
    } on PostgrestException catch (error) {
      _errorMessage = 'Failed to add location: ${error.message}';
      print(_errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to add location: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateLocation(Location location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _locationService.updateLocation(location);
      await fetchLocations();
    } on PostgrestException catch (error) {
      _errorMessage = 'Failed to update location: ${error.message}';
      print(_errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to update location: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteLocation(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _locationService.deleteLocation(id);
      await fetchLocations();
    } on PostgrestException catch (error) {
      _errorMessage = 'Failed to delete location: ${error.message}';
      print(_errorMessage);
    } catch (e) {
      _errorMessage = 'Failed to delete location: $e';
      print(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}