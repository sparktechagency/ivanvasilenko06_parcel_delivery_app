import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/routes/app_routes.dart';
import 'package:parcel_delivery_app/screens/profile_screen/model/profile_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_delete_services.dart';
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
    required String facebook,
    required String instagram,
    required String whatsapp,
    required String ID,
    File? Image,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      if (token.isEmpty) {
        errorMessage.value = 'Authorization token is missing';
        log("Token missing");
        isLoading.value = false;
        return;
      }
      log("🔑 Authorization Token: $token");

      var request =
          http.MultipartRequest('PUT', Uri.parse(AppApiUrl.updateProfile));
      request.fields['id'] = ID; // Add ID to request fields
      request.fields['fullName'] = fullName;
      request.fields['facebook'] = facebook;
      request.fields['instagram'] = instagram;
      request.fields['whatsapp'] = whatsapp;

      if (Image != null) {
        File imageFile = File(Image.path);
        if (!await imageFile.exists()) {
          errorMessage.value = 'Image file does not exist';
          log("Image file error");
          isLoading.value = false;
          return;
        }
        Uint8List imageData = await imageFile.readAsBytes();
        String extension =
            path.extension(imageFile.path).toLowerCase().replaceAll('.', '');
        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // Note: Using 'image' as per your latest code
            imageData,
            filename: path.basename(imageFile.path),
            contentType:
                MediaType('image', extension == 'jpg' ? 'jpeg' : extension),
          ),
        );
      }

      request.headers['Authorization'] = 'Bearer $token';
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();
      log("Raw API Response: $responseBody");

      if (response.statusCode == 200) {
        log("Profile updated successfully");
        await refreshProfileData(); // Refresh profile data
        Get.back(); // Navigate back to ProfileScreen
      } else {
        try {
          final jsonResponse = json.decode(responseBody);
          errorMessage.value =
              'Error: ${response.statusCode} - ${jsonResponse['message'] ?? response.reasonPhrase}';
        } catch (e) {
          errorMessage.value =
              'Error: ${response.statusCode} - ${response.reasonPhrase}';
        }
        log("Error Response: $responseBody");
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Exception error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProfile() async {
    isLoading(true);
    errorMessage.value = '';

    try {
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);

      if (token.isEmpty) {
        errorMessage.value = "No valid token found, please login again.";
        isLoading(false);
        return;
      }
      var url = AppApiUrl.deleteProfile;
      log("Deleting profile at: $url with token: ${token.substring(0, 20)}...");

      final response =
          await ApiDeleteServices().apiDeleteServices(url: url, token: token);

      if (response != null) {
        log("Profile deleted successfully");
        SharePrefsHelper.remove(SharedPreferenceValue.token);

        // Use a slight delay to ensure all UI operations complete
        await Future.delayed(const Duration(milliseconds: 100));

        Get.offAllNamed(AppRoutes.splashScreen);
      } else {
        errorMessage.value =
            'Failed to delete profile - server returned null response';
        log('Failed to delete profile - null response');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        errorMessage.value = "Authentication failed. Please login again.";
        SharePrefsHelper.remove(SharedPreferenceValue.token);
        //Get.offAllNamed(AppRoutes.loginScreen);
      } else {
        errorMessage.value =
            'Delete failed: ${e.response?.data?['message'] ?? e.message}';
      }
      log('DioException in deleteProfile: ${e.toString()}');
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Exception error in deleteProfile: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshProfileData() async {
    await getProfileInfo();
  }
}
