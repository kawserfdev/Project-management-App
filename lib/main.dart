import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/core/utils/app_bloc_observer.dart';
import 'package:task_manager_app/firebase_options.dart';
import 'package:task_manager_app/task_manager_app.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set global BlocObserver to track all cubit/bloc actions and state transitions
  Bloc.observer = AppBlocObserver();

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

  FlutterNativeSplash.remove();

  runApp(TaskManagerApp(
    initialRoute: initialRoute,
  ));
}
