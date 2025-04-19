import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/profile_screen/model/profile_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/appStroage/share_helper.dart';

class ProfileController extends GetxController {
  var profileData = ProfileModel().obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfileInfo();
  }

  Future<dynamic> getProfileInfo() async {
    isLoading.value = true;
    errorMessage.value = '';

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
        errorMessage.value = 'Invalid server response format';
        log("Invalid response format: $response");
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      log('Exception error: ${e.toString()}');
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
