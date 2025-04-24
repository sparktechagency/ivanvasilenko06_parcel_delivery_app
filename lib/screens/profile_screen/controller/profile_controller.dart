import 'dart:developer';
import 'dart:io';
import 'dart:typed_data'; // Added for Uint8List

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/profile_screen/model/profile_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';
import 'package:path/path.dart' as path;

class ProfileController extends GetxController {
  // Observables for profile data, loading state, and error messages
  var profileData = ProfileModel().obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfileInfo();
  }

  Future<void> getProfileInfo() async {
    isLoading.value = true; // Set loading state to true
    errorMessage.value = ''; // Reset error message
    try {
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      log("🔑 Authorization Token: $token");

      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.getProfile, token: token);

      log("API URL: ${AppApiUrl.getProfile}");
      log("Raw API Response: ${response.toString()}");

      if (response is Map<String, dynamic>) {
        if (response['status'] == 'success' && response['data'] != null) {
          profileData.value = ProfileModel.fromJson(response);
          log("Parsed Profile Data: ${profileData.value.toJson().toString()}");
          log("Profile Data Full Name: ${profileData.value.data?.user?.fullName}");
        } else {
          errorMessage.value =
              'Error: ${response['message'] ?? 'Unknown error occurred'}';
          log("Error in response: ${response['message'] ?? 'No error message'}");
        }
      } else {
        // Handle invalid response formats
        errorMessage.value = 'Invalid server response format';
        log("Invalid response format: $response");
      }
    } catch (e) {
      // Handle exceptions during the API call or data parsing
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Exception error: ${e.toString()}');
    } finally {
      // Ensure loading state is set to false after the operation
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String facebook,
    required String instagram,
    required String whatsapp,
    File? profileImage,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      log("🔑 Authorization Token: $token");

      // Step 1: Create multipart request instance
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse(AppApiUrl.updateProfile),
      );

      // Step 2: Add text fields to the request
      request.fields['fullName'] = fullName;
      request.fields['email'] = email;
      request.fields['facebook'] = facebook;
      request.fields['instagram'] = instagram;
      request.fields['whatsapp'] = whatsapp;

      // Step 3: Add the profile image if provided
      if (profileImage != null) {
        // Step 3a: Read the image file
        File imageFile = File(profileImage.path);

        // Step 3b: Convert image to bytes
        Uint8List imageData = await imageFile.readAsBytes();

        // Step 3c: Add the image as a file to the request
        request.files.add(
          http.MultipartFile.fromBytes(
            'profileImage',
            imageData,
            filename: path.basename(imageFile.path), // Use the file's name
            contentType: MediaType('image', 'jpg'),
          ),
        );
      }

      // Step 4: Add the token to the headers
      request.headers['Authorization'] = 'Bearer $token';

      // Step 5: Send the request
      var response = await request.send();

      // Step 6: Handle the response
      final responseBody = await response.stream.bytesToString();
      log("Raw API Response: $responseBody");

      if (response.statusCode == 200) {
        log("Profile updated successfully");
        await getProfileInfo(); // Refresh the profile data
      } else {
        errorMessage.value =
            'Error: ${response.statusCode} - ${response.reasonPhrase}';
        log("Error Response: $responseBody");
      }
    } catch (e) {
      // Handle exceptions during the API call or data parsing
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Exception error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfileData() async {
    await getProfileInfo(); // Re-fetch profile data
  }
}
