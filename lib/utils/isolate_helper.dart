import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// This function must be a top-level function.
void _loadAssetInBackground(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String assetPath = args[1];
  
  try {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final fileName = assetPath.split('/').last;
    final file = File('${tempDir.path}/$fileName');
    
    await file.writeAsBytes(byteData.buffer.asUint8List());
    
    sendPort.send(file.path);
  } catch (e) {
    sendPort.send('Error: $e');
  }
}