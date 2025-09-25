import 'package:get_storage/get_storage.dart';
import 'package:parcel_delivery_app/constants/storage_key.dart';
import 'package:parcel_delivery_app/utils/appLog/error_app_log.dart';

class AppAuthStorage {
  ////////////// storage initial
  GetStorage box = GetStorage();

  Future<void> setToken(String value) async {
    try {
      await box.write(StorageKey.token, value);
    } catch (e) {
      errorLog("set token ", e);
    }
  }

  String? getToken() {
    try {
      return box.read(StorageKey.token) ?? "";
    } catch (e) {
      errorLog("get token", e);
      return "";
    }
  }

  Future<void> setRefreshToken(String value) async {
    try {
      await box.write(StorageKey.refreshToken, value);
    } catch (e) {
      errorLog("set refresh token", e);
    }
  }

  String? getRefreshToken() {
    try {
      return box.read(StorageKey.refreshToken);
    } catch (e) {
      errorLog("get refresh token", e);
      return "";
    }
  }

  ///logout
  Future<void> storageClear() async {
    try {
      await box.erase();
    } catch (e) {
      errorLog("logout", e);
    }
  }
}