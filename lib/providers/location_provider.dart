import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../data/mock_data.dart';

class LocationProvider extends ChangeNotifier {
  List<Location> _locations = [];
  List<Location> _filteredLocations = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Location? _selectedLocation;

  List<Location> get locations => _locations;
  List<Location> get filteredLocations => _filteredLocations;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  Location? get selectedLocation => _selectedLocation;
  List<String> get categories => MockData.categories;

  LocationProvider() {
    _loadLocations();
  }

  void _loadLocations() {
    _locations = MockData.locations;
    _filteredLocations = _locations;
    notifyListeners();
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
      final matchesCategory = _selectedCategory == 'All' || 
                             location.category == _selectedCategory;
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
}