import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/di/service_locator.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_local_data_source.dart';
import 'package:task_manager_app/features/focus/data/repos/focus_repository.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager_app/features/task/data/repos/task_repository.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key, required this.initialRoute});
  final String initialRoute;

  TaskCubit _resolveTaskCubit() {
    if (getIt.isRegistered<TaskCubit>()) {
      return getIt<TaskCubit>();
    }
    final localDataSource = TaskLocalDataSourceImpl();
    final remoteDataSource = TaskRemoteDataSourceImpl();
    final repository = TaskRepositoryImpl(
      localDataSource: localDataSource,
      remoteDataSource: remoteDataSource,
    );
    final cubit = TaskCubit(taskRepository: repository)..init();
    getIt.registerSingleton<TaskCubit>(cubit);
    SessionManager.getUserSession().then((session) {
      if (session['id'] != null) {
        cubit.init(userId: session['id']);
      }
    }).catchError((_) {});
    return cubit;
  }

  FocusCubit _resolveFocusCubit() {
    if (getIt.isRegistered<FocusCubit>()) {
      return getIt<FocusCubit>();
    }
    final localDataSource = FocusLocalDataSourceImpl();
    final repository = FocusRepositoryImpl(localDataSource: localDataSource);
    final cubit = FocusCubit(focusRepository: repository)..init();
    getIt.registerSingleton<FocusCubit>(cubit);
    SessionManager.getUserSession().then((session) {
      if (session['id'] != null) {
        cubit.init(userId: session['id']);
      }
    }).catchError((_) {});
    return cubit;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>.value(value: _resolveTaskCubit()),
        BlocProvider<FocusCubit>.value(value: _resolveFocusCubit()),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final Size designSize;
          if (width >= 1024) {
            designSize = const Size(1440, 900);
          } else if (width >= 650) {
            designSize = const Size(768, 1024);
          } else {
            designSize = const Size(375, 812);
          }

          return ScreenUtilInit(
            designSize: designSize,
            minTextAdapt: true,
            splitScreenMode: true,
            fontSizeResolver: (fontSize, instance) {
              if (instance.screenWidth >= 1024) {
                final scale = (instance.screenWidth / 1440).clamp(0.85, 1.25);
                return fontSize * scale;
              } else if (instance.screenWidth >= 650) {
                final scale = (instance.screenWidth / 768).clamp(0.9, 1.15);
                return fontSize * scale;
              }
              return FontSizeResolvers.width(fontSize, instance);
            },
            builder: (context, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                scrollBehavior: const AppScrollBehavior(),
                title: 'UpTodo - Task Manager',
                theme: ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: AppColors.darkBlue,
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primaryColor,
                    surface: AppColors.darkBlue,
                  ),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: AppColors.darkBlue,
                    elevation: 0,
                  ),
                ),
                initialRoute: initialRoute,
                onGenerateRoute: Routes.generateRoute,
              );
            },
          );
        },
      ),
    );
  }
}
