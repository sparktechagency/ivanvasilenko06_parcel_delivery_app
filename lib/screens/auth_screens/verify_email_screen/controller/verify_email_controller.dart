import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/bottom_nav_bar/bottom_nav_bar.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:parcel_delivery_app/services/deviceInfo/device_info.dart';
import 'package:parcel_delivery_app/widgets/app_snackbar/custom_snackbar.dart';

class VerifyEmailController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController otpController = TextEditingController();
  String emailId = "";
  var isButtonDisabled = true.obs;
  var start = 60.obs;
  Timer? _timer;
  bool isFromLogin = false;
  final DeviceInfo _deviceInfo = DeviceInfo();

  late String firebaseID;
  late String phoneNumber;
  late String email;
  late String fullName;
  late String country;
  late String fcmToken;
  late String deviceId;
  late String deviceType;
  late String screen;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};

    firebaseID = arguments["firebaseID"] ?? "";
    phoneNumber = arguments["phoneNumber"] ?? "";
    email = arguments["email"] ?? "";
    fullName = arguments["fullName"] ?? "";
    country = arguments["country"] ?? "";
    fcmToken = arguments["fcmToken"] ?? "";
    deviceId = arguments["deviceId"] ?? "";
    deviceType = arguments["deviceType"] ?? "";
    screen = arguments["screen"] ?? "";
    isFromLogin = screen == "login";

    log("Screen type: $screen, isFromLogin: $isFromLogin");

    startTimer();

    // Validation check
    if (Get.arguments == null || firebaseID.isEmpty || phoneNumber.isEmpty) {
      log("Missing required arguments");
      Get.back();
    }
  }

  void startTimer() {
    isButtonDisabled.value = true;
    start.value = 60; // Changed back to 180 seconds
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start.value == 0) {
        isButtonDisabled.value = false;
        timer.cancel();
      } else {
        start.value--;
      }
    });
  }

  // Main OTP verification method that handles both flows
  Future<void> verifyOTP() async {
    if (otpController.text.isEmpty) {
      AppSnackBar.error("Please enter the OTP");
      return;
    }

    try {
      isLoading.value = true;

      // Firebase OTP verification (common for both flows)
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: firebaseID,
        smsCode: otpController.text,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        log("Firebase OTP verification successful");

        // Route to appropriate flow based on screen type
        if (isFromLogin) {
          await handleLoginFlow();
        } else {
          await handleSignupFlow();
        }
      } else {
        AppSnackBar.error("OTP verification failed. Please try again.");
      }
    } on FirebaseAuthException catch (e) {
      log("Firebase Auth Error: ${e.code} - ${e.message}");
      _handleFirebaseAuthError(e);
    } catch (e) {
      log("Error in Firebase OTP verification: $e");
      AppSnackBar.error(
          "An error occurred while verifying the OTP. Please try again.");
    } finally {
      isLoading.value = false;
    }
  }

  // Handle signup flow after successful Firebase verification
  Future<void> handleSignupFlow() async {
    try {
      // Get fresh device info
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        "fullName": fullName,
        "country": country,
        "email": email,
        "mobileNumber": phoneNumber,
        "fcmToken": fcmToken,
        "deviceId": deviceId,
        "deviceType": deviceType,
        "role": "sender"
      };

      var response = await ApiPostServices().apiPostServices(
        url: AppApiUrl.registerWithPhone,
        body: body,
        statusCode: 201,
      );

      if (response["status"] == "success") {
        log("Registration successful");

        if (response["token"] != null) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, response["token"].toString());

          String token =
              await SharePrefsHelper.getString(SharedPreferenceValue.token);
          log("Saved registration token: $token");
        }

        AppSnackBar.success("Account created successfully!");
        final FirebaseAuth auth = FirebaseAuth.instance;
        final GoogleSignIn googleSignIn = GoogleSignIn();

        // Signout Call
        await auth.signOut();
        await googleSignIn.signOut();

        Get.offAll(() => const BottomNavScreen());
      } else {
        AppSnackBar.error("Registration failed. Please try again.");
      }
    } catch (e) {
      log("Error in signup flow: $e");
      AppSnackBar.error("Registration failed. Please try again.");
    }
  }

  // Handle login flow after successful Firebase verification
  Future<void> handleLoginFlow() async {
    try {
      // Get fresh device info and FCM token
      var fcmToken =
          await SharePrefsHelper.getString(SharedPreferenceValue.fcmToken);
      String deviceId = await _deviceInfo.getDeviceId();
      String deviceType = await _deviceInfo.getDeviceType();

      Map<String, String> body = {
        'mobileNumber': phoneNumber,
        'fcmToken': fcmToken.toString(),
        'deviceId': deviceId,
        'deviceType': deviceType
      };

      var response = await ApiPostServices().apiPostServices(
        url: AppApiUrl.loginWithPhone,
        body: body,
        statusCode: 200,
      );

      if (response != null && response["status"] == "success") {
        if (response["token"] != null) {
          await SharePrefsHelper.setString(
              SharedPreferenceValue.token, response["token"].toString());

          String token =
              await SharePrefsHelper.getString(SharedPreferenceValue.token);
          log("Saved login token: $token");
        }

        AppSnackBar.success("Login successful!");

        final FirebaseAuth auth = FirebaseAuth.instance;
        final GoogleSignIn googleSignIn = GoogleSignIn();

        // Signout Call
        await auth.signOut();
        await googleSignIn.signOut();

        Get.offAll(() => const BottomNavScreen());
      } else {
        AppSnackBar.error("Login failed. Please try again.");
      }
    } catch (e) {
      log("Error in login flow: $e");
      AppSnackBar.error("Login failed. Please try again.");
    }
  }

  // Handle Firebase Auth errors
  void _handleFirebaseAuthError(FirebaseAuthException e) {
    String errorMessage;

    switch (e.code) {
      case 'invalid-verification-code':
        errorMessage = "Invalid OTP. Please enter the correct code.";
        break;
      case 'invalid-verification-id':
        errorMessage =
            "Verification session expired. Please request a new OTP.";
        break;
      case 'session-expired':
        errorMessage = "OTP has expired. Please request a new one.";
        break;
      default:
        errorMessage = "OTP verification failed. Please try again.";
    }

    AppSnackBar.error(errorMessage);
  }

  // Resend OTP functionality
  void resendCode() {
    log("Resend code initiated");
    // You might want to call the appropriate resend method based on the flow
    if (isFromLogin) {
      _resendLoginOTP();
    } else {
      _resendSignupOTP();
    }
    startTimer();
  }

  // Resend OTP for signup flow
  Future<void> _resendSignupOTP() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Resend failed: ${e.message}");
          AppSnackBar.error("Failed to resend OTP. Please try again.");
        },
        codeSent: (String verificationId, int? resendToken) {
          firebaseID = verificationId; // Update the verification ID
          AppSnackBar.success("OTP resent successfully!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          firebaseID = verificationId;
        },
      );
    } catch (e) {
      log("Error resending signup OTP: $e");
      AppSnackBar.error("Failed to resend OTP. Please try again.");
    }
  }

  // Resend OTP for login flow
  Future<void> _resendLoginOTP() async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log("Resend failed: ${e.message}");
          AppSnackBar.error("Failed to resend OTP. Please try again.");
        },
        codeSent: (String verificationId, int? resendToken) {
          firebaseID = verificationId; // Update the verification ID
          AppSnackBar.success("OTP resent successfully!");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          firebaseID = verificationId;
        },
      );
    } catch (e) {
      log("Error resending login OTP: $e");
      AppSnackBar.error("Failed to resend OTP. Please try again.");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}
