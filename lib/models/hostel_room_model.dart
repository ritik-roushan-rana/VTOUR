// lib/models/hostel_room_model.dart


class HostelRoom {
  final String id;
  final String locationId;
  final String roomType;
  final List<String> photoUrls;
  final List<String> features;
  final String panoUrl; // NEW: Field for the 360 walkthrough URL

  HostelRoom({
    required this.id,
    required this.locationId,
    required this.roomType,
    required this.photoUrls,
    required this.features,
    required this.panoUrl, // NEW: Added to the constructor
  });

  factory HostelRoom.fromJson(Map<String, dynamic> json) {
    return HostelRoom(
      id: json['id']?.toString() ?? '',
      locationId: json['location_id']?.toString() ?? '',
      roomType: json['room_type']?.toString() ?? '',
      photoUrls: (json['photo_urls'] is List)
          ? List<String>.from(json['photo_urls'].map((url) => url.toString()))
          : <String>[],
      features: (json['features'] is List)
          ? List<String>.from(json['features'].map((f) => f.toString()))
          : <String>[],
      panoUrl: json['pano_url']?.toString() ?? '', // NEW: Parse the pano_url
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'room_type': roomType,
      'photo_urls': photoUrls,
      'features': features,
      'pano_url': panoUrl, // NEW: Added to JSON output
    };
  }
}