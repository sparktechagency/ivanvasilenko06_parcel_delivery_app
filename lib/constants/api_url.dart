class AppApiUrl{
  static const String localDomain ="http://10.0.70.208:3000";

  static const String liveDomain ="https://azizul3000.binarybards.online";
  static const String baseUrl = "$liveDomain/api";
  static const String login = "/auth/login-email";
  static const String signupemail = "/auth/register-email";
  static const String verifyEmail = "/auth/verify-otp-email";
  static const String loginemailveify = "/auth/verify-login-otp";
  static const String sendPercel = "$baseUrl/parcel/create";
  static const String getProfile = "/user/profile";
  static const String sevicePromote =  "$baseUrl/parcel/available";
  static const String token = "";
}