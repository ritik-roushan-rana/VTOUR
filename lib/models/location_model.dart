// lib/models/location_model.dart

import 'package:flutter/material.dart';
import 'hostel_room_model.dart';

class Location {
  final String? id;
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
  final String? userId;
  final String? arModelPath;
  final List<HostelRoom>? hostelRooms;
  final String? genderType; // Changed to String

  Location({
    this.id,
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
    this.userId,
    this.arModelPath,
    this.hostelRooms,
    this.genderType, // Changed to String
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      imagePath: json['image_path'],
      videoPath: json['video_path'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      features: List<String>.from(json['features'] ?? []),
      voiceoverText: json['voiceover_text'],
      isAvailable: json['is_available'] ?? true,
      userId: json['user_id'],
      arModelPath: json['ar_model_path'],
      genderType: json['gender_type'], // Directly assign string
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
      'user_id': userId,
      'ar_model_path': arModelPath,
    };
    if (id != null) {
      jsonMap['id'] = id;
    }
    if (genderType != null) {
      jsonMap['gender_type'] = genderType;
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

  static LocationCategory? fromDisplayName(String displayName) {
    for (var category in LocationCategory.values) {
      if (category.displayName == displayName) {
        return category;
      }
    }
    return null;
  }
}