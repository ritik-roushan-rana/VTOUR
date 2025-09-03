import 'package:flutter/material.dart';
import '../utils/app_theme.dart'; // Assuming you have this for consistent styling

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topSectionHeight = MediaQuery.of(context).size.height * 0.35; // Slightly taller for the illustration

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          // Top Colored Section
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: topSectionHeight,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryColor, // Matching your app's primary color
              ),
              child: SafeArea(
                child: Center(
                  child: Text(
                    'VTour', // Your app's name
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ),
          ),
          // White Content Card
          Positioned(
            top: topSectionHeight - 30, // Overlap the top section slightly
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration/Icon Section (similar to Jobsly documents)
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[100], // Light background for the icon
                        borderRadius: BorderRadius.circular(20),
                        // You could add a subtle shadow here if desired
                      ),
                      child: Icon(
                        Icons.map, // A relevant icon for VTour (e.g., map, explore)
                        size: 80,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Discover your campus virtually', // Adapted main text
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore buildings, facilities, and points of interest from anywhere.', // Adapted subtitle
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to the next screen, likely the Login/Signup screen
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor, // Use your primary color
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 5,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                        ),
                        child: const Text(
                          'Get Started',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}