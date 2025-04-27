import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_put_services.dart';

class NewBookingsController extends GetxController {
  // Map to track the state of each request (pending, accepted, rejected)
  var requestStates = <String, String>{}.obs;

  Future<void> acceptParcelRequest(String parcelId, String delivererId) async {
    const String url = AppApiUrl.acceptRequest;
    final String requestKey = '$parcelId-$delivererId';

    // Update state immediately for better user experience
    requestStates[requestKey] = 'accepted';
    requestStates.refresh();

    final body = json.encode({
      "parcelId": parcelId,
      "delivererId": delivererId,
    });

    try {
      Response response =
          await ApiPutServices().apiPutServices(url: url, body: body);

      if (response.statusCode == 200) {
        log('Parcel delivery updated successfully');
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.refreshCurrentOrder();
        Get.snackbar('Success', 'Delivery request accepted successfully');
      } else {
        log('Failed to update parcel: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to accept delivery request');

        // Revert state on failure
        requestStates[requestKey] = 'pending';
        requestStates.refresh();
      }
    } catch (error) {
      log('Error: $error');
      Get.snackbar('Error', 'An error occurred while accepting the request');

      // Revert state on error
      requestStates[requestKey] = 'pending';
      requestStates.refresh();
    }
  }

  Future<void> rejectParcelRequest(String parcelId, String delivererId) async {
    const String url = AppApiUrl.cancelDeliveryRequest;
    final String requestKey = '$parcelId-$delivererId';

    // Update state immediately for better user experience
    requestStates[requestKey] = 'rejected';
    requestStates.refresh();

    final body = json.encode({
      "parcelId": parcelId,
      "delivererId": delivererId,
    });

    try {
      Response response =
          await ApiPostServices().apiPostServices(url: url, body: body);

      if (response.statusCode == 200) {
        log('Parcel delivery rejected successfully');
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.refreshCurrentOrder();
        Get.snackbar('Success', 'Delivery request rejected successfully');
      } else {
        log('Failed to reject parcel: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to reject delivery request');

        // Revert state on failure
        requestStates[requestKey] = 'pending';
        requestStates.refresh();
      }
    } catch (error) {
      log('Error: $error');
      Get.snackbar('Error', 'An error occurred while rejecting the request');

      // Revert state on error
      requestStates[requestKey] = 'pending';
      requestStates.refresh();
    }
  }

  // Clear request states (can be called when navigating away or refreshi
  // ng)
  void clearRequestStates() {
    requestStates.clear();
    requestStates.refresh();
  }
}
