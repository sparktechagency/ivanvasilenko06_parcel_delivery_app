import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerifyPhoneController extends GetxController {
  var otpController = TextEditingController();
  var isButtonDisabled = true.obs;
  var start = 10.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() {
    isButtonDisabled.value = true;
    start.value = 10;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start.value == 0) {
        isButtonDisabled.value = false;
        timer.cancel();
      } else {
        start.value--;
      }
    });
  }

  void resendCode() {
    // Add your resend code logic here
    print("Resend code logic executed");
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
