import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class FeatureChip extends StatelessWidget {
  final String feature;

  const FeatureChip({
    super.key,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFeatureIcon(feature),
            size: 14,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            feature,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String feature) {
    final lowerFeature = feature.toLowerCase();
    if (lowerFeature.contains('wifi')) return Icons.wifi;
    if (lowerFeature.contains('air') || lowerFeature.contains('ac')) return Icons.ac_unit;
    if (lowerFeature.contains('security')) return Icons.security;
    if (lowerFeature.contains('elevator')) return Icons.elevator;
    if (lowerFeature.contains('parking')) return Icons.local_parking;
    if (lowerFeature.contains('food') || lowerFeature.contains('mess')) return Icons.restaurant;
    if (lowerFeature.contains('laundry')) return Icons.local_laundry_service;
    if (lowerFeature.contains('gym') || lowerFeature.contains('fitness')) return Icons.fitness_center;
    if (lowerFeature.contains('library') || lowerFeature.contains('book')) return Icons.library_books;
    if (lowerFeature.contains('computer') || lowerFeature.contains('lab')) return Icons.computer;
    return Icons.check_circle;
  }
}