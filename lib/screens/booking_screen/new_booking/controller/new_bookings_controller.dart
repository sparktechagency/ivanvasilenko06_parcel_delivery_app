import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/services/apiServices/api_delete_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_post_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_put_services.dart';

class NewBookingsController extends GetxController {
  RxBool isLoading = false.obs;
  var requestStates = <String, String>{}.obs;

  RxBool isDeleteParcel = false.obs;

  RxBool isCancellingDelivery = false.obs;

  Future<void> acceptParcelRequest(String parcelId, String delivererId) async {
    const String url = AppApiUrl.acceptRequest;
    final String requestKey = '$parcelId-$delivererId';

    // Update state immediately for better user experience
    requestStates[requestKey] = 'accepted';
    update();

    final body = json.encode({
      "parcelId": parcelId,
      "delivererId": delivererId,
    });

    try {
      // Response is now a Map<String, dynamic>
      var response =
          await ApiPutServices().apiPutServices(url: url, body: body);

      // Handle the response based on status field in the Map
      if (response['status'] == 'success') {
        log('Parcel delivery updated successfully');
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.refreshCurrentOrder();
        // Get.snackbar('Success', 'Delivery request accepted successfully');
      } else {
        log('Failed to update parcel: ${response['message']}');
        // Get.snackbar('Error', 'Failed to accept delivery request');

        // Revert state on failure
        requestStates[requestKey] = 'pending';
        requestStates.refresh();
      }
    } catch (error) {
      log('Error: $error');
      // Get.snackbar('Error', 'An error occurred while accepting the request');

      // Revert state on error
      requestStates[requestKey] = 'pending';
      update();
    }
  }

  Future<void> rejectParcelRequest(String parcelId, String delivererId) async {
    const String url = AppApiUrl.cancelDeliveryRequest;
    final String requestKey = '$parcelId-$delivererId';

    // Update state immediately for better user experience
    requestStates[requestKey] = 'rejected';
    update();

    final body = json.encode({
      "parcelId": parcelId,
      "delivererId": delivererId,
    });

    try {
      // Response is now a Map<String, dynamic>
      var response =
          await ApiPostServices().apiPostServices(url: url, body: body);

      // Handle the response based on the 'status' field in the Map
      if (response['status'] == 'success') {
        log('Parcel delivery rejected successfully');
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.refreshCurrentOrder();
        // Get.snackbar('Success', 'Delivery request rejected successfully');
      } else {
        log('Failed to reject parcel: ${response['message']}');
        // Get.snackbar('Error', 'Failed to reject delivery request');

        // Revert state on failure
        requestStates[requestKey] = 'pending';
        requestStates.refresh();
      }
    } catch (error) {
      log('Error: $error');
      // Get.snackbar('Error', 'An error occurred while rejecting the request');

      // Revert state on error
      requestStates[requestKey] = 'pending';
      update();
    }
  }

  Future<void> removeParcelFromMap(String parcelId) async {
    const String url = AppApiUrl.deleteParcel;

    try {
      // Constructing the full URL by appending the parcelId
      var response =
          await ApiDeleteServices().apiDeleteServices(url: '$url$parcelId');

      // Check if response is a Map (could happen if your service returns a Map instead of Response)
      if (response is Map<String, dynamic>) {
        // Handle success case based on your API response structure
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.getCurrentOrder();
        update(); // Use update() instead of refresh() if using GetX
      }
      // Check if response is a Response object (the expected type)
      else if (response is Response) {
        if (response.statusCode == 200) {
          // Refresh the data
          final CurrentOrderController controller =
              Get.find<CurrentOrderController>();
          await controller.getCurrentOrder();
          update(); // Use update() instead of refresh() if using GetX
        } else {
          log('Failed to remove parcel: ${response.statusCode}');
        }
      } else {
        // Fallback for unexpected response type
        log('Unexpected response type: ${response.runtimeType}');
      }
    } catch (error) {
      log('Error: $error');
      rethrow; // Rethrow to handle in UI
    }
  }

  Future<void> cancelDelivery(String parcelId, String delivererId) async {
    const String url = AppApiUrl.cancelAssignDeliver;
    final body = json.encode({
      "parcelId": parcelId,
      "delivererId": delivererId,
    });

    try {
      var response =
          await ApiPutServices().apiPutServices(url: url, body: body);

      // Handle the response based on the response type
      if (response is Map<String, dynamic>) {
        // Handle success case based on your API response structure
        if (response['status'] == 'success') {
          log('Delivery cancelled successfully');
          final CurrentOrderController controller =
              Get.find<CurrentOrderController>();
          await controller.getCurrentOrder();
          update();
        } else {
          log('Failed to cancel delivery: ${response['message']}');
        }
      } else if (response != null && response.statusCode == 201) {
        // Handle Response object case
        final CurrentOrderController controller =
            Get.find<CurrentOrderController>();
        await controller.getCurrentOrder();
        update();
      } else {
        log('Failed to cancel delivery: ${response?.statusCode ?? 'Unknown error'}');
      }
    } catch (error) {
      log('Error: $error');
      rethrow;
    }
  }
}
