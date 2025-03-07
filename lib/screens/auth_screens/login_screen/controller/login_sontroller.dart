import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var isOtpSent = false.obs;
  var verificationId = ''.obs;

  // FirebaseAuth instance (uncomment if using Firebase)
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  void sendOtp(String mobileNumber) async {
    try {
      isLoading(true);

      // Send OTP request (Firebase Example)
      // await _auth.verifyPhoneNumber(
      //   phoneNumber: "+88$mobileNumber", // Bangladesh country code
      //   verificationCompleted: (PhoneAuthCredential credential) async {
      //     await _auth.signInWithCredential(credential);
      //   },
      //   verificationFailed: (FirebaseAuthException e) {
      //     Get.snackbar("Error", e.message ?? "Verification failed");
      //   },
      //   codeSent: (String id, int? resendToken) {
      //     verificationId.value = id;
      //     isOtpSent(true);
      //   },
      //   codeAutoRetrievalTimeout: (String id) {
      //     verificationId.value = id;
      //   },
      // );

      // Mock API Response (Replace with actual API call)
      await Future.delayed(Duration(seconds: 2));
      verificationId.value = "123456"; // Fake verification ID
      isOtpSent(true);

      Get.snackbar("OTP Sent", "OTP has been sent to $mobileNumber");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }

  void verifyOtp(String otp) async {
    try {
      isLoading(true);

      // Firebase OTP verification (Uncomment if using Firebase)
      // PhoneAuthCredential credential = PhoneAuthProvider.credential(
      //   verificationId: verificationId.value,
      //   smsCode: otp
      // );
      // await _auth.signInWithCredential(credential);
      //
      // Mock API Response (Replace with actual API call)
      await Future.delayed(Duration(seconds: 2));

      if (otp == "123456") {
        Get.snackbar("Success", "OTP Verified Successfully");
        // Navigate to home or dashboard
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("Error", "Invalid OTP");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading(false);
    }
  }
}
