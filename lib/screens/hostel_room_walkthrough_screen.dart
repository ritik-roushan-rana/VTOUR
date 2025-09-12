import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';
import '../utils/app_theme.dart';
import '../models/location_model.dart';

class HostelRoomWalkthroughScreen extends StatelessWidget {
  final Location hostel;
  final String panoUrl;

  const HostelRoomWalkthroughScreen({
    super.key,
    required this.hostel,
    required this.panoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${hostel.name} - 360° Walkthrough'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Center(
        child: Panorama(
          animSpeed: 1.0,
          // FIX: Replaced Pan → Orientation (device gyroscope controls the view)
          sensorControl: SensorControl.Orientation,
          child: Image.network(
            panoUrl,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Text('Failed to load 360° image.')),
          ),
        ),
      ),
    );
  }
}