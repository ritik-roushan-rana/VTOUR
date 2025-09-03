import 'package:flutter/material.dart';

class HomeScreenConfig {
  // Header Configuration
  static const double headerBaseHeight = 300.0;
  static const double headerPadding = 20.0;
  static const double headerBorderRadius = 12.0;
  
  // Stats Configuration
  static const double statsCardTransform = -30.0;
  static const double statsCardPadding = 16.0;
  static const double statsCardBorderRadius = 16.0;
  static const double statsCardSpacing = 12.0;
  
  // Quick Actions Configuration
  static const double quickActionHeight = 140.0;
  static const double quickActionWidth = 120.0;
  static const double quickActionBorderRadius = 20.0;
  static const int quickActionAnimationDuration = 375;
  
  // General Layout
  static const double sectionSpacing = 30.0;
  static const double cardSpacing = 12.0;
  static const double defaultPadding = 20.0;
  static const double defaultBorderRadius = 16.0;
  
  // Typography
  static const double titleFontSize = 22.0;
  static const double subtitleFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  static const double captionFontSize = 12.0;
}

class HomeScreenData {
  // Stats Data
  static final List<Map<String, dynamic>> statsData = [
    {
      'number': '50+',
      'label': 'Locations',
      'icon': Icons.location_on_rounded,
      'color': const Color(0xFF4CAF50),
    },
    {
      'number': '8',
      'label': 'Categories', 
      'icon': Icons.category_rounded,
      'color': const Color(0xFF7E57C2),
    },
    {
      'number': '24/7',
      'label': 'Access',
      'icon': Icons.access_time_rounded,
      'color': const Color(0xFFFBC02D),
    },
  ];
  
  // Quick Actions Data
  static final List<Map<String, dynamic>> quickActionsData = [
    {
      'title': 'Virtual Tour',
      'subtitle': 'Start exploring',
      'icon': Icons.tour_rounded,
      'gradient': [const Color(0xFF2196F3), const Color(0xFF4CAF50)],
      'action': 'tour',
    },
    {
      'title': 'AR Experience',
      'subtitle': 'Coming Soon',
      'icon': Icons.view_in_ar_rounded,
      'gradient': [const Color(0xFFF44336), const Color(0xFFFFEB3B)],
      'action': 'ar',
    },
    {
      'title': 'Campus Map',
      'subtitle': 'Navigate easily',
      'icon': Icons.map_rounded,
      'gradient': [const Color(0xFF00BCD4), const Color(0xFF4CAF50)],
      'action': 'map',
    },
    {
      'title': 'Search',
      'subtitle': 'Find locations',
      'icon': Icons.search_rounded,
      'gradient': [const Color(0xFFB2EBF2), const Color(0xFFE0F2F7)],
      'action': 'search',
    },
    {
      'title': 'Favorites',
      'subtitle': 'Saved places',
      'icon': Icons.favorite_rounded,
      'gradient': [const Color(0xFFFFCC80), const Color(0xFFFFAB40)],
      'action': 'favorites',
    },
    {
      'title': 'Events',
      'subtitle': 'What\'s happening',
      'icon': Icons.event_rounded,
      'gradient': [const Color(0xFF9FA8DA), const Color(0xFF5C6BC0)],
      'action': 'events',
    },
  ];
  
  // Campus Highlights Data
  static final List<Map<String, dynamic>> campusHighlights = [
    {
      'title': 'Modern Labs',
      'subtitle': 'State-of-the-art equipment',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF4CAF50),
    },
    {
      'title': 'Smart Library',
      'subtitle': '100K+ digital resources',
      'icon': Icons.library_books_rounded,
      'color': const Color(0xFF7E57C2),
    },
  ];
  
  // Events Data
  static final List<Map<String, dynamic>> upcomingEvents = [
    {
      'title': 'Campus Open Day',
      'date': 'Jan 15, 2024',
      'time': '10:00 AM',
      'icon': Icons.event_rounded,
      'color': const Color(0xFF2196F3),
    },
    {
      'title': 'Virtual Lab Tour',
      'date': 'Jan 18, 2024',
      'time': '2:00 PM',
      'icon': Icons.science_rounded,
      'color': const Color(0xFF4CAF50),
    },
  ];
  
  // Welcome Section Data
  static const Map<String, dynamic> welcomeSection = {
    'title': 'Explore Your Dream Campus',
    'description': 'Take an immersive virtual journey through our state-of-the-art facilities, modern classrooms, and vibrant campus life.',
    'ctaText': 'Watch Campus Tour',
    'icon': Icons.school_rounded,
  };
  
  // Footer Actions Data
  static const Map<String, dynamic> footerActions = {
    'title': 'Ready to explore?',
    'subtitle': 'Start your virtual campus journey today',
    'primaryButton': {
      'text': 'Start Tour',
      'icon': Icons.play_arrow_rounded,
    },
    'secondaryButton': {
      'text': 'View Map',
      'icon': Icons.map_rounded,
    },
  };
}
