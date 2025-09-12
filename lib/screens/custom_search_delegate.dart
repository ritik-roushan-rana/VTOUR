import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../models/location_model.dart';
import 'location_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomSearchDelegate extends SearchDelegate<Location?> {
  final LocationProvider locationProvider;
  
  final List<String> _recentSearches = [];
  
  CustomSearchDelegate({required this.locationProvider}) {
    _loadRecentSearches();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList('recent_searches');
    if (searches != null) {
      _recentSearches.clear();
      _recentSearches.addAll(searches);
    }
  }

  Future<void> _saveRecentSearch(String newSearch) async {
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(newSearch);
    _recentSearches.insert(0, newSearch);
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast();
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  @override
  String get searchFieldLabel => 'Start typing here...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        iconTheme: theme.iconTheme.copyWith(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: theme.textTheme.titleMedium?.copyWith(color: Colors.white70),
        fillColor: AppTheme.primaryColor,
        filled: true,
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _saveRecentSearch(query);
    
    final results = locationProvider.locations.where((location) {
      return location.name.toLowerCase().contains(query.toLowerCase()) ||
             location.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    return _buildResultsList(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      final popularLocations = locationProvider.locations.take(3).toList();

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_recentSearches.isNotEmpty) ...[
              _buildSectionHeader(context, 'Recent Searches', Icons.access_time),
              ..._recentSearches.map((search) {
                return ListTile(
                  leading: Icon(Icons.access_time_filled, color: AppTheme.textSecondary),
                  title: Text(search),
                  onTap: () {
                    query = search;
                    showResults(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            
            _buildSectionHeader(context, 'Popular Locations', Icons.trending_up),
            ...popularLocations.map((location) {
              return ListTile(
                leading: Icon(Icons.trending_up, color: AppTheme.textSecondary),
                title: Text(location.name),
                onTap: () {
                  close(context, location);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailScreen(location: location),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        ),
      );
    }
    
    final suggestions = locationProvider.locations.where((location) {
      return location.name.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return _buildResultsList(context, suggestions);
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textPrimary, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Location> locations) {
    if (locations.isEmpty) {
      return Center(
        child: Text(
          'No results found for "$query".',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: location.imagePath,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[200]),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(Icons.image_not_supported, size: 24, color: AppTheme.textSecondary),
              ),
            ),
          ),
          title: Text(location.name),
          subtitle: Text(
            location.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () {
            close(context, location);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocationDetailScreen(location: location),
              ),
            );
          },
        );
      },
    );
  }
}