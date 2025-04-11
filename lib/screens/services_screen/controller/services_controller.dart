import 'dart:developer';
import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/services_screen/model/promote_delivery_parcel.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import '../../../constants/api_url.dart';
import '../../../services/appStroage/share_helper.dart';

class ServiceController extends GetxController {
  RxBool loading = false.obs;
  RxList<DeliveryPromote> parcelList = <DeliveryPromote>[].obs;

  Future<void> fetchParcelList() async {
    try {
      loading.value = true;
      log("Fetching parcel list...");

      var token = await SharePrefsHelper.getString(SharedPreferenceValue.token);

      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.servicePromote, token: token);

      log("API Response: $response");

      if (response["data"] != null && response["data"].isNotEmpty) {
        parcelList.clear();
        for (var element in response['data']) {
          parcelList.add(DeliveryPromote.fromJson(element));
        }
        log("Parcel list updated. Total items: ${parcelList.length}");
      } else {
        Get.snackbar('Error', 'No parcels found.');
      }
    } catch (e) {
      log("Error: $e");
      Get.snackbar('Error', 'Failed to load parcels. Please try again later.');
    } finally {
      loading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchParcelList();
  }
}
