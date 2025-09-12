import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/featured_location_card.dart';
import '../widgets/home_screen_widgets.dart';
import '../config/home_screen_config.dart';
import 'location_detail_screen.dart';
import '../providers/location_provider.dart';
import '../services/auth_service.dart';
import '../models/location_model.dart';
import '../widgets/search_bar_widget.dart';
import 'explore_screen.dart';
import 'custom_search_delegate.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildModernHeader(context),
                _buildStatsCards(),
                _buildWelcomeSection(),
                _buildQuickActions(context),
                _buildCampusHighlights(),
                if (locationProvider.searchQuery.isNotEmpty)
                  _buildSearchResults(locationProvider.filteredLocations)
                else ...[
                  _buildFeaturedLocations(context),
                  _buildUpcomingEvents(),
                  _buildFooterActions(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(List<Location> locations) {
    if (locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No locations found for "${Provider.of<LocationProvider>(context).searchQuery}".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }
    
    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: FeaturedLocationCard(
                  location: location,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LocationDetailScreen(
                          location: location,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double totalHeaderHeight = HomeScreenConfig.headerBaseHeight + statusBarHeight;

    return Container(
      height: totalHeaderHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.accentColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: HeaderPatternPainter()),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              HomeScreenConfig.headerPadding,
              statusBarHeight + HomeScreenConfig.headerPadding,
              HomeScreenConfig.headerPadding,
              HomeScreenConfig.headerPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderContent(),
                const SizedBox(height: 16),
                _buildHeaderInfoCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good ${_getGreeting()}!',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Welcome to VTour',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                'Your Virtual Campus Guide',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.search,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(
                  locationProvider: Provider.of<LocationProvider>(context, listen: false),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container();
  }

  Widget _buildHeaderInfoCard() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        final int locationCount = locationProvider.locations.length;
        final String locationCountText = "$locationCount";
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  // CORRECTED: This text now uses the dynamic location count
                  'Discover $locationCountText+ campus locations with immersive virtual tours',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        if (locationProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final int locationCount = locationProvider.locations.length;
        final int categoryCount = locationProvider.categories.length - 1;
        final String locationCountText = "$locationCount";
        final String categoryCountText = "$categoryCount";
        
        final dynamicStats = [
          {'number': locationCountText, 'label': 'Locations', 'icon': Icons.location_on_rounded, 'color': AppTheme.primaryColor},
          {'number': categoryCountText, 'label': 'Categories', 'icon': Icons.category_rounded, 'color': AppTheme.accentColor},
          {'number': '24/7', 'label': 'Access', 'icon': Icons.access_time_rounded, 'color': AppTheme.secondaryColor},
        ];

        return Container(
          transform: Matrix4.translationValues(0, HomeScreenConfig.statsCardTransform, 0),
          padding: const EdgeInsets.symmetric(horizontal: HomeScreenConfig.defaultPadding),
          child: Row(
            children: dynamicStats.asMap().entries.map((entry) {
              final index = entry.key;
              final stat = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < dynamicStats.length - 1 
                        ? HomeScreenConfig.statsCardSpacing 
                        : 0,
                  ),
                  child: ModernStatCard(
                    number: stat['number'].toString(),
                    label: stat['label'].toString(),
                    icon: stat['icon'] as IconData,
                    color: stat['color'] as Color,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    final welcomeData = HomeScreenData.welcomeSection;
    return Container(
      margin: const EdgeInsets.fromLTRB(
        HomeScreenConfig.defaultPadding,
        10,
        HomeScreenConfig.defaultPadding,
        0,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundColor,
            AppTheme.backgroundColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.surfaceColor, width: 2),
      ),
      child: Column(
        children: [
          _buildWelcomeImage(welcomeData),
          const SizedBox(height: 20),
          Text(
            welcomeData['title'],
            style: TextStyle(
              fontSize: HomeScreenConfig.titleFontSize,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            welcomeData['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeImage(Map<String, dynamic> welcomeData) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              welcomeData['icon'],
              size: 60,
              color: Colors.white,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Row(
              children: [
                const Icon(
                  Icons.play_circle_filled_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  welcomeData['ctaText'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeScreenConfig.sectionSpacing),
        const SectionHeader(
          title: 'Quick Actions',
          icon: Icons.flash_on_rounded,
          iconColor: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: HomeScreenConfig.quickActionHeight,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: HomeScreenConfig.defaultPadding),
              itemCount: HomeScreenData.quickActionsData.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: HomeScreenConfig.quickActionAnimationDuration),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: ModernActionCard(
                        action: HomeScreenData.quickActionsData[index],
                        onTap: () => _handleQuickAction(context, HomeScreenData.quickActionsData[index]['action']),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampusHighlights() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        HomeScreenConfig.defaultPadding,
        HomeScreenConfig.sectionSpacing,
        HomeScreenConfig.defaultPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: SectionHeader(
              title: 'Campus Highlights',
              icon: Icons.star_rounded,
              iconColor: Color(0xFFFBC02D),
            ),
          ),
          Row(
            children: HomeScreenData.campusHighlights.asMap().entries.map((entry) {
              final index = entry.key;
              final highlight = entry.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < HomeScreenData.campusHighlights.length - 1 
                        ? HomeScreenConfig.cardSpacing 
                        : 0,
                  ),
                  child: HighlightCard(
                    title: highlight['title'],
                    subtitle: highlight['subtitle'],
                    icon: highlight['icon'],
                    color: highlight['color'],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLocations(BuildContext context) {
    final locationProvider = Provider.of<LocationProvider>(context);
    
    if (locationProvider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (locationProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Error: ${locationProvider.errorMessage}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    final featuredLocations = locationProvider.locations.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: HomeScreenConfig.sectionSpacing),
        const SectionHeader(
          title: 'Featured Locations',
          icon: Icons.place_rounded,
          iconColor: Color(0xFFD32F2F),
        ),
        const SizedBox(height: 16),
        if (featuredLocations.isEmpty)
          const Center(
            child: Text('No featured locations found.'),
          )
        else
          AnimationLimiter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: HomeScreenConfig.defaultPadding),
              itemCount: featuredLocations.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: FeaturedLocationCard(
                        location: featuredLocations[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationDetailScreen(
                                location: featuredLocations[index],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUpcomingEvents() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        HomeScreenConfig.defaultPadding,
        HomeScreenConfig.sectionSpacing,
        HomeScreenConfig.defaultPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: SectionHeader(
              title: 'Upcoming Events',
              icon: Icons.calendar_today_rounded,
              iconColor: Color(0xFF7E57C2),
            ),
          ),
          ...HomeScreenData.upcomingEvents.map((event) => EventCard(event: event)),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    final footerData = HomeScreenData.footerActions;
    return Container(
      margin: const EdgeInsets.all(HomeScreenConfig.defaultPadding),
      padding: const EdgeInsets.all(HomeScreenConfig.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            footerData['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            footerData['subtitle'],
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleQuickAction(context, 'tour'),
                  icon: Icon(footerData['primaryButton']['icon']),
                  label: Text(footerData['primaryButton']['text']),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _handleQuickAction(context, 'map'),
                  icon: Icon(footerData['secondaryButton']['icon']),
                  label: Text(footerData['secondaryButton']['text']),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  void _handleQuickAction(BuildContext context, String action) {
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      switch (action) {
        case 'tour':
          tabController.animateTo(1);
          break;
        case 'map':
          tabController.animateTo(2);
          break;
        case 'ar':
        case 'search':
        case 'favorites':
        case 'events':
          _showComingSoonDialog(context, action);
          break;
      }
    } else {
      print('Error: DefaultTabController not found in widget tree.');
      _showComingSoonDialog(context, action);
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    final featureName = feature.replaceFirst(feature[0], feature[0].toUpperCase());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.rocket_launch_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text('$featureName Coming Soon!'),
          ],
        ),
        content: Text(
          '$featureName feature will be available in the next update. Stay tuned for amazing new experiences!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

}

class HeaderPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final circleCount = (size.width / 50).round();
    final lineCount = (size.height / 30).round();

    for (int i = 0; i < circleCount * 4; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < lineCount; i++) {
      canvas.drawLine(
        Offset(0, i * 30.0),
        Offset(size.width, i * 30.0),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}