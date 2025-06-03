import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../constants/api_url.dart';
import '../../../../routes/app_routes.dart';
import '../../../../services/apiServices/api_post_services.dart';
import '../../../../services/appStroage/share_helper.dart';
import '../../../../services/deviceInfo/device_info.dart';
import '../../../../widgets/app_snackbar/custom_snackbar.dart';
import '../../../bottom_nav_bar/bottom_nav_bar.dart';

class VerifyPhoneSignupController extends GetxController {
  // Form and UI state
  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  RxBool isLoading = false.obs;
  RxBool isPhoneLoading = false.obs;

  // Text controllers
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController countryController = TextEditingController();

  // Phone number handling
  RxString completePhoneNumber = ''.obs;
  String countryCode = '+1'; // Default country code

  // Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfo _deviceInfo = DeviceInfo();

  @override
  void onInit() {
    super.onInit();
    // Initialize any default values if needed
  }

  // Update complete phone number when country code or phone changes
  void updateCompletePhoneNumber() {
    completePhoneNumber.value = '$countryCode${phoneController.text}';
  }

  // Set country code
  void setCountryCode(String code) {
    countryCode = code;
    updateCompletePhoneNumber();
  }

  // Main signup OTP sending method
  Future<void> sendSignupOTP() async {
    try {
      if (signUpFormKey.currentState!.validate()) {
        isLoading.value = true;

        var fcmToken =
            await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
        updateCompletePhoneNumber();

        // Get device info
        String deviceId = await _deviceInfo.getDeviceId();
        String deviceType = await _deviceInfo.getDeviceType();

        // If device info is not initialized yet, get it asynchronously
        if (deviceId == 'unknown' || deviceType == 'unknown') {
          deviceId = await _deviceInfo.getDeviceId();
          deviceType = await _deviceInfo.getDeviceType();
        }

        // Prepare signup data
        Map<String, String> signupData = {
          "fullName": fullNameController.text,
          "country": countryController.text,
          "email": emailController.text,
          "mobileNumber": completePhoneNumber.value,
          "fcmToken": fcmToken.toString(),
          "deviceId": deviceId,
          "deviceType": deviceType,
          "role": "sender"
        };

        log('📱 Sending signup OTP to: ${completePhoneNumber.value}');

        // Send OTP via Firebase
        await _auth.verifyPhoneNumber(
          phoneNumber: completePhoneNumber.value,
          verificationCompleted: (PhoneAuthCredential credential) async {
            // Auto verification completed
            await _handleAutoVerification(credential, signupData);
          },
          verificationFailed: (FirebaseAuthException e) {
            log("Signup OTP verification failed: ${e.message}");
            _handleVerificationError(e);
          },
          codeSent: (String verificationId, int? resendToken) {
            log("Signup OTP sent successfully");
            _navigateToVerification(verificationId, signupData);
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            log("Signup OTP auto retrieval timeout");
          },
        );
      }
    } catch (e) {
      log("Error in sendSignupOTP: $e");
      AppSnackBar.error("Failed to send OTP. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Handle auto verification
  Future<void> _handleAutoVerification(
      PhoneAuthCredential credential, Map<String, String> signupData) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        log("Auto verification successful, proceeding with signup");
        await _completeSignupProcess(signupData);
      }
    } catch (e) {
      log("Error in auto verification: $e");
      AppSnackBar.error("Verification failed. Please try again.");
    }
  }

  // Navigate to verification screen
  void _navigateToVerification(
      String verificationId, Map<String, String> signupData) {
    Get.toNamed(
      AppRoutes.verifyEmailScreen,
      arguments: {
        "firebaseID": verificationId,
        "phoneNumber": completePhoneNumber.value,
        "email": emailController.text,
        "fullName": fullNameController.text,
        "country": countryController.text,
        "fcmToken": signupData["fcmToken"],
        "deviceId": signupData["deviceId"],
        "deviceType": signupData["deviceType"],
        "screen": "signup",
      },
    );
  }

  // Complete signup process after verification
  Future<void> _completeSignupProcess(Map<String, String> signupData) async {
    try {
      var response = await ApiPostServices().apiPostServices(
        url: AppApiUrl.registerWithPhone,
        body: signupData,
        statusCode: 201,
      );

      if (response["status"] == "success") {
        log("Signup successful");

        if (response["token"] != null) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, response["token"].toString());
        }

        AppSnackBar.success("Account created successfully!");

        // Sign out from Firebase and Google
        await _signOutServices();

        // Navigate to main app
        Get.offAll(() => const BottomNavScreen());
      } else {
        AppSnackBar.error("Registration failed. Please try again.");
      }
    } catch (e) {
      log("Error completing signup: $e");
      AppSnackBar.error("Registration failed. Please try again.");
    }
  }

  // Handle verification errors
  void _handleVerificationError(FirebaseAuthException e) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-phone-number':
        errorMessage = "Invalid phone number format.";
        break;
      case 'too-many-requests':
        errorMessage = "Too many attempts. Please try again later.";
        break;
      case 'quota-exceeded':
        errorMessage = "SMS quota exceeded. Please try again later.";
        break;
      default:
        errorMessage = "Failed to send OTP. Please try again.";
    }
    AppSnackBar.error(errorMessage);
  }

  // Sign out from Firebase and Google services
  Future<void> _signOutServices() async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      await auth.signOut();
      await googleSignIn.signOut();
    } catch (e) {
      log("Error signing out: $e");
    }
  }

  // Form validation methods
  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? validateCountry(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your country';
    }
    return null;
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    countryController.dispose();
    super.onClose();
  }
}
