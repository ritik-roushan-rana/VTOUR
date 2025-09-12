import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';
import '../models/hostel_room_model.dart';

class LocationService {
  final SupabaseClient _supabaseClient;

  LocationService(this._supabaseClient);

  Future<void> addLocation(Location location) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot add location.');
    }
    
    final locationData = location.toJson();
    locationData['user_id'] = userId;
    
    await _supabaseClient.from('locations').insert(locationData);
  }

  Future<List<Location>> getLocations() async {
    final List<Map<String, dynamic>> data = await _supabaseClient
        .from('locations')
        .select();

    return data.map((json) => Location.fromJson(json)).toList();
  }

  Future<List<HostelRoom>> getHostelRooms(String locationId) async {
    final List<Map<String, dynamic>> data = await _supabaseClient
        .from('hostel_rooms')
        .select()
        .eq('location_id', locationId);
    
    return data.map((json) => HostelRoom.fromJson(json)).toList();
  }

  Future<void> updateLocation(Location location) async {
    if (location.id == null) {
      throw Exception('Cannot update location without an ID.');
    }
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot update location.');
    }
    
    await _supabaseClient
        .from('locations')
        .update(location.toJson())
        .eq('id', location.id!);
  }

  Future<void> deleteLocation(String id) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated. Cannot delete location.');
    }
    
    await _supabaseClient
        .from('locations')
        .delete()
        .eq('id', id);
  }
}