import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart'; // Assuming you have this for consistent styling

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      // On successful sign-up, navigate back to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign up successful! Please log in.')),
        );
        Navigator.of(context).pop(); // Go back to login screen
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Removed AppBar to allow for full-screen background and custom header if desired
      body: Container(
        // Added a subtle gradient background for a modern iOS feel
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.8), // Lighter blue
              AppTheme.primaryColor, // Primary blue
              AppTheme.primaryColor.withOpacity(0.9), // Slightly darker blue
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              // Adjusted elevation and shadow for a softer look
              elevation: 12,
              shadowColor: Colors.black.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Icon/Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                        // Added a subtle shadow to the icon container
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school, // Or a custom app icon
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Create Your Account',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign up to explore the campus',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, // Remove default border
                        ),
                        prefixIcon: const Icon(Icons.email, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.grey[100], // Lighter fill color
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, // Remove default border
                        ),
                        prefixIcon: const Icon(Icons.lock, color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.grey[100], // Lighter fill color
                        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity, // Make button full width
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 5, // Add elevation to button
                          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text(
                                'Sign Up',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Go back to login screen
                      },
                      child: Text(
                        'Already have an account? Sign In',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
