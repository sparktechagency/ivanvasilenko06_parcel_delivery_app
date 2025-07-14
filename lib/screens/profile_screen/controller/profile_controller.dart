import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' show debugPrint;
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
    log('🎯 ProfileController initialized');
    getProfileInfo();
  }

  Future<void> getProfileInfo() async {
    log('🚀 Starting getProfileInfo API call');

    isLoading.value = true;
    errorMessage.value = '';

    try {
      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
      log("🔑 Authorization Token: ${token.isNotEmpty ? '${token.substring(0, 20)}...' : 'EMPTY'}");

      if (token.isEmpty) {
        log('❌ No token found, cannot make API call');
        errorMessage.value = 'No authentication token found';
        return;
      }

      log('🌐 Making API call to: ${AppApiUrl.getProfile}');
      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.getProfile, token: token);

      log('📥 Raw API Response Type: ${response.runtimeType}');
      log('📥 Raw API Response: ${response.toString()}');

      if (response is Map<String, dynamic>) {
        log('✅ Response is valid Map');
        log('📊 Response keys: ${response.keys.toList()}');
        log('📊 Response status: ${response['status']}');
        log('📊 Response message: ${response['message']}');

        if (response['status'] == 'success' && response['data'] != null) {
          log('✅ Response status is success, parsing data...');

          // Parse the profile data
          profileData.value = ProfileModel.fromJson(response);


          if (profileData.value.data != null) {
            log('   - User exists: ${profileData.value.data!.user != null}');

            if (profileData.value.data!.user != null) {
              final user = profileData.value.data!.user!;
              log('   - Image (raw): "${user.image}"');
              log('   - Image type: ${user.image.runtimeType}');


              // Test image URL construction
              if (user.image != null && user.image!.isNotEmpty) {
                String testUrl;
                if (user.image!.startsWith('http')) {
                  testUrl = user.image!;
                } else {
                  testUrl = "${AppApiUrl.liveDomain}/${user.image!.replaceAll(RegExp(r'^/+'), '')}";
                }
                log('🔗 Constructed image URL: $testUrl');

                // Test the URL accessibility
                _testImageUrl(testUrl);
              } else {
                log('❌ No image URL available');
              }
            }
          }

          log('✅ Profile data successfully parsed and stored');
        } else {
          errorMessage.value = 'Error: ${response['message'] ?? 'Unknown error occurred'}';
          log("❌ API returned error: ${response['message'] ?? 'No error message'}");
        }
      } else {
        errorMessage.value = 'Invalid server response format';
        log("❌ Invalid response format - not a Map: ${response.runtimeType}");
      }
    } catch (e, stackTrace) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('❌ Exception in getProfileInfo: ${e.toString()}');
      log('❌ Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
      log('🏁 getProfileInfo completed, isLoading set to false');
    }
  }

  // Helper method to test image URL accessibility
  Future<void> _testImageUrl(String url) async {
    try {
      log('🔍 Testing image URL: $url');

      final response = await http.head(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          log('⏰ Image URL test timed out');
          throw Exception('Timeout');
        },
      );

      log('🔍 Image URL test result:');
      log('   - Status Code: ${response.statusCode}');
      log('   - Content-Type: ${response.headers['content-type']}');
      log('   - Content-Length: ${response.headers['content-length']}');

      if (response.statusCode == 200) {
        log('✅ Image URL is accessible');
      } else {
        log('❌ Image URL returned status: ${response.statusCode}');
      }
    } catch (e) {
      log('❌ Image URL test failed: $e');
    }
  }

  // Method to manually trigger a profile reload (for debugging)
  void forceReload() {
    log('🔄 Force reloading profile data');
    getProfileInfo();
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
