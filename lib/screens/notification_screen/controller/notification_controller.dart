import 'dart:developer';

import 'package:get/get.dart';
import 'package:parcel_delivery_app/constants/api_url.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notification_model.dart';
import 'package:parcel_delivery_app/screens/notification_screen/notification_model/notify_parcel_model.dart';
import 'package:parcel_delivery_app/services/apiServices/api_get_services.dart';
import 'package:parcel_delivery_app/services/apiServices/api_patch_services.dart';

import '../read_notificaiton/read_notifcation_model.dart';

class NotificationController extends GetxController {
  var notificationModel = Rx<NotificationModel?>(null);
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var isNotificationReceived = false.obs;
  var receivingDeliveries = true.obs;

  // Added RxInt for unreadCount
  var unreadCount = 0.obs;

  //! Variables for parcel notifications
  var parcelNotifications = <NotifyParcelModel>[].obs;
  var isParcelLoading = true.obs;
  var parcelError = ''.obs;

  //! Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreNotifications = true.obs;
  var parcelCurrentPage = 1.obs;
  var parcelTotalPages = 1.obs;
  var hasMoreParcelNotifications = true.obs;

  RxSet<String> sentParcelIds = RxSet<String>();

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchParcelNotifications();
    isReadNotification(); // Call to fetch initial unreadCount
  }

  bool isRequestSent(String? parcelId) {
    if (parcelId == null || parcelId.isEmpty) return false;
    return sentParcelIds.contains(parcelId);
  }

  Future<void> fetchNotifications({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading(true);
      }

      final response = await ApiGetServices().apiGetServices(
          "${AppApiUrl.notifcations}?page=$page&limit=10",
          statusCode: 200,
          body: {});

      if (response != null) {
        NotificationModel newNotifications =
            NotificationModel.fromJson(response);

        if (newNotifications.data?.pagination != null) {
          totalPages.value = newNotifications.data!.pagination!.pages ?? 1;
          currentPage.value = page;
          hasMoreNotifications.value = currentPage.value < totalPages.value;
        }

        if (page == 1) {
          notificationModel.value = newNotifications;
        } else if (notificationModel.value != null &&
            notificationModel.value!.data != null &&
            newNotifications.data != null &&
            newNotifications.data!.notifications != null &&
            notificationModel.value!.data!.notifications != null) {
          notificationModel.value!.data!.notifications!
              .addAll(newNotifications.data!.notifications!);
          notificationModel.refresh();
        }

       //!  log("✅✅✅ Fetched notifications, page $page of ${totalPages.value}");
      } else {
        throw Exception("Failed to load notifications - null response");
      }
    } catch (ex) {
      //! log("❎❎❎❎❎❎ Error fetching notifications: ${ex.toString()} ❎❎❎❎❎❎");
      errorMessage(ex.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchParcelNotifications({int page = 1}) async {
    try {
      if (page == 1) {
        isParcelLoading(true);
        parcelError('');
      }

      final response = await ApiGetServices().apiGetServices(
          "${AppApiUrl.notifyParcel}?page=$page&limit=10",
          statusCode: 200,
          body: {});

      if (response != null) {
        NotifyParcelModel parcelModel = NotifyParcelModel.fromJson(response);

        if (parcelModel.data?.pagination != null) {
          parcelTotalPages.value = parcelModel.data!.pagination!.pages ?? 1;
          parcelCurrentPage.value = page;
          hasMoreParcelNotifications.value =
              parcelCurrentPage.value < parcelTotalPages.value;
        }

        if (parcelModel.data?.notifications != null &&
            parcelModel.data!.notifications!.isNotEmpty) {
          if (page == 1) {
            parcelNotifications.clear();
          }
          parcelNotifications.add(parcelModel);
          //! log("✅ Parcel notifications fetched: Page $page");
        } else {
          if (page == 1) parcelNotifications.clear();
          //! log("⚠️ No parcel notifications found");
        }
      } else {
        throw Exception("Failed to load parcel notifications - null response");
      }
    } catch (ex) {
      //! log("❌ Error fetching parcel notifications: ${ex.toString()}");
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

      //! log("✅✅✅ Delivery notification status changed to: ${receivingDeliveries.value}");
      return serverStatus;
    } catch (ex) {
      //! log("❎❎❎❎❎❎ Error updating delivery notification status: ${ex.toString()} ❎❎❎❎❎❎");
      errorMessage(ex.toString());
      return receivingDeliveries.value;
    } finally {
      isLoading(false);
    }
  }

  Future<void> isReadNotification() async {
    try {
      isLoading(true);
      final response = await ApiGetServices().apiGetServices(
        AppApiUrl.readNotificaiton,
        statusCode: 200,
      );

      //! log("API Response: $response");

      if (response["status"] == "success") {
        final notificationModel = ReadingNotificaitonModel.fromJson(response);
        //! log("Unread count from API: ${notificationModel.data?.unreadCount}");

        if (notificationModel.status == "success" &&
            notificationModel.data != null) {
          unreadCount.value = (notificationModel.data!.unreadCount!).toInt();
          //! log("Final unread count: ${unreadCount.value}");
        }
      }
    } catch (ex) {
      // ... rest of your code
    }
  }

  Future<void> isReadAllNotificaton() async {
    try {
      isLoading(true);
      final response = await ApiPatchServices()
          .apiPatchServices(url: AppApiUrl.isReadNotification, statusCode: 200);
      if (response["status"] == "success") {
        //! log("✅✅✅ All notifications marked as read successfully ✅✅✅");
        unreadCount.value = 0; // Reset unread count
        fetchNotifications(); // Refresh notifications
      } else {
        //! log("❎❎❎❎❎❎ Failed to mark all notifications as read ❎❎❎❎❎❎");
      }
    } catch (ex) {
      //! log("❎❎❎❎❎❎ Error marking all notifications as read: ${ex.toString()} ❎❎❎❎❎❎");
    }
  }
}
