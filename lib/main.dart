import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection_app/views/camera_views.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CameraView(),
    );
  }
}
