import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart'; // Assuming API service is imported

import '../models/delivery_screen_models.dart'; // Import your model class

class DeliveryScreenController extends GetxController {
  RxString selectedDeliveryType = ''.obs;
  RxString pickupLocation = 'baridhara'.obs;
  RxString selectedDeliveryLocation = ''.obs;
  RxList<Parcel> parcels = RxList<Parcel>();
  RxBool isLoading = false.obs;

  void setSelectedDeliveryType(String type) {
    selectedDeliveryType.value = type;
    fetchParcels();
  }

  void setSelectedDeliveryLocation(String location) {
    selectedDeliveryLocation.value = location;
    fetchParcels();
  }

  Future<void> fetchParcels() async {
    if (selectedDeliveryType.value.isNotEmpty &&
        selectedDeliveryLocation.value.isNotEmpty) {
      isLoading.value = true;
      try {
        final String url =
            '${AppApiUrl.deliverParcel}?deliveryType=${selectedDeliveryType.value}&pickupLocation=${pickupLocation.value}&deliveryLocation=${selectedDeliveryLocation.value}';

        final response = await ApiGetServices().apiGetServices(url);

        if (response.status == "success" && response.data != null) {
          parcels.value = (response.data as List)
              .map((item) => Parcel.fromJson(item))
              .toList();
        } else {
          parcels.clear();
        }
      } catch (e) {
        log("Error fetching parcels: $e");
        parcels.clear();
        isLoading.value = false;
      }
    } else {
      parcels.clear(); // Clear the parcels list if type or location is empty
    }
  }
}
