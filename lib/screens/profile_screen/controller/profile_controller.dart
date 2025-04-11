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

  Future<dynamic> getProfileInfo() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response =
          await ApiGetServices().apiGetServices(AppApiUrl.getProfile);

      if (response['statusCode'] == 200) {
        profileData.value = ProfileModel.fromJson(response.deliveryParcelList);
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
