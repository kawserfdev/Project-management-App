import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:task_manager_app/core/services/user_directory_service.dart';
import 'package:task_manager_app/features/authentication/data/repos/auth_repo.dart';
import 'package:task_manager_app/features/authentication/presentation/manager/cubits/login_with_email_and_password/login_with_email_and_password_cubit.dart';
import 'package:task_manager_app/features/authentication/presentation/manager/cubits/registerwithemailandpassword/register_with_email_and_password_cubit.dart';
import 'package:task_manager_app/features/focus/data/datasources/focus_local_data_source.dart';
import 'package:task_manager_app/features/focus/data/repos/focus_repository.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/home/presentation/manager/logic/navigation/navigation_cubit.dart';
import 'package:task_manager_app/features/task/data/datasources/task_local_data_source.dart';
import 'package:task_manager_app/features/task/data/datasources/task_remote_data_source.dart';
import 'package:task_manager_app/features/task/data/repos/task_repository.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register User Directory Service
  getIt.registerLazySingleton<UserDirectoryService>(
      () => UserDirectoryServiceImpl());

  // Register Task Local & Remote Data Sources & Repository
  getIt.registerLazySingleton<TaskLocalDataSource>(
      () => TaskLocalDataSourceImpl());
  getIt.registerLazySingleton<TaskRemoteDataSource>(
      () => TaskRemoteDataSourceImpl());
  getIt.registerLazySingleton<TaskRepository>(
      () => TaskRepositoryImpl(
            localDataSource: getIt<TaskLocalDataSource>(),
            remoteDataSource: getIt<TaskRemoteDataSource>(),
          ));

  // Register Focus Data Source, Repository & Cubit
  getIt.registerLazySingleton<FocusLocalDataSource>(
      () => FocusLocalDataSourceImpl());
  getIt.registerLazySingleton<FocusRepository>(
      () => FocusRepositoryImpl(localDataSource: getIt<FocusLocalDataSource>()));
  getIt.registerLazySingleton<FocusCubit>(
      () => FocusCubit(focusRepository: getIt<FocusRepository>())..init());

  // Register FirebaseAuth
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  // Register GoogleSignIn
  getIt.registerLazySingleton<GoogleSignIn>(
    () => GoogleSignIn(
      clientId: kIsWeb
          ? '959053640502-j0scjr697o0i51sf0vujr3h539q95di4.apps.googleusercontent.com'
          : null,
    ),
  );

  // Register AuthRepo
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );

  // Register Cubits
  getIt.registerFactory<RegisterWithEmailAndPasswordCubit>(
      () => RegisterWithEmailAndPasswordCubit());
  getIt.registerFactory<LoginWithEmailAndPasswordCubit>(
      () => LoginWithEmailAndPasswordCubit());
  getIt.registerFactory<NavigationCubit>(() => NavigationCubit());
  getIt.registerLazySingleton<TaskCubit>(
      () => TaskCubit(taskRepository: getIt<TaskRepository>())..init());
}
