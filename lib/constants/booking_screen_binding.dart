import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/booking_screen/current_order/controller/current_order_controller.dart';
import 'package:parcel_delivery_app/screens/booking_screen/new_booking/controller/new_bookings_controller.dart';

class BookingScreenBinding extends Bindings {
  @override
  void dependencies() {
    // Use lazyPut to ensure the controller persists across screen navigation
    Get.lazyPut<CurrentOrderController>(() => CurrentOrderController(), fenix: true);
    Get.lazyPut<NewBookingsController>(() => NewBookingsController(), fenix: true);
  }
}