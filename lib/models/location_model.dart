class Location {
  final String id;
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

  Location({
    required this.id,
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
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      description: json['description'],
      imagePath: json['imagePath'],
      videoPath: json['videoPath'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      features: List<String>.from(json['features']),
      voiceoverText: json['voiceoverText'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'description': description,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'latitude': latitude,
      'longitude': longitude,
      'features': features,
      'voiceoverText': voiceoverText,
      'isAvailable': isAvailable,
    };
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
        return 'assets/icons/academic.png';
      case LocationCategory.hostel:
        return 'assets/icons/hostel.png';
      case LocationCategory.cafeteria:
        return 'assets/icons/cafeteria.png';
      case LocationCategory.library:
        return 'assets/icons/library.png';
      case LocationCategory.lab:
        return 'assets/icons/lab.png';
      case LocationCategory.sportsGround:
        return 'assets/icons/sports.png';
      case LocationCategory.other:
        return 'assets/icons/other.png';
    }
  }
}