class AppApiUrl {
  static const String localDomain = "http://10.0.70.208:3000";

  static const String liveDomain = "https://azizul3000.binarybards.online";
  static const String baseUrl = "$liveDomain/api";
  static const String login = "/auth/login-email";
  static const String signupemail = "/auth/register-email";
  static const String verifyEmail = "/auth/verify-otp-email";
  static const String loginemailveify = "/auth/verify-login-otp";
  static const String googleAuth = "/auth/google-auth";
  static const String sendPercel = "$baseUrl/parcel/create";
  static const String getProfile = "/user/profile";
  static const String servicePromote = "$baseUrl/parcel/available";
  static const String deliverParcel = "$baseUrl/parcel/filtered";
  static const String deliveryRequest = "$baseUrl/delivery/request-delivery";
  static const String getParcelInRadius = "$baseUrl/parcel/availableByRadius";
  static const String notifcations = "$baseUrl/notification";
  static const String getCurrentOrders = "$baseUrl/parcel/user-parcels";
  static const String updateProfile = "$baseUrl/user/profile";
  static const String acceptRequest = "$baseUrl/parcel/assign";
  static const String cancelDeliveryRequest =
      "$baseUrl/delivery/cancel-request";
  static const String deleteParcel = "$baseUrl/parcel/delete/";

  static const String cancelDelivery = "$baseUrl/delivery/DevCancelparcel";

  static const String cancelAssignDeliver = "$baseUrl/parcel/cancel-assignment";
  static const String token = "";
}
