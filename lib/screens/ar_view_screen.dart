import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../models/location_model.dart';
import 'location_detail_screen.dart';

class ARViewScreen extends StatefulWidget {
  final Location location;

  const ARViewScreen({Key? key, required this.location}) : super(key: key);

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  bool _showInfoLabel = false;
  
  @override
  Widget build(BuildContext context) {
    if (widget.location.arModelPath == null) {
      return Scaffold(
        appBar: AppBar(title: Text('AR View for ${widget.location.name}')),
        body: const Center(
          child: Text('No AR model available for this location.'),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('AR View for ${widget.location.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationDetailScreen(location: widget.location),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _showInfoLabel = !_showInfoLabel;
              });
            },
            child: ModelViewer(
              src: widget.location.arModelPath!,
              ar: true,
              arModes: const ['scene-viewer', 'webxr', 'quick-look'],
              arScale: ArScale.fixed,
              cameraControls: true,
              loading: Loading.eager,
              autoRotate: true,
              alt: 'A 3D model of ${widget.location.name}',
              backgroundColor: Colors.transparent,
            ),
          ),
          
          if (_showInfoLabel)
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 80.0),
                child: Card(
                  color: Colors.white.withOpacity(0.9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.location.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationDetailScreen(location: widget.location),
                              ),
                            );
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}