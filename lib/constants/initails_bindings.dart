import 'package:get/get.dart';

import '../screens/auth_screens/login_screen/controller/login_controller.dart';
import '../screens/auth_screens/signup_screen/controller/signup_controller.dart';
import '../screens/auth_screens/verify_phone_screen/controller/verify_phone_controller.dart';
import '../screens/booking_screen/current_order/controller/current_order_controller.dart';
import '../screens/booking_screen/new_booking/controller/new_bookings_controller.dart';
import '../screens/delivery_parcel_screens/controller/delivery_screens_controller.dart';
import '../screens/home_screen/controller/earn_money_radius_controller.dart';
import '../screens/notification_screen/controller/notification_controller.dart';
import '../screens/profile_screen/controller/profile_controller.dart';
import '../screens/services_screen/controller/services_controller.dart';
import '../screens/splash_screen/controller/splash_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    //! Splash Controller
    Get.lazyPut<SplashController>(() => SplashController());

    //! Login Screen Controller
    Get.lazyPut<LoginScreenController>(() => LoginScreenController());

    //! Sign Up Screen Controller
    Get.lazyPut<SignUpScreenController>(() => SignUpScreenController());

    //! Verify Phone Controller
    Get.lazyPut<VerifyPhoneController>(() => VerifyPhoneController());

    //! Earn Mone with Radius Controller
    Get.lazyPut<EarnMoneyRadiusController>(() => EarnMoneyRadiusController());

    //! Profile Screen Controller
    Get.lazyPut<ProfileController>(() => ProfileController());

    //! Notification Controller
    Get.lazyPut<NotificationController>(() => NotificationController());

    //! Service Controller
    Get.lazyPut<ServiceController>(() => ServiceController());

    //! Delivery Screen Controller
    Get.lazyPut<DeliveryScreenController>(() => DeliveryScreenController());

    //! New Bookings Controller 
    Get.lazyPut<NewBookingsController>(() => NewBookingsController());

    //! Current Orders Controller
    Get.lazyPut<CurrentOrderController>(() => CurrentOrderController());
  }
}
