import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import CachedNetworkImage
import '../models/location_model.dart';
import '../utils/app_theme.dart';

class CampusMapWidget extends StatefulWidget {
  final List<Location> locations;
  final Function(Location) onLocationTapped;

  const CampusMapWidget({
    super.key,
    required this.locations,
    required this.onLocationTapped,
  });

  @override
  State<CampusMapWidget> createState() => _CampusMapWidgetState();
}

class _CampusMapWidgetState extends State<CampusMapWidget> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundColor,
      child: InteractiveViewer(
        transformationController: _transformationController,
        boundaryMargin: const EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 3.0,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.green[50],
            // CORRECTED: Use CachedNetworkImage for the background image
            image: DecorationImage(
              image: CachedNetworkImageProvider(
                'https://via.placeholder.com/1200x800/campus_map.jpg?text=Campus+Map', // Placeholder URL for the map
              ),
              fit: BoxFit.cover,
              opacity: 0.3,
            ),
          ),
          child: Stack(
            children: [
              // Campus background elements
              _buildCampusBackground(),
              // Location markers
              ...widget.locations.map((location) => _buildLocationMarker(location)),
              // Map legend
              _buildMapLegend(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampusBackground() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: CampusMapPainter(),
      ),
    );
  }

  Widget _buildLocationMarker(Location location) {
    // Calculate position based on lat/lng (simplified for demo)
    final double x = (location.longitude - 77.2080) * 10000 + 200;
    final double y = (28.6150 - location.latitude) * 10000 + 200;

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () => widget.onLocationTapped(location),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getMarkerColor(location.category),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            _getMarkerIcon(location.category),
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildMapLegend() {
    final categories = [
      {'name': 'Academic', 'color': Colors.blue, 'icon': Icons.school},
      {'name': 'Hostel', 'color': Colors.orange, 'icon': Icons.home},
      {'name': 'Cafeteria', 'color': Colors.red, 'icon': Icons.restaurant},
      {'name': 'Library', 'color': Colors.purple, 'icon': Icons.library_books},
      {'name': 'Lab', 'color': Colors.green, 'icon': Icons.science},
      {'name': 'Sports', 'color': Colors.teal, 'icon': Icons.sports_soccer},
    ];
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Legend',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ...categories.map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: category['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        category['name'] as String,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Color _getMarkerColor(String category) {
    switch (category) {
      case 'Academic Block':
        return Colors.blue;
      case 'Hostel':
        return Colors.orange;
      case 'Cafeteria':
        return Colors.red;
      case 'Library':
        return Colors.purple;
      case 'Laboratory':
        return Colors.green;
      case 'Sports Ground':
        return Colors.teal;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getMarkerIcon(String category) {
    switch (category) {
      case 'Academic Block':
        return Icons.school;
      case 'Hostel':
        return Icons.home;
      case 'Cafeteria':
        return Icons.restaurant;
      case 'Library':
        return Icons.library_books;
      case 'Laboratory':
        return Icons.science;
      case 'Sports Ground':
        return Icons.sports_soccer;
      default:
        return Icons.location_on;
    }
  }
}

class CampusMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    // Draw campus roads
    final roadPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    // Main road
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );
    // Cross roads
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );
    // Draw green areas (parks/gardens)
    final greenPaint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      50,
      greenPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      60,
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
