import 'package:get/get.dart';

import '../screens/auth_screens/login_screen/login_screen.dart';
import '../screens/auth_screens/signup_screen/signup_screen.dart';
import '../screens/auth_screens/verify_phone_screen/verify_phone_screen.dart';
import '../screens/onboarding_screen/onboarding_screen.dart';
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
    ];
  }
}
