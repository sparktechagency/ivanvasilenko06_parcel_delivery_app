class AppApiUrl {
  static const String localDomain = "http://10.0.70.208:3000";

  static const String liveDomain = "http://72.167.54.115:3000";
  static const String baseUrl = "$localDomain/api";
  static const String login = "/auth/login-email";
  static const String signupemail = "/auth/register-email";
  static const String verifyEmail = "/auth/verify-otp-email";
  static const String loginemailveify = "/auth/verify-login-otp";
  static const String googleAuth = "$baseUrl/auth/google-auth";
  static const String sendPercel = "$baseUrl/parcel/create";
  static const String getProfile = "/user/single-profile";
  static const String servicePromote = "$baseUrl/parcel/available";
  static const String deliverParcel = "$baseUrl/parcel/filtered";
  static const String deliveryRequest = "$baseUrl/delivery/request-delivery";
  static const String getParcelInRadius = "$baseUrl/parcel/availableByRadius";
  static const String notifcations = "$baseUrl/notification/all-notification";

  // static const String getCurrentOrders = "$baseUrl/parcel/user-parcels";
  static const String getCurrentOrders = "$baseUrl/parcel/user-all-parcels";
  static const String updateProfile = "$baseUrl/user/profile";
  static const String acceptRequest = "$baseUrl/parcel/assign";
  static const String cancelDeliveryRequest =
      "$baseUrl/delivery/cancel-request";
  static const String deleteParcel = "$baseUrl/parcel/delete/";

  static const String cancelDelivery = "$baseUrl/delivery/DevCancelparcel";

  static const String cancelAssignDeliver = "$baseUrl/parcel/cancel-assignment";

  static const String receivingDeliveryNotification =
      "$baseUrl/notification/update-status";

  static const String notifyParcel = "$baseUrl/notification/parcelNotify";

  static const String givingReview = "$baseUrl/delivery/review";

  static const String finishedDelivery = "$baseUrl/delivery/update-status";
  static const String deleteProfile = "$baseUrl/auth/user";
  static const String registerWithPhone = "$baseUrl/auth/register";
  static const String loginWithPhone = "$baseUrl/auth/login";
  static const String readNotificaiton = "$baseUrl/notification/unread";
  static const String isReadNotification = "$baseUrl/notification/mark-read";

  //// Phone OTP Login and Signup
  static const String phoneOtpSignup = "$baseUrl/auth/register";
  static const String phoneOtpLogin = "$baseUrl/auth/login";
  static const String phoneOtpVerify = "$baseUrl/auth/verify-otp";
  static const String phoneOtpLoginVerify = "$baseUrl/auth/login-otp";
  static const String phoneOtpResend = "$baseUrl/auth/resend-otp";

  static const String token = "";
}
