import 'package:flutter/material.dart';
import '../models/location_model.dart';

class MockData {
  static List<Location> get locations => [
    Location(
      id: '1',
      name: 'Main Academic Block',
      category: 'Academic Block',
      description: 'The main academic building housing multiple departments including Computer Science, Electronics, and Mathematics. Features modern classrooms, lecture halls, and faculty offices.',
      imagePath: 'assets/images/academic_block.jpg',
      videoPath: 'assets/videos/academic_tour.mp4',
      latitude: 28.6139,
      longitude: 77.2090,
      features: ['WiFi', 'Air Conditioning', 'Smart Boards', 'Elevator Access'],
      voiceoverText: 'Welcome to the Main Academic Block, the heart of our university where knowledge meets innovation. This state-of-the-art facility houses multiple departments and provides an excellent learning environment.',
    ),
    
    Location(
      id: '2',
      name: 'Boys Hostel A',
      category: 'Hostel',
      description: 'Modern hostel facility for male students with comfortable rooms, common areas, and 24/7 security. Each room is equipped with basic furniture and high-speed internet.',
      imagePath: 'assets/images/boys_hostel.jpg',
      videoPath: 'assets/videos/hostel_tour.mp4',
      latitude: 28.6145,
      longitude: 77.2085,
      features: ['24/7 Security', 'WiFi', 'Common Room', 'Laundry', 'Mess Facility'],
      voiceoverText: 'Boys Hostel A provides a comfortable home away from home for our male students, featuring modern amenities and a supportive community environment.',
    ),
    
    Location(
      id: '3',
      name: 'Central Cafeteria',
      category: 'Cafeteria',
      description: 'The main dining facility serving diverse cuisines including North Indian, South Indian, Chinese, and Continental food. Open from 7 AM to 10 PM.',
      imagePath: 'assets/images/cafeteria.jpg',
      videoPath: 'assets/videos/cafeteria_tour.mp4',
      latitude: 28.6142,
      longitude: 77.2088,
      features: ['Multiple Cuisines', 'Hygienic Food', 'Affordable Prices', 'Seating for 500+'],
      voiceoverText: 'Our Central Cafeteria is the social hub of the campus, offering delicious and affordable meals in a vibrant atmosphere where students gather to dine and socialize.',
    ),
    
    Location(
      id: '4',
      name: 'Central Library',
      category: 'Library',
      description: 'A comprehensive library with over 100,000 books, digital resources, and quiet study spaces. Features include computer lab, group study rooms, and 24/7 access during exams.',
      imagePath: 'assets/images/library.jpg',
      videoPath: 'assets/videos/library_tour.mp4',
      latitude: 28.6140,
      longitude: 77.2092,
      features: ['100K+ Books', 'Digital Resources', 'Study Rooms', '24/7 Access', 'Computer Lab'],
      voiceoverText: 'The Central Library is a treasure trove of knowledge, providing students with access to vast collections of books, journals, and digital resources in a peaceful learning environment.',
    ),
    
    Location(
      id: '5',
      name: 'Computer Science Lab',
      category: 'Laboratory',
      description: 'State-of-the-art computer laboratory with 60 high-performance workstations, latest software, and high-speed internet connectivity for programming and research work.',
      imagePath: 'assets/images/cs_lab.jpg',
      videoPath: 'assets/videos/lab_tour.mp4',
      latitude: 28.6138,
      longitude: 77.2094,
      features: ['60 Workstations', 'Latest Software', 'High-Speed Internet', 'Air Conditioned'],
      voiceoverText: 'Our Computer Science Laboratory is equipped with cutting-edge technology, providing students with hands-on experience in programming, software development, and research.',
    ),
    
    Location(
      id: '6',
      name: 'Sports Complex',
      category: 'Sports Ground',
      description: 'Multi-purpose sports facility including basketball court, tennis court, football ground, and indoor gymnasium. Open for all students with equipment rental available.',
      imagePath: 'assets/images/sports_ground.jpg',
      videoPath: 'assets/videos/sports_tour.mp4',
      latitude: 28.6135,
      longitude: 77.2095,
      features: ['Basketball Court', 'Tennis Court', 'Football Ground', 'Gymnasium', 'Equipment Rental'],
      voiceoverText: 'The Sports Complex promotes physical fitness and team spirit, offering various sports facilities where students can engage in recreational and competitive activities.',
    ),
    
    Location(
      id: '7',
      name: 'Girls Hostel B',
      category: 'Hostel',
      description: 'Secure and comfortable accommodation for female students with modern amenities, common areas, and strict security protocols. Features include study rooms and recreational facilities.',
      imagePath: 'assets/images/girls_hostel.jpg',
      videoPath: 'assets/videos/hostel_tour.mp4',
      latitude: 28.6147,
      longitude: 77.2083,
      features: ['Enhanced Security', 'Study Rooms', 'Recreation Area', 'WiFi', 'Mess Facility'],
      voiceoverText: 'Girls Hostel B provides a safe and nurturing environment for our female students, combining security with comfort and modern amenities.',
    ),
    
    Location(
      id: '8',
      name: 'Physics Laboratory',
      category: 'Laboratory',
      description: 'Well-equipped physics lab with modern instruments for conducting experiments in mechanics, optics, electricity, and magnetism. Suitable for both undergraduate and postgraduate students.',
      imagePath: 'assets/images/physics_lab.jpg',
      videoPath: 'assets/videos/lab_tour.mp4',
      latitude: 28.6141,
      longitude: 77.2089,
      features: ['Modern Instruments', 'Safety Equipment', 'Experiment Kits', 'Research Facilities'],
      voiceoverText: 'The Physics Laboratory enables students to explore the fundamental laws of nature through hands-on experiments and cutting-edge research opportunities.',
    ),
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
      'icon': 'assets/icons/tour.png',
      'color': const Color(0xFF2E7D32),
    },
    {
      'title': 'AR Mode',
      'subtitle': 'Coming Soon',
      'icon': 'assets/icons/ar.png',
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Campus Map',
      'subtitle': 'Interactive map',
      'icon': 'assets/icons/map.png',
      'color': const Color(0xFF7B1FA2),
    },
    {
      'title': 'Search',
      'subtitle': 'Find locations',
      'icon': 'assets/icons/search.png',
      'color': const Color(0xFFD32F2F),
    },
  ];
}