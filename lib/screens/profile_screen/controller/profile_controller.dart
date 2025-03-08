import 'dart:math';

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
  
  Future<void> getProfileInfo() async {
    isLoading.value = true; // Set loading to true
    errorMessage.value = ''; // Clear any previous error message

    try {
      // Make the API call using ApiGetServices
      final response = await ApiGetServices().apiGetServices(AppApiUrl.getProfile);

      if (response.statusCode == 200) {
        profileData.value = ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load profile data: ${response.statusCode}');
      }
    } on Exception catch (e) {
      errorMessage.value = 'An error occurred: ${e.toString()}';
      print('Error: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  // Method to refresh profile data
  Future<void> refreshProfileData() async {
    await getProfileInfo();
  }
}