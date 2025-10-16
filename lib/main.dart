import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:luz_smart_ilumina/controller/luz_controller.dart';
import 'package:luz_smart_ilumina/firebase_options.dart';
import 'package:luz_smart_ilumina/ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  Get.put(LuzController());
  runApp(const MyApp());
}
