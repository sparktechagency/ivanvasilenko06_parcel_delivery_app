import 'package:get_storage/get_storage.dart';
import 'package:parcel_delivery_app/constants/storage_key.dart';

class AppAuthStorage {
  ////////////// storage initial
  GetStorage box = GetStorage();

  Future<void> setToken(String value) async {
    await box.write(StorageKey.token, value);
  }

  String? getToken() {
    return box.read(StorageKey.token);
  }

  Future<void> setRefreshToken(String value) async {
    await box.write(StorageKey.refreshToken, value);
  }

  String? getRefreshToken() {
    return box.read(StorageKey.refreshToken);
  }

  ///logout
  Future<void> storageClear() async {
    await box.erase();
  }

  ///////////////// Chat ID
  Future<void> setChatID(String value) async {
    await box.write(StorageKey.chatID, value);
  }

  String? getChatID() {
    return box.read(StorageKey.chatID);
  }

  Future<void> removeChatID() async {
    await box.remove(StorageKey.chatID);
  }
}