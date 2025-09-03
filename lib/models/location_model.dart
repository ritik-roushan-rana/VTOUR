import 'package:flutter/material.dart';

class Location {
  final String? id; // Made nullable
  final String name;
  final String category;
  final String description;
  final String imagePath;
  final String videoPath;
  final double latitude;
  final double longitude;
  final List<String> features;
  final String voiceoverText;
  final bool isAvailable;
  final String? userId; // Add userId to link to authenticated user

  Location({
    this.id, // Now optional
    required this.name,
    required this.category,
    required this.description,
    required this.imagePath,
    required this.videoPath,
    required this.latitude,
    required this.longitude,
    required this.features,
    required this.voiceoverText,
    this.isAvailable = true,
    this.userId, // Make userId optional for creation, but include in model
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'], // Can be null if not present or for new inserts
      name: json['name'],
      category: json['category'],
      description: json['description'],
      imagePath: json['image_path'],
      videoPath: json['video_path'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      features: List<String>.from(json['features'] ?? []), // Handle null features
      voiceoverText: json['voiceover_text'],
      isAvailable: json['is_available'] ?? true,
      userId: json['user_id'], // Read user_id from JSON
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'name': name,
      'category': category,
      'description': description,
      'image_path': imagePath,
      'video_path': videoPath,
      'latitude': latitude,
      'longitude': longitude,
      'features': features,
      'voiceover_text': voiceoverText,
      'is_available': isAvailable,
      'user_id': userId, // Include user_id in JSON for insertion/update
    };
    if (id != null) { // Only include id if it's not null (for updates)
      jsonMap['id'] = id;
    }
    return jsonMap;
  }
}

enum LocationCategory {
  academicBlock,
  hostel,
  cafeteria,
  library,
  lab,
  sportsGround,
  other,
}

extension LocationCategoryExtension on LocationCategory {
  String get displayName {
    switch (this) {
      case LocationCategory.academicBlock:
        return 'Academic Block';
      case LocationCategory.hostel:
        return 'Hostel';
      case LocationCategory.cafeteria:
        return 'Cafeteria';
      case LocationCategory.library:
        return 'Library';
      case LocationCategory.lab:
        return 'Laboratory';
      case LocationCategory.sportsGround:
        return 'Sports Ground';
      case LocationCategory.other:
        return 'Other';
    }
  }

  String get iconPath {
    // Changed to return placeholder URLs for icons
    // You will replace these with actual Supabase Storage URLs later
    switch (this) {
      case LocationCategory.academicBlock:
        return 'https://via.placeholder.com/50/academic_icon.png?text=Academic';
      case LocationCategory.hostel:
        return 'https://via.placeholder.com/50/hostel_icon.png?text=Hostel';
      case LocationCategory.cafeteria:
        return 'https://via.placeholder.com/50/cafeteria_icon.png?text=Cafeteria';
      case LocationCategory.library:
        return 'https://via.placeholder.com/50/library_icon.png?text=Library';
      case LocationCategory.lab:
        return 'https://via.placeholder.com/50/lab_icon.png?text=Lab';
      case LocationCategory.sportsGround:
        return 'https://via.placeholder.com/50/sports_icon.png?text=Sports';
      case LocationCategory.other:
        return 'https://via.placeholder.com/50/other_icon.png?text=Other';
    }
  }

  // ADDED THIS STATIC METHOD
  static LocationCategory? fromDisplayName(String displayName) {
    for (var category in LocationCategory.values) {
      if (category.displayName == displayName) {
        return category;
      }
    }
    return null; // Return null if no matching display name is found
  }
}
