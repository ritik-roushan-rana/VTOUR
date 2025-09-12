// lib/services/geocoding_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geocoding_old;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math';

class GeocodingService {
  Future<geocoding_old.Location?> getCoordinates(String address) async {
    try {
      final String googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
      
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'address': address,
          'location_bias': 'circle:5000@12.9716,79.1594',
          'key': googleMapsApiKey,
        },
      );
      print('Geocoding API URL: $uri');

      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          return geocoding_old.Location(
            latitude: location['lat'],
            longitude: location['lng'],
            timestamp: DateTime.now(),
          );
        } else {
          print('Geocoding API Error: ${data['status']}');
          if (data['error_message'] != null) {
            print('Error Message: ${data['error_message']}');
          }
        }
      }
      return null;
    } catch (e) {
      print('Error geocoding address: $e');
      return null;
    }
  }
}