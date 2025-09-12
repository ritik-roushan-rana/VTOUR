// lib/services/hostel_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/hostel_room_model.dart';

class HostelService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch hostel rooms by locationId
  Future<List<HostelRoom>> fetchHostelRoomsByLocationId(String locationId) async {
    final response = await _supabase
        .from('hostel_rooms')
        .select()
        .eq('location_id', locationId);

    // Convert Supabase result into List<HostelRoom>
    return (response as List<dynamic>)
        .map((room) => HostelRoom.fromJson(room as Map<String, dynamic>))
        .toList();
  }
}