import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class VerifyPhoneController extends GetxController {
  RxBool isLoading = false.obs;
  var otpController = TextEditingController();
  var isButtonDisabled = true.obs;
  var start = 60.obs;
  Timer? _timer;
  bool isFromLogin = false;
  final DeviceInfo _deviceInfo = DeviceInfo();

  // Initialize with default values to prevent null issues
  String firebaseID = '';
  String phoneNumber = '';
  String email = '';
  String fullName = '';
  String country = '';
  String fcmToken = '';
  String deviceId = '';
  String deviceType = '';
  String screen = '';

  // Add a flag to prevent multiple initializations
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    
    // Prevent multiple initializations
    if (_isInitialized) return;
    _isInitialized = true;

    // Move heavy operations to the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeController();
    });
  }

  Future<void> _initializeController() async {
    try {
      final arguments = Get.arguments;
      
      // Validate arguments exist
      if (arguments == null) {
        AppSnackBar.error("Missing verification data");
        Get.back();
        return;
      }

      final Map<String, dynamic> args = arguments is Map<String, dynamic> 
          ? arguments 
          : {};

      // Extract arguments with proper null handling
      phoneNumber = args["phoneNumber"]?.toString() ?? 
                   args["mobileNumber"]?.toString() ?? "";
      email = args["email"]?.toString() ?? "";
      fullName = args["fullName"]?.toString() ?? "";
      country = args["country"]?.toString() ?? "";
      fcmToken = args["fcmToken"]?.toString() ?? "";
      deviceId = args["deviceId"]?.toString() ?? "";
      deviceType = args["deviceType"]?.toString() ?? "";
      screen = args["screen"]?.toString() ?? "";

      isFromLogin = screen == "login";

      // Validate required phone number
      if (phoneNumber.isEmpty) {
        AppSnackBar.error("Phone number is required");
        Get.back();
        return;
      }

      // Start timer after validation
      _startTimerSafely();
      
    } catch (e) {
      debugPrint("Error initializing VerifyPhoneController: $e");
      AppSnackBar.error("Failed to initialize verification screen");
      Get.back();
    }
  }

  void _startTimerSafely() {
    try {
      // Cancel existing timer if any
      _timer?.cancel();
      
      isButtonDisabled.value = true;
      start.value = 60;
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isInitialized) {
          timer.cancel();
          return;
        }
        
        if (start.value <= 0) {
          isButtonDisabled.value = false;
          timer.cancel();
        } else {
          start.value--;
        }
      });
    } catch (e) {
      debugPrint("Error starting timer: $e");
      isButtonDisabled.value = false;
    }
  }

  Future<void> verifyOTP() async {
    if (otpController.text.trim().isEmpty) {
      AppSnackBar.error("Please enter the OTP");
      return;
    }

    if (isLoading.value) return; // Prevent multiple calls

    try {
      isLoading.value = true;
      
      if (isFromLogin) {
        await handleLoginFlow();
      } else {
        await handleSignupFlow();
      }
    } catch (e) {
      debugPrint("Error from verifyOTP: $e");
      AppSnackBar.error("Verification failed. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleLoginFlow() async {
    try {
      // Get fresh device info asynchronously
      String currentDeviceId = await _deviceInfo.getDeviceId();
      String currentDeviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        "mobileNumber": phoneNumber,
        "otpCode": otpController.text.trim(),
        "fcmToken": fcmToken.isEmpty ? "" : fcmToken,
        "deviceId": currentDeviceId,
        "deviceType": currentDeviceType,
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpLoginVerify,
        body: body,
        statusCode: 200,
      );

      if (data != null && data["data"] != null) {
        String? token = data["data"]["token"]?.toString();
        
        if (token != null && token.isNotEmpty) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, token);
          
          // Use Get.offAll with a delay to ensure proper navigation
          await Future.delayed(const Duration(milliseconds: 100));
          Get.offAll(() => const BottomNavScreen());
        } else {
          AppSnackBar.error("Invalid authentication token received");
        }
      } else {
        AppSnackBar.error("Login verification failed");
      }
    } catch (e) {
      debugPrint("Error from handleLoginFlow: $e");
      AppSnackBar.error("Login failed: Please try again");
    }
  }

  Future<void> handleSignupFlow() async {
    try {
      // Get fresh device info asynchronously
      String currentDeviceId = await _deviceInfo.getDeviceId();
      String currentDeviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        "mobileNumber": phoneNumber,
        "otpCode": otpController.text.trim(),
        "fcmToken": fcmToken.isEmpty ? "" : fcmToken,
        "deviceId": currentDeviceId,
        "deviceType": currentDeviceType,
        "role": "sender"
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpVerify,
        body: body,
        statusCode: 200,
      );

      if (data != null) {
        String? token = data["token"]?.toString();
        
        if (token != null && token.isNotEmpty) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, token);
          
          // Use Get.offAll with a delay to ensure proper navigation
          await Future.delayed(const Duration(milliseconds: 100));
          Get.offAll(() => const BottomNavScreen());
        } else {
          AppSnackBar.error("Invalid registration token received");
        }
      } else {
        AppSnackBar.error("Signup verification failed");
      }
    } catch (e) {
      debugPrint("Error from handleSignupFlow: $e");
      AppSnackBar.error("Signup failed: Please try again");
    }
  }

  Future<void> resendCode() async {
    if (phoneNumber.isEmpty) {
      AppSnackBar.error("Phone number not available");
      return;
    }

    try {
      Map<String, String> body = {
        "mobileNumber": phoneNumber,
      };

      var data = await ApiPostServices().apiPostServices(
        url: AppApiUrl.phoneOtpResend,
        body: body,
        statusCode: 200,
      );

      if (data != null) {
        AppSnackBar.success("OTP resent successfully");
        _startTimerSafely();
      } else {
        AppSnackBar.error("Failed to resend OTP");
      }
    } catch (e) {
      debugPrint("Error from resendCode: $e");
      AppSnackBar.error("Failed to resend code");
    }
  }

  @override
  void onClose() {
    _isInitialized = false;
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}