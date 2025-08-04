import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'tour_screen.dart';
import 'explore_screen.dart';
import 'about_screen.dart';
import '../utils/app_theme.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this); // 4 tabs: Home, Tour, Explore, About
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController( // Provide DefaultTabController to the widget tree
      length: 4, // Number of tabs
      child: Scaffold(
        body: TabBarView( // Use TabBarView to display screens based on selected tab
          controller: _tabController, // Link with the TabController
          physics: const NeverScrollableScrollPhysics(), // Prevent manual swiping between tabs
          children: const [
            HomeScreen(),
            TourScreen(),
            ExploreScreen(),
            AboutScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _tabController.index, // Use controller's index
            onTap: (index) {
              _tabController.animateTo(index); // Animate to the selected tab
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondary,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.tour_outlined),
                activeIcon: Icon(Icons.tour),
                label: 'Tour',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_outlined),
                activeIcon: Icon(Icons.explore),
                label: 'Explore',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info_outline),
                activeIcon: Icon(Icons.info),
                label: 'About',
              ),
            ],
          ),
        ),
      ),
    );
  }
}