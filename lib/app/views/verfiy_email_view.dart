import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:gradution_project/app/controllers/verfiy_email_controller.dart';

class VerifyEmailView extends GetView<VerifyEmailController> {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text('app_name'.tr,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF00A7E1),
                      letterSpacing: 1.2)),
              const SizedBox(height: 80),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                    color: const Color(0xFF00A7E1),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.email_outlined, size: 45, color: Colors.white),
              ),
              const SizedBox(height: 40),
              Text('verify_your_email'.tr,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('verify_email_subtitle'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, height: 1.5)),
              const SizedBox(height: 40),
              GetBuilder<VerifyEmailController>(
                builder: (c) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(c.length, (index) {
                    return Container(
                      width: 45,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: c.focusNodes[index].hasFocus
                              ? const Color(0xFF003366)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: TextField(
                        controller: c.controllers[index],
                        focusNode: c.focusNodes[index],
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        onChanged: (value) => c.onCodeChanged(value, index),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: GetBuilder<VerifyEmailController>(
                  builder: (c) => ElevatedButton(
                    onPressed: c.isLoading ? null : c.submit,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366)),
                    child: c.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('continue_btn'.tr,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('didnt_receive_code'.tr,
                      style: const TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: controller.resendCode,
                    child: Text('resend_code'.tr,
                        style: const TextStyle(
                            color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              GestureDetector(
                onTap: () => Get.back(),
                child: Text('back_to_login'.tr,
                    style: const TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
