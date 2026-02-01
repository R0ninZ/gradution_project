import 'package:get/get.dart';

abstract class BaseController extends GetxController {
  final isLoading = false.obs;

  void startLoading() => isLoading.value = true;
  void stopLoading() => isLoading.value = false;
}
