import 'dart:developer';

import 'package:flutter/foundation.dart';

void errorLog(String message, dynamic e, {String title = "Error form"}) {
  try {
    if (kDebugMode) {
      log("👿😈 $title > $message >>> 🧐🧐 ${e.toString()} ✋🏻✋🏻✋🏻✋🏻");
    }
  } catch (e) {
    ///////
  }
}
