import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  bool isProcessingFrame = false;
  final StreamController<CameraImage> _imageStreamController =
      StreamController<CameraImage>();

  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFlite();
  }

  @override
  void dispose() {
    cameraController.dispose();
    Tflite.close();
    _imageStreamController.close();
    super.dispose();
  }

  Future<void> initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController = CameraController(
        cameras[0], // Use the first camera (front camera if available)
        ResolutionPreset.high,
        enableAudio: false,
      );

      await cameraController.initialize().then((_) {
        cameraController.startImageStream((image) {
          if (!_imageStreamController.isClosed) {
            _imageStreamController.add(image);
          }
        });

        _imageStreamController.stream.listen((image) {
          if (!isProcessingFrame) {
            isProcessingFrame = true;
            objectDetector(image);
          }
        });

        isCameraInitialized.value = true;
        update();
      }).catchError((e) {
        print("Camera initialization error: $e");
      });
    } else {
      print("Camera permission denied");
    }
  }

  Future<void> initTFlite() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        isAsset: true,
        numThreads: 1,
        useGpuDelegate: false,
      );
    } catch (e) {
      print("Failed to load TFLite model: $e");
    }
  }

  Future<void> objectDetector(CameraImage image) async {
    try {
      var results = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.4,
        asynch: true,
      );

      if (results != null) {
        print("Results: $results");
      }
    } catch (e) {
      print("Error during object detection: $e");
    } finally {
      isProcessingFrame = false;
    }
  }
}
