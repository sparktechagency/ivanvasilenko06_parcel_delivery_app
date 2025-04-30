import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notification_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';

class NotificationController extends GetxController {
  var isLoading = true.obs;
  var notifications = <NotificationDataList>[].obs; // Correct list type
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading(true); // Start loading
      error(''); // Reset any previous error
      final response = await ApiGetServices()
          .apiGetServices(AppApiUrl.notifcations, statusCode: 200, body: {});

      NotificationModel notificationModel =
          NotificationModel.fromJson(response);

      // Assign the correct data to notifications list
      notifications.assignAll(notificationModel.notificationData ?? []);
    } catch (ex) {
      log("❎❎❎❎❎❎ Error fetching notifications: ${ex.toString()} ❎❎❎❎❎❎");
      error(ex.toString());
    } finally {
      isLoading(false);
    }
  }
}
