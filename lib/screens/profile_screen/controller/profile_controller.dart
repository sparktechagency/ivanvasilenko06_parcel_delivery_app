// File: profile_controller.dart
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/profile_screen/model/profile_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

class ProfileController extends GetxController {
  var profileData = ProfileModel().obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfileInfo();
  }

  // In profile_controller.dart, modify the getProfileInfo method:
  Future<dynamic> getProfileInfo() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response =
          await ApiGetServices().apiGetServices(AppApiUrl.getProfile);
      log("API URL: ${AppApiUrl.getProfile}");
      log("Raw API Response: ${response.toString()}");
      log("Status Code: ${response['statusCode']}");

      // Create the profile model from the entire response
      if (response['status'] == 'success' && response['data'] != null) {
        profileData.value = ProfileModel.fromJson(response);
        log("Parsed Profile Data: ${profileData.value.toJson().toString()}");
        log("Profile Data Full Name: ${profileData.value.data?.fullName}");
      } else {
        errorMessage.value = 'Error: ${response['message'] ?? 'No message'}';
        log("Error: ${response['message'] ?? 'No message'}");
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
    return null;
  }

  // Method to refresh profile data
  Future<void> refreshProfileData() async {
    await getProfileInfo();
  }
}
