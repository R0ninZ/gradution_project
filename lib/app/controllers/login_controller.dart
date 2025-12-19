
import 'package:get/get.dart';

class LoginController extends GetxController {
  // State: True = Full Screen Blue. False = Wave Header.
  var isSplashMode = true.obs;
  
  // State: Controls the visibility of the input fields
  var showLoginInputs = false.obs;

  @override
  void onInit() {
    super.onInit();
    _startAnimation();
  }

  void _startAnimation() async {
    // 1. Hold the full blue screen for 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    // 2. Shrink the blue background
    isSplashMode.value = false;

    // 3. Wait for the shrink to finish (800ms), then show inputs
    await Future.delayed(const Duration(milliseconds: 800));
    showLoginInputs.value = true;
  }
}