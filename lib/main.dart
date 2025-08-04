import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/location_provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_navigation.dart'; // Import MainNavigation
import 'utils/app_theme.dart';
import 'models/location_model.dart';

// Your Supabase credentials
const SUPABASE_URL = 'https://wwkqdexdncskvpgygfik.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind3a3FkZXhkbmNza3ZwZ3lnZmlrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQyNTgwNDUsImV4cCI6MjA2OTgzNDA0NX0.sIKG8MsleIizQTg_JiOG3FXvI7r_BmWHpgabMJXkXAQ';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );
  runApp(const VTourApp());
}

class VTourApp extends StatefulWidget {
  const VTourApp({super.key});

  @override
  State<VTourApp> createState() => _VTourAppState();
}

class _VTourAppState extends State<VTourApp> {
  // Create a GlobalKey for the NavigatorState
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and navigate accordingly
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      // Schedule navigation to run after the current frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Ensure the navigator is available before attempting navigation
        if (!mounted || navigatorKey.currentState == null) {
          return;
        }
        if (event == AuthChangeEvent.signedIn) {
          // User signed in, navigate to MainNavigation (which contains HomeScreen)
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()), // Changed to MainNavigation
            (route) => false, // Remove all previous routes
          );
        } else if (event == AuthChangeEvent.signedOut) {
          // User signed out, navigate to login page using the global key
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false, // Remove all previous routes
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(Supabase.instance.client),
        ),
        ChangeNotifierProvider(
          create: (context) => LocationProvider(Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Assign the global key to MaterialApp
        title: 'VTour - Virtual Campus Tour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/', // Set initial route to SplashScreen
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const MainNavigation(), // Also update this route to MainNavigation
        },
      ),
    );
  }
}