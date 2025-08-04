import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart'; // Added for AuthService and LocationProvider
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for AuthException and Supabase client
import '../utils/app_theme.dart';
import '../data/mock_data.dart';
import '../widgets/featured_location_card.dart';
import 'location_detail_screen.dart';
import '../providers/location_provider.dart'; // Added
import '../services/auth_service.dart'; // Added
import '../models/location_model.dart'; // Added for LocationCategory and Location

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch locations when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LocationProvider>(context, listen: false).fetchLocations();
    });
  }

  // Method to add a sample location (re-added from previous context)
  Future<void> _addSampleLocation() async {
    final newLocation = Location(
      name: 'New Academic Block',
      category: LocationCategory.academicBlock.displayName, // Use displayName
      description: 'A newly constructed academic building with modern classrooms.',
      imagePath: 'https://example.com/images/new_academic.jpg',
      videoPath: 'https://example.com/videos/new_academic_tour.mp4',
      latitude: 34.0522 + 0.01,
      longitude: -118.2437 + 0.01,
      features: ['Smart Boards', 'Auditorium', 'Research Labs'],
      voiceoverText: 'Explore the state-of-the-art new academic block.',
      isAvailable: true,
      userId: Supabase.instance.client.auth.currentUser?.id, // Assign current user's ID
    );
    try {
      await Provider.of<LocationProvider>(context, listen: false).addLocation(newLocation);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample location added!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add sample location: $e')),
      );
    }
  }

  // Method to handle user sign out
  Future<void> _signOut() async {
    try {
      await Provider.of<AuthService>(context, listen: false).signOut();
      // Navigation handled by main.dart's auth listener
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred during sign out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // Removed AppBar to match the screenshot's custom header
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(context),
            _buildStatsCards(),
            _buildWelcomeSection(),
            _buildQuickActions(context),
            _buildCampusHighlights(),
            _buildFeaturedLocations(context),
            _buildUpcomingEvents(),
            _buildFooterActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    const double baseHeaderContentHeight = 300;
    final double totalHeaderHeight = baseHeaderContentHeight + statusBarHeight;

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
            child: CustomPaint(
              painter: HeaderPatternPainter(),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, statusBarHeight + 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                    cursorColor: AppTheme.primaryColor,
                    decoration: InputDecoration(
                      hintText: 'Search for locations, events...',
                      hintStyle: TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
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
                      const SizedBox(width: 1),
                      const Expanded(
                        child: Text(
                          'Discover 50+ campus locations with immersive virtual tours',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      transform: Matrix4.translationValues(0, -30, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              '50+',
              'Locations',
              Icons.location_on_rounded,
              AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '8',
              'Categories',
              Icons.category_rounded,
              const Color(0xFF7E57C2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              '24/7',
              'Access',
              Icons.access_time_rounded,
              const Color(0xFFFBC02D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.secondaryColor,
                  AppTheme.primaryColor,
                ],
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
                // Directly use the Icon widget to match the screenshot
                const Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 60, // Adjust size as needed to match screenshot
                    color: Colors.white,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 16,
                  left: 16,
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Watch Campus Tour',
                        style: TextStyle(
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
          ),
          const SizedBox(height: 20),
          Text(
            'Explore Your Dream Campus',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take an immersive virtual journey through our state-of-the-art facilities, modern classrooms, and vibrant campus life.',
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

  Widget _buildQuickActions(BuildContext context) {
    final modernActions = [
      {
        'title': 'Virtual Tour',
        'subtitle': 'Start exploring',
        'icon': Icons.tour_rounded,
        'gradient': [AppTheme.primaryColor, AppTheme.secondaryColor],
      },
      {
        'title': 'AR Experience',
        'subtitle': 'Coming Soon',
        'icon': Icons.view_in_ar_rounded,
        'gradient': [const Color(0xFFF44336), const Color(0xFFFFEB3B)],
      },
      {
        'title': 'Campus Map',
        'subtitle': 'Navigate easily',
        'icon': Icons.map_rounded,
        'gradient': [AppTheme.accentColor, AppTheme.secondaryColor],
      },
      {
        'title': 'Search',
        'subtitle': 'Find locations',
        'icon': Icons.search_rounded,
        'gradient': [const Color(0xFFB2EBF2), const Color(0xFFE0F2F7)],
      },
      {
        'title': 'Favorites',
        'subtitle': 'Saved places',
        'icon': Icons.favorite_rounded,
        'gradient': [const Color(0xFFFFCC80), const Color(0xFFFFAB40)],
      },
      {
        'title': 'Events',
        'subtitle': 'What\'s happening',
        'icon': Icons.event_rounded,
        'gradient': [const Color(0xFF9FA8DA), const Color(0xFF5C6BC0)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.flash_on_rounded,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: AnimationLimiter(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: modernActions.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildModernActionCard(
                        modernActions[index],
                        () => _handleQuickAction(context, index),
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

  Widget _buildModernActionCard(Map<String, dynamic> action, VoidCallback onTap) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: action['gradient'],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (action['gradient'][0] as Color).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  action['icon'],
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  action['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  action['subtitle'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusHighlights() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFBC02D),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Campus Highlights',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildHighlightCard(
                  'Modern Labs',
                  'State-of-the-art equipment',
                  Icons.science_rounded,
                  AppTheme.secondaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHighlightCard(
                  'Smart Library',
                  '100K+ digital resources',
                  Icons.library_books_rounded,
                  const Color(0xFF7E57C2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedLocations(BuildContext context) {
    final featuredLocations = MockData.locations.take(3).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.place_rounded,
                color: const Color(0xFFD32F2F),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Featured Locations',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
    final events = [
      {
        'title': 'Campus Open Day',
        'date': 'Jan 15, 2024',
        'time': '10:00 AM',
        'icon': Icons.event_rounded,
        'color': AppTheme.primaryColor,
      },
      {
        'title': 'Virtual Lab Tour',
        'date': 'Jan 18, 2024',
        'time': '2:00 PM',
        'icon': Icons.science_rounded,
        'color': AppTheme.secondaryColor,
      },
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: const Color(0xFF7E57C2),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Upcoming Events',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          ...events.map((event) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: (event['color'] as Color).withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (event['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        event['icon'] as IconData,
                        color: event['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event['date']} • ${event['time']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFooterActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Ready to explore?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start your virtual campus journey today',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleQuickAction(context, 0),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Tour'),
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
                  onPressed: () => _handleQuickAction(context, 2),
                  icon: const Icon(Icons.map_rounded),
                  label: const Text('View Map'),
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

  void _handleQuickAction(BuildContext context, int index) {
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      switch (index) {
        case 0:
          tabController.animateTo(1);
          break;
        case 1:
          _showComingSoonDialog(context, 'AR Experience');
          break;
        case 2:
          tabController.animateTo(2);
          break;
        case 3:
          _showComingSoonDialog(context, 'Search');
          break;
        case 4:
          _showComingSoonDialog(context, 'Favorites');
          break;
        case 5:
          _showComingSoonDialog(context, 'Events');
          break;
      }
    } else {
      print('Error: DefaultTabController not found in widget tree.');
      _showComingSoonDialog(context, 'Feature');
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
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
            Text('$feature Coming Soon!'),
          ],
        ),
        content: Text(
          '$feature feature will be available in the next update. Stay tuned for amazing new experiences!',
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

    for (int i = 0; i < 20; i++) {
      final x = (i * 50.0) % size.width;
      final y = (i * 30.0) % size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }

    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
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