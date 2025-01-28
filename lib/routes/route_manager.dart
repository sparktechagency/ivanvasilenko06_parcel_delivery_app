import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/home_screen/home_screen.dart';

import '../screens/auth_screens/email_login_screen/email_login_screen.dart';
import '../screens/auth_screens/login_screen/login_screen.dart';
import '../screens/auth_screens/signup_screen/signup_screen.dart';
import '../screens/auth_screens/verify_email_screen/verify_email_screen.dart';
import '../screens/auth_screens/verify_phone_screen/verify_phone_screen.dart';
import '../screens/booking_parcel_details_screen/booking_parcel_details_screen.dart';
import '../screens/booking_screen/booking_screen.dart';
import '../screens/booking_view_details_screen/booking_view_details_screen.dart';
import '../screens/contact_us_screen/contact_us_screen.dart';
import '../screens/delivery_parcel_screens/delivery_type_screen/delivery_type_screen.dart';
import '../screens/history_screen/history_screen.dart';
import '../screens/notification_screen/notification_screen.dart';
import '../screens/onboarding_screen/onboarding_screen.dart';
import '../screens/parcel_for_delivery_screen/parcel_for_delivery_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/radius_map_screen/radius_map_screen.dart';
import '../screens/services_screen/services_screen.dart';
import '../screens/splash_screen/splash_screen.dart';
import 'app_routes.dart';

class RouteManager {
  RouteManager._();

  static const initial = AppRoutes.splashScreen;

  static List<GetPage> getPages() {
    return [
      GetPage(
        name: AppRoutes.splashScreen,
        page: () => const SplashScreen(),
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.onboardingScreen,
        page: () => OnboardingScreen(),
        //transition: Transition.cupertino,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.signupScreen,
        page: () => SignupScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.verifyPhoneScreen,
        page: () => VerifyPhoneScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.loginScreen,
        page: () => LoginScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.emailLoginScreen,
        page: () => EmailLoginScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.verifyEmailScreen,
        page: () => VerifyEmailScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.homeScreen,
        page: () => HomeScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.servicesScreen,
        page: () => ServicesScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.bookingScreen,
        page: () => const BookingScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.profileScreen,
        page: () => const ProfileScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.bookingParcelDetailsScreen,
        page: () => const BookingParcelDetailsScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.bookingViewDetailsScreen,
        page: () => const BookingViewDetailsScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.deliveryTypeScreen,
        page: () => DeliveryTypeScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.notificationScreen,
        page: () => NotificationScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.radiusMapScreen,
        page: () => RadiusMapScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.parcelForDeliveryScreen,
        page: () => ParcelForDeliveryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.contactUsScreen,
        page: () => ContactUsScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.historyScreen,
        page: () => HistoryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
    ];
  }
}
