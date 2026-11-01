import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:task_manager_app/core/errors/exceptions.dart';
import 'package:task_manager_app/core/errors/firebase_auth_exceptions.dart';
import 'package:task_manager_app/core/errors/firebase_exceptions.dart';
import 'package:task_manager_app/core/errors/platform_exceptions.dart';
import 'package:task_manager_app/core/utils/logger.dart';
import 'package:task_manager_app/features/authentication/data/repos/auth_repo.dart';
import 'package:task_manager_app/features/authentication/presentation/manager/cubits/google_sign_in/google_sign_in_state.dart';

class GoogleSignInCubit extends Cubit<GoogleSignInState> {
  final AuthRepo _authRepo = GetIt.instance<AuthRepo>();

  GoogleSignInCubit() : super(GoogleSignInInitial());

  Future<void> signInWithGoogle() async {
    emit(GoogleSignInLoading());
    try {
      final user = await _authRepo.signInWithGoogle();
      if (user != null) {
        emit(GoogleSignInSuccess(user));
      } else {
        emit(GoogleSignInInitial());
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' || e.code == 'cancelled') {
        emit(GoogleSignInInitial());
        return;
      }
      AppLogger.error("FirebaseAuthException", e);
      emit(GoogleSignInFailure(e.message ?? e.code));
    } on AppFirebaseAuthException catch (e) {
      AppLogger.error("Firebase Auth Exception", e);
      emit(GoogleSignInFailure(AppFirebaseAuthException(e.message).message));
    } on AppPlatformException catch (e) {
      AppLogger.error("Platform Exception", e);
      emit(GoogleSignInFailure(AppPlatformException(e.message).message));
    } on AppFirebaseException catch (e) {
      AppLogger.error("Firebase Exception", e);
      emit(GoogleSignInFailure(AppFirebaseException(e.message).message));
    } on AppExceptions catch (e) {
      AppLogger.error("General Exception", e);
      emit(GoogleSignInFailure(AppExceptions(e.message).message));
    } catch (e, stackTrace) {
      final errStr = e.toString();
      if (errStr.contains('popup_closed') || errStr.contains('cancelled')) {
        emit(GoogleSignInInitial());
        return;
      }
      AppLogger.error("An error occurred", e);
      AppLogger.error(stackTrace.toString());
      emit(GoogleSignInFailure(errStr));
    }
  }
}
