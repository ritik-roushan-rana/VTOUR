import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location_model.dart';

class LocationService {
  final SupabaseClient _supabaseClient;

  LocationService(this._supabaseClient);

  Future<void> addLocation(Location location) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated. Cannot add location.');
      }
      
      // Create a new location with the authenticated user's ID
      final locationData = location.toJson();
      locationData['user_id'] = userId; // Ensure user_id is set
      
      print('Adding location with user_id: $userId'); // Debug log
      print('Location data: $locationData'); // Debug log
      
      await _supabaseClient.from('locations').insert(locationData);
      print('Location added successfully: ${location.name}');
    } on PostgrestException catch (error) {
      print('Error adding location: ${error.message}');
      print('Error code: ${error.code}');
      print('Error details: ${error.details}');
      rethrow;
    } catch (error) {
      print('Unexpected error adding location: $error');
      rethrow;
    }
  }

  Future<List<Location>> getLocations() async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        print('No authenticated user. Returning empty list of locations.');
        return [];
      }

      print('Fetching locations for user: $userId'); // Debug log

      final List<Map<String, dynamic>> data = await _supabaseClient
          .from('locations')
          .select();

      print('Fetched ${data.length} locations'); // Debug log
      return data.map((json) => Location.fromJson(json)).toList();
    } on PostgrestException catch (error) {
      print('Error fetching locations: ${error.message}');
      rethrow;
    } catch (error) {
      print('Unexpected error fetching locations: $error');
      rethrow;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
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
      print('Location updated successfully: ${location.name}');
    } on PostgrestException catch (error) {
      print('Error updating location: ${error.message}');
      rethrow;
    } catch (error) {
      print('Unexpected error updating location: $error');
      rethrow;
    }
  }

  Future<void> deleteLocation(String id) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated. Cannot delete location.');
      }
      
      await _supabaseClient
          .from('locations')
          .delete()
          .eq('id', id);
      print('Location deleted successfully: $id');
    } on PostgrestException catch (error) {
      print('Error deleting location: ${error.message}');
      rethrow;
    } catch (error) {
      print('Unexpected error deleting location: $error');
      rethrow;
    }
  }
}
