import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notification_model.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notify_parcel_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_patch_services.dart';

class NotificationController extends GetxController {
  var notificationModel = Rx<NotificationModel?>(null);
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var isNotificationReceived = false.obs;
  var receivingDeliveries = true.obs;

  // Variables for parcel notifications
  var parcelNotifications = <NotifyParcelModel>[].obs;
  var isParcelLoading = true.obs;
  var parcelError = ''.obs;

  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreNotifications = true.obs;
  var parcelCurrentPage = 1.obs;
  var parcelTotalPages = 1.obs;
  var hasMoreParcelNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchParcelNotifications();
  }

  Future<void> fetchNotifications({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading(true); // Set loading state for first page only
      }

      final response = await ApiGetServices().apiGetServices(
          "${AppApiUrl.notifcations}?page=$page&limit=10",
          statusCode: 200,
          body: {});

      if (response != null) {
        // Parse the response into the NotificationModel
        NotificationModel newNotifications =
            NotificationModel.fromJson(response);

        // Handle pagination
        if (newNotifications.data?.pagination != null) {
          totalPages.value = newNotifications.data!.pagination!.pages ?? 1;
          currentPage.value = page;
          hasMoreNotifications.value = currentPage.value < totalPages.value;
        }

        // Set the model
        if (page == 1) {
          notificationModel.value = newNotifications;
        } else if (notificationModel.value != null &&
            notificationModel.value!.data != null &&
            newNotifications.data != null &&
            newNotifications.data!.notifications != null &&
            notificationModel.value!.data!.notifications != null) {
          // Add new notifications to the existing list
          notificationModel.value!.data!.notifications!
              .addAll(newNotifications.data!.notifications!);
          notificationModel.refresh();
        }

        log("✅✅✅ Fetched notifications, page $page of ${totalPages.value}");
      } else {
        throw Exception("Failed to load notifications - null response");
      }
    } catch (ex) {
      log("❎❎❎❎❎❎ Error fetching notifications: ${ex.toString()} ❎❎❎❎❎❎");
      errorMessage(ex.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchParcelNotifications({int page = 1}) async {
    try {
      if (page == 1) {
        isParcelLoading(true); // Set loading state for the first page
        parcelError(''); // Reset any previous error
      }

      final response = await ApiGetServices().apiGetServices(
          "${AppApiUrl.notifyParcel}?page=$page&limit=10",
          statusCode: 200,
          body: {});

      if (response != null) {
        NotifyParcelModel parcelModel = NotifyParcelModel.fromJson(response);

        // Handle pagination
        if (parcelModel.data?.pagination != null) {
          parcelTotalPages.value = parcelModel.data!.pagination!.pages ?? 1;
          parcelCurrentPage.value = page;
          hasMoreParcelNotifications.value =
              parcelCurrentPage.value < parcelTotalPages.value;
        }

        // Add the notifications to the list
        if (parcelModel.data?.notifications != null &&
            parcelModel.data!.notifications!.isNotEmpty) {
          if (page == 1) {
            parcelNotifications.clear(); // Clear the list for the first page
          }
          parcelNotifications.add(parcelModel); // Add new data
          log("✅ Parcel notifications fetched: Page $page");
        } else {
          if (page == 1) parcelNotifications.clear(); // Clear if no data
          log("⚠️ No parcel notifications found");
        }
      } else {
        throw Exception("Failed to load parcel notifications - null response");
      }
    } catch (ex) {
      log("❌ Error fetching parcel notifications: ${ex.toString()}");
      parcelError(ex.toString());
    } finally {
      isParcelLoading(false);
    }
  }

  Future<void> loadMoreNotifications() async {
    if (hasMoreNotifications.value && !isLoading.value) {
      await fetchNotifications(page: currentPage.value + 1);
    }
  }

  Future<void> loadMoreParcelNotifications() async {
    if (hasMoreParcelNotifications.value && !isParcelLoading.value) {
      await fetchParcelNotifications(page: parcelCurrentPage.value + 1);
    }
  }

  Future<bool> receivingDeliveryNotification(bool status) async {
    try {
      isLoading(true);
      final response = await ApiPatchServices().apiPatchServices(
        statusCode: 200,
        body: {"notificationStatus": status},
        url: AppApiUrl.receivingDeliveryNotification,
      );
      bool serverStatus = response['notificationStatus'] ?? status;
      receivingDeliveries.value = serverStatus;
      if (serverStatus == true) {
        fetchParcelNotifications();
        refresh();
      }

      log("✅✅✅ Delivery notification status changed to: ${receivingDeliveries.value}");
      return serverStatus;
    } catch (ex) {
      log("❎❎❎❎❎❎ Error updating delivery notification status: ${ex.toString()} ❎❎❎❎❎❎");
      errorMessage(ex.toString());
      return receivingDeliveries
          .value; // Return previous value if request fails
    } finally {
      isLoading(false);
    }
  }
}
