import 'package:get/get.dart';
import 'package:parcel_delivery_app/screens/before_signups/country_select_page.dart';
import 'package:parcel_delivery_app/screens/before_signups/language_select_page.dart';
import 'package:parcel_delivery_app/screens/booking_screen/parcel_details_screen/parcel_details_screen.dart';
import 'package:parcel_delivery_app/screens/booking_screen/parcel_details_screen/view_details_screen.dart';
import 'package:parcel_delivery_app/screens/delivery_man_details/delivery_man_details.dart';
import 'package:parcel_delivery_app/screens/home_screen/home_screen.dart';
import 'package:parcel_delivery_app/screens/profile_screen/edit_profile.dart';
import 'package:parcel_delivery_app/screens/radius_map_screen/radius_available_parcel/radius_avaiable_parcel.dart';
import 'package:parcel_delivery_app/screens/radius_map_screen/radius_map_screen_details/radius_map_screen_details.dart';
import 'package:parcel_delivery_app/screens/recent_publish_orders/recent_publish_order.dart';
import 'package:parcel_delivery_app/screens/termsNconditon/terms_and_condition.dart';

import '../screens/auth_screens/email_login_screen/email_login_screen.dart';
import '../screens/auth_screens/login_screen/login_screen.dart';
import '../screens/auth_screens/signup_screen/signup_screen.dart';
import '../screens/auth_screens/verify_email_screen/verify_email_screen.dart';
import '../screens/auth_screens/verify_phone_screen/verify_phone_screen.dart';
import '../screens/booking_parcel_details_screen/booking_parcel_details_screen.dart';
import '../screens/booking_screen/booking_screen.dart';
import '../screens/booking_view_details_screen/booking_view_details_screen.dart';
import '../screens/cancel_delivery_screen/cancel_delivery_screen.dart';
import '../screens/contact_us_screen/contact_us_screen.dart';
import '../screens/delivery_parcel_screens/choose_parcel_for_delivery_screen/choose_parcel_for_delivery_screen.dart';
import '../screens/delivery_parcel_screens/delivery_type_screen/delivery_type_screen.dart';
import '../screens/delivery_parcel_screens/parcel_for_delivery_screen/parcel_for_delivery_screen_radius.dart';
import '../screens/delivery_parcel_screens/select_delivery_location_screen/select_delevery_location_screen.dart';
import '../screens/delivery_parcel_screens/send_request_successfully/send_request_successfully.dart';
import '../screens/delivery_parcel_screens/summary_of_parcel_screen/summary_of_parcel_screen.dart';
import '../screens/history_screen/history_screen.dart';
import '../screens/notification_screen/notification_screen.dart';
import '../screens/onboarding_screen/onboarding_screen.dart';
import '../screens/profile_screen/profile_screen.dart';
import '../screens/radius_map_screen/radius_map_screen.dart';
import '../screens/recent_publish_order_details/recent_publish_order_details.dart';
import '../screens/send_parcel_screens/hurrah_screen/hurrah_screen.dart';
import '../screens/send_parcel_screens/sender_delivery_type_screen/sender_delivery_type_screen.dart';
import '../screens/send_parcel_screens/sender_summary_of_parcel_screen/sender_summary_of_parcel_screen.dart';
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

      /// Got the Country Select Page
      GetPage(
        name: AppRoutes.countrySelectScreen,
        page: () => const CountrySelectPage(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      // Select the Language
      GetPage(
        name: AppRoutes.languageSelectScreen,
        page: () => const LanguageSelectPage(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.signupScreen,
        page: () => const SignupScreen(),
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
        page: () => const HomeScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.servicesScreen,
        page: () => const ServicesScreen(),
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
        page: () => const NotificationScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.radiusMapScreen,
        page: () => const RadiusMapScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.parcelForDeliveryScreen,
        page: () => const ParcelForDeliveryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.sentRequestSuccessfully,
        page: () => const SendRequestSuccessfully(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.contactUsScreen,
        page: () =>  const ContactUsScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.historyScreen,
        page: () => const HistoryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.selectDeliveryLocationScreen,
        page: () => const SelectDeliveryLocationScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.chooseParcelForDeliveryScreen,
        page: () => const ChooseParcelForDeliveryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.summaryOfParcelScreen,
        page: () => const SummaryOfParcelScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.senderDeliveryTypeScreen,
        page: () => const SenderDeliveryTypeScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.senderSummaryOfParcelScreen,
        page: () => const SenderSummaryOfParcelScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.hurrahScreen,
        page: () => const HurrahScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
        name: AppRoutes.cancelDeliveryScreen,
        page: () => const CancelDeliveryScreen(),
        transition: Transition.rightToLeft,
        // binding: GeneralBindings(),
      ),
      GetPage(
          name: AppRoutes.recentpublishorder,
          page: () => const RecentPublishOrder(),
          transition: Transition.rightToLeft),
      GetPage(
          name: AppRoutes.radiusAvailableParcel,
          page: () => const RadiusAvailableParcel(),
          transition: Transition.rightToLeft),
      GetPage(
        name: AppRoutes.editProfile,
        page: () => const EditProfile(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.deliveryManDetails,
        page: () => const DeliveryManDetails(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.parcelDetailsScreen,
        page: () => const ParcelDetailsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.radiusMapScreenDetails,
        page: () => const RadiusMapScreenDetails(),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.serviceScreenDeliveryDetails,
        page: () => DeliveryDetailsScreen(parcelId: Get.arguments),
        transition: Transition.rightToLeft,
      ),
      GetPage(
        name: AppRoutes.viewDetailsScreen,
        page: () => const ViewDetailsScreen(),
        transition: Transition.rightToLeft,
      ),
      GetPage(name: AppRoutes.termsNConditions, page: () => const TermsAndCondition(),transition: Transition.rightToLeft,),
    ];
  }
}
