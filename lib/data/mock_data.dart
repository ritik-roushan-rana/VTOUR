// lib/data/mock_data.dart
import 'package:flutter/material.dart';
import '../models/location_model.dart';
import '../models/hostel_room_model.dart';

class MockData {
  static List<Location> get locations => [
    Location(
      id: '1',
      name: 'Main Academic Block',
      category: 'Academic Block',
      description: 'The main academic building housing multiple departments including Computer Science, Electronics, and Mathematics. Features modern classrooms, lecture halls, and faculty offices.',
      imagePath: 'https://via.placeholder.com/150/academic_block.jpg',
      videoPath: 'https://www.example.com/videos/academic_tour.mp4',
      latitude: 28.6139,
      longitude: 77.2090,
      features: ['WiFi', 'Air Conditioning', 'Smart Boards', 'Elevator Access'],
      voiceoverText: 'Welcome to the Main Academic Block...',
      genderType: 'Other',
    ),
    Location(
      id: '2',
      name: 'Boys Hostel A',
      category: 'Hostel',
      description: 'Modern hostel facility for male students...',
      imagePath: 'https://via.placeholder.com/150/boys_hostel.jpg',
      videoPath: 'https://www.example.com/videos/hostel_tour.mp4',
      latitude: 28.6145,
      longitude: 77.2085,
      features: ['24/7 Security', 'WiFi', 'Common Room', 'Laundry', 'Mess Facility'],
      voiceoverText: 'Boys Hostel A provides a comfortable home...',
      genderType: 'Mens',
      hostelRooms: [ // Now a list of HostelRoom objects
        HostelRoom(
          id: 'room_101',
          locationId: '2',
          roomType: 'Single Room',
          photoUrls: ['https://via.placeholder.com/150/hostel_room_1.jpg'],
          features: ['Attached Bathroom', 'Study Table', 'Cupboard'],
          panoUrl: 'https://pannellum.org/images/alma.jpg',
        ),
        HostelRoom(
          id: 'room_102',
          locationId: '2',
          roomType: 'Double Room',
          photoUrls: ['https://via.placeholder.com/150/hostel_room_2.jpg'],
          features: ['Balcony', 'Two beds', 'Shared Bathroom'],
          panoUrl: 'https://pannellum.org/images/alma.jpg',
        ),
      ],
    ),
    Location(
      id: '7',
      name: 'Girls Hostel B',
      category: 'Hostel',
      description: 'Secure and comfortable accommodation for female students...',
      imagePath: 'https://via.placeholder.com/150/girls_hostel.jpg',
      videoPath: 'https://www.example.com/videos/hostel_tour.mp4',
      latitude: 28.6147,
      longitude: 77.2083,
      features: ['Enhanced Security', 'Study Rooms', 'Recreation Area', 'WiFi', 'Mess Facility'],
      voiceoverText: 'Girls Hostel B provides a safe and nurturing environment...',
      genderType: 'Ladies',
      hostelRooms: [ // Now a list of HostelRoom objects
        HostelRoom(
          id: 'room_201',
          locationId: '7',
          roomType: 'Single Room',
          photoUrls: ['https://via.placeholder.com/150/g_hostel_room_1.jpg'],
          features: ['Attached Bathroom', 'Study Table', 'Cupboard'],
          panoUrl: 'https://pannellum.org/images/alma.jpg',
        ),
        HostelRoom(
          id: 'room_202',
          locationId: '7',
          roomType: 'Triple Room',
          photoUrls: ['https://via.placeholder.com/150/g_hostel_room_2.jpg'],
          features: ['Balcony', 'Three beds', 'Shared Bathroom'],
          panoUrl: 'https://pannellum.org/images/alma.jpg',
        ),
      ],
    ),
    // Add other Location objects here as needed
    // ...
  ];

  static List<String> get categories => [
    'All',
    'Academic Block',
    'Hostel',
    'Cafeteria',
    'Library',
    'Laboratory',
    'Sports Ground',
  ];

  static List<Map<String, dynamic>> get quickActions => [
    {
      'title': 'Virtual Tour',
      'subtitle': 'Start guided tour',
      'icon': 'https://via.placeholder.com/50/tour_icon.png?text=Tour',
      'color': const Color(0xFF2E7D32),
    },
    {
      'title': 'AR Mode',
      'subtitle': 'Coming Soon',
      'icon': 'https://via.placeholder.com/50/ar_icon.png?text=AR',
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Campus Map',
      'subtitle': 'Interactive map',
      'icon': 'https://via.placeholder.com/50/map_icon.png?text=Map',
      'color': const Color(0xFF7B1FA2),
    },
    {
      'title': 'Search',
      'subtitle': 'Find locations',
      'icon': 'https://via.placeholder.com/50/search_icon.png?text=Search',
      'color': const Color(0xFFD32F2F),
    },
  ];
}