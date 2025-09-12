import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/location_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/campus_map_widget.dart';
import '../widgets/location_grid_item.dart';
import 'location_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Campus'),
        backgroundColor: AppTheme.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.map),
              text: 'Map View',
            ),
            Tab(
              icon: Icon(Icons.grid_view),
              text: 'List View',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapView(),
                _buildListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return SearchBarWidget(
            onSearchChanged: (query) {
              locationProvider.setSearchQuery(query);
            },
          );
        },
      ),
    );
  }

  Widget _buildMapView() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return CampusMapWidget(
          locations: locationProvider.filteredLocations,
          onLocationTapped: (location) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LocationDetailScreen(location: location),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final locations = locationProvider.filteredLocations;

        if (locations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'No locations found',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Try adjusting your search terms',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return LocationGridItem(
              location: location,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LocationDetailScreen(location: location),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
