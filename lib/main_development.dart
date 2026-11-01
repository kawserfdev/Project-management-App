import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/firebase_options.dart';
import 'package:task_manager_app/task_manager_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }
  await ScreenUtil.ensureScreenSize();
  final initialRoute = await SessionManager.determineInitialRoute();

  runApp(TaskManagerApp(
    initialRoute: initialRoute,
  ));
}
