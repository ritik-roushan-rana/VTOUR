import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/location_provider.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/WelcomeScreen.dart';
import 'utils/app_theme.dart';

// Declare a late global variable to hold the API key
late final String googleMapsApiKey;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize the global variable with the key from .env
  googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const VTourApp());
}

class VTourApp extends StatefulWidget {
  const VTourApp({super.key});

  @override
  State<VTourApp> createState() => _VTourAppState();
}

class _VTourAppState extends State<VTourApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || navigatorKey.currentState == null) {
          return;
        }
        if (event == AuthChangeEvent.signedIn && session != null) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
          );
        } else if (event == AuthChangeEvent.signedOut) {
          navigatorKey.currentState!.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            (route) => false,
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
        navigatorKey: navigatorKey,
        title: 'VTour - Virtual Campus Tour',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const MainNavigation(),
        },
      ),
    );
  }
}