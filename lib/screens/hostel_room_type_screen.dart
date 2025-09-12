import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../models/location_model.dart';
import '../models/hostel_room_model.dart';
import  '../services/hostel_service.dart'; // This line was added
import '../widgets/feature_chip.dart';
import 'navigation_screen.dart';
import 'ar_view_screen.dart';
import 'hostel_room_walkthrough_screen.dart';
import 'photo_view_screen.dart';

class HostelRoomTypeScreen extends StatefulWidget {
  final Location hostel;

  const HostelRoomTypeScreen({super.key, required this.hostel});

  @override
  State<HostelRoomTypeScreen> createState() => _HostelRoomTypeScreenState();
}

class _HostelRoomTypeScreenState extends State<HostelRoomTypeScreen> {
  String? _selectedRoomType;
  bool _isPlaying = false;

  late Future<List<HostelRoom>> _roomsFuture;
  List<HostelRoom> _allRooms = [];
  HostelRoom? _selectedRoom;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _roomsFuture = _fetchRooms();
  }

  Future<List<HostelRoom>> _fetchRooms() async {
    try {
      final hostelService = HostelService();
      final rooms = await hostelService.fetchHostelRoomsByLocationId(widget.hostel.id!);

      // DEBUG: Print the raw data received from the backend
      print('DEBUG: Fetched ${rooms.length} room entries.');
      print('DEBUG: Raw data: $rooms');
      
      if (rooms.isNotEmpty) {
        _allRooms = rooms;
        _selectedRoomType = rooms.first.roomType;
        _updateSelectedRoom();
      }

      return rooms;
    } catch (e) {
      // DEBUG: Print the error if data fetching fails
      print('DEBUG: Failed to fetch rooms with error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      throw Exception("Failed to fetch rooms: $e");
    }
  }

  void _updateSelectedRoom() {
    _selectedRoom = _allRooms.firstWhere(
      (room) => room.roomType == _selectedRoomType,
      orElse: () => _allRooms.first,
    );
    // DEBUG: Print the selected room's data and photo URLs
    print('DEBUG: Selected Room: ${_selectedRoom?.roomType}');
    print('DEBUG: Photo URLs for selected room: ${_selectedRoom?.photoUrls}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.hostel.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.hostel.imagePath,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FutureBuilder<List<HostelRoom>>(
                  future: _roomsFuture,
                  builder: (context, snapshot) {
                    // DEBUG: Print the state of the FutureBuilder
                    print('DEBUG: FutureBuilder connection state: ${snapshot.connectionState}');
                    print('DEBUG: FutureBuilder has data: ${snapshot.hasData}');
                    print('DEBUG: FutureBuilder has error: ${snapshot.hasError}');

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No rooms available for this hostel."));
                    }

                    final roomTypes = snapshot.data!.map((room) => room.roomType).toSet().toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select a Room Type',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedRoomType,
                          decoration: InputDecoration(
                            labelText: 'Room Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: roomTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedRoomType = newValue;
                              _updateSelectedRoom();
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        if (_selectedRoom != null) ..._buildRoomWalkthroughSection(),
                        if (_selectedRoom != null) ..._buildOtherHostelFeatures(),
                      ],
                    );
                  },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRoomWalkthroughSection() {
    return [
      Text(
        "Photos of ${_selectedRoom!.roomType}",
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedRoom!.photoUrls.length,
          itemBuilder: (context, index) {
            final photoUrl = _selectedRoom!.photoUrls[index];
            return Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoViewScreen(
                        imageUrls: _selectedRoom!.photoUrls,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: photoUrl,
                    width: 250,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HostelRoomWalkthroughScreen(
                  hostel: widget.hostel,
                  panoUrl: _selectedRoom!.panoUrl, // MODIFIED: Pass the panoUrl
                ),
              ),
            );
          },
          icon: const Icon(Icons.vrpano_rounded),
          label: Text("View 360 Walkthrough for ${_selectedRoom!.roomType}"),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildOtherHostelFeatures() {
    return [
      const SizedBox(height: 24),
      _buildFeatures(),
      const SizedBox(height: 24),
      _buildVoiceoverSection(),
      const SizedBox(height: 24),
      _buildActionButtons(),
    ];
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Features & Amenities',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedRoom!.features.map((f) => Chip(label: Text(f))).toList(),
        ),
      ],
    );
  }

  Widget _buildVoiceoverSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.record_voice_over, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                "Audio Description",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggleVoiceover,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  color: AppTheme.primaryColor,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.hostel.voiceoverText,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _startTour,
            icon: const Icon(Icons.tour),
            label: const Text("Start Virtual Tour"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _navigate,
                icon: const Icon(Icons.navigation),
                label: const Text("Navigate"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showARMode,
                icon: const Icon(Icons.view_in_ar),
                label: const Text("AR View"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _toggleVoiceover() {
    setState(() => _isPlaying = !_isPlaying);

    if (_isPlaying) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _isPlaying = false);
      });
    }
  }

  void _startTour() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Virtual Tour"),
        content: Text("Starting virtual tour for ${widget.hostel.name}."),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
      ),
    );
  }

  void _navigate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NavigationScreen(
          destinationName: widget.hostel.name,
          destinationLat: widget.hostel.latitude,
          destinationLng: widget.hostel.longitude,
        ),
      ),
    );
  }

  void _showARMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ARViewScreen(location: widget.hostel),
      ),
    );
  }
}