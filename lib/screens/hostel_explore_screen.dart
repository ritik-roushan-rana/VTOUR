import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/app_theme.dart';
import '../models/location_model.dart';
import '../providers/location_provider.dart';
import 'hostel_room_type_screen.dart';

class HostelExploreScreen extends StatefulWidget {
  const HostelExploreScreen({super.key});

  @override
  State<HostelExploreScreen> createState() => _HostelExploreScreenState();
}

class _HostelExploreScreenState extends State<HostelExploreScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = ''; // NEW: State variable for the search query
  final List<String> _filters = ['All', 'Mens Hostel', 'Ladies Hostel'];

  @override
  Widget build(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);

    // Filter by category first, then apply selected filter and search query
    final allHostels = locationProvider.hostels.where((hostel) => hostel.category == 'Hostel').toList();
    
    final filteredByChips = _selectedFilter == 'All'
        ? allHostels
        : allHostels.where((hostel) => hostel.genderType == _selectedFilter).toList();

    final displayedHostels = _searchQuery.isEmpty
        ? filteredByChips
        : filteredByChips.where(
            (hostel) => hostel.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hostel Explore'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: locationProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // NEW: Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search hostels...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                // Filter chips
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: _selectedFilter == filter,
                          onSelected: (bool selected) {
                            setState(() {
                              _selectedFilter = selected ? filter : 'All';
                            });
                          },
                          selectedColor: AppTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: _selectedFilter == filter ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: displayedHostels.isEmpty
                      ? const Center(child: Text('No hostels found.'))
                      : GridView.builder(
                          padding: const EdgeInsets.all(16.0),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: displayedHostels.length,
                          itemBuilder: (context, index) {
                            final hostel = displayedHostels[index];
                            // Truncate the name to 9 characters if it's longer
                            final String shortenedName = hostel.name.length > 9
                                ? '${hostel.name.substring(0, 9)}...'
                                : hostel.name;
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HostelRoomTypeScreen(hostel: hostel),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: hostel.imagePath,
                                        fit: BoxFit.cover,
                                        height: double.infinity,
                                        width: double.infinity,
                                        placeholder: (context, url) =>
                                            const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) =>
                                            const Icon(Icons.error),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        right: 12,
                                        child: Text(
                                          shortenedName, // MODIFIED: Use the shortened name here
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}