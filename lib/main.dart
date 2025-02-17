import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants/dep.dart' as dep;
import 'main_app_entry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  Map<String, Map<String, String>> _languages = await dep.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MainApp(
    languages: _languages,
  ));
}
