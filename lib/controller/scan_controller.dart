import 'package:camera/camera.dart';
import 'package:get/state_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> camera; //all avaliable cameras

  var isCameraInitialized = false.obs;

  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      camera = await availableCameras();

      cameraController = CameraController(
        camera[0], //front camera [1]
        ResolutionPreset.max,
      );
      await cameraController.initialize();
      isCameraInitialized(true);
      update(); //updating widget
    } else {
      print("Permission denied");
    }
  }
}
