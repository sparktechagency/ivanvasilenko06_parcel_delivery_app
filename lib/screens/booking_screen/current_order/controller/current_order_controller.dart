import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/model/current_order_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

class CurrentOrderController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<CurrentOrderModel> currentOrdersModel = CurrentOrderModel().obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentOrder();
  }

  Future<CurrentOrderModel?> getCurrentOrder() async {
    isLoading(true); // Start loading
    try {
      // Make API call to fetch current orders
      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.getCurrentOrders, statusCode: 200);

      // It seems the response is already a Map, not an HTTP response object
      // So we need to handle it differently
      log("API response received: ${response.runtimeType}");

      try {
        if (response is Map<String, dynamic>) {
          if (response.containsKey("body")) {
            var body = response["body"];
            if (body is Map<String, dynamic>) {
              currentOrdersModel.value = CurrentOrderModel.fromJson(body);
            } else if (body is String) {
              currentOrdersModel.value =
                  CurrentOrderModel.fromJson(json.decode(body));
            }
          } else {
            currentOrdersModel.value = CurrentOrderModel.fromJson(response);
          }

          log("Current orders model updated: ${currentOrdersModel.value.data?.length ?? 0} orders found");
          return currentOrdersModel.value;
        } else {
          log("Unexpected response type: ${response.runtimeType}");
          return null;
        }
      } catch (parseError) {
        log("Error parsing response data: ${parseError.toString()}");
        return null;
      }
    } catch (ex) {
      log("Error in getCurrentOrder: ${ex.toString()}");
      return null;
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshCurrentOrder() async {
    isLoading(true);
    await getCurrentOrder();
    isLoading(false);
  }
}
