import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A global [BlocObserver] that logs all BLoC/Cubit events, state transitions,
/// changes, and errors to the console using [debugPrint].
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('🚀 [BLOC CREATE] ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('⚡ [BLOC EVENT] ${bloc.runtimeType} -> $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint(
      '🔄 [BLOC CHANGE] ${bloc.runtimeType}\n'
      '   From: ${change.currentState.runtimeType}\n'
      '   To:   ${change.nextState.runtimeType}',
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint(
      '🔀 [BLOC TRANSITION] ${bloc.runtimeType}\n'
      '   Event: ${transition.event}\n'
      '   From:  ${transition.currentState.runtimeType}\n'
      '   To:    ${transition.nextState.runtimeType}',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('❌ [BLOC ERROR] ${bloc.runtimeType}: $error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    debugPrint('🛑 [BLOC CLOSE] ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}

