import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/features/authentication/presentation/views/login_view.dart';
import 'package:task_manager_app/features/authentication/presentation/views/register_view.dart';
import 'package:task_manager_app/features/home/presentation/views/home_view.dart';
import 'package:task_manager_app/features/home/presentation/widgets/add_note_bottom_sheet.dart';
import 'package:task_manager_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:task_manager_app/features/profile/presentation/views/settings_view.dart';
import 'package:task_manager_app/features/task/data/models/task_model.dart';
import 'package:task_manager_app/features/task/presentation/views/add_task_category_view.dart';
import 'package:task_manager_app/features/task/presentation/views/edit_task_view.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';
import 'package:task_manager_app/features/team/presentation/views/team_detail_view.dart';
import 'package:task_manager_app/features/team/presentation/views/teams_hub_view.dart';

class Routes {
  static const String onboarding = '/onboarding_view';
  static const String registerView = '/register_view';
  static const String homeView = '/home_view';
  static const String loginView = '/login_view';
  static const String signUpView = '/sign_up_view';
  static const String settingsView = '/settings_view';
  static const String addTaskView = '/add_task_view';
  static const String editTaskView = '/edit_task_view';
  static const String addTaskCategoryView = '/add_task_category_view';
  static const String teamsHub = '/teams_hub';
  static const String teamDetail = '/team_detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final rawName = settings.name ?? '';
    final uri = Uri.tryParse(rawName);
    final routePath = (uri?.path.isNotEmpty == true) ? uri!.path : rawName;
    final normalized = routePath.startsWith('/') ? routePath : '/$routePath';

    switch (normalized) {
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());

      case registerView:
      case signUpView:
        return MaterialPageRoute(builder: (_) => const RegisterView());

      case loginView:
        return MaterialPageRoute(builder: (_) => const LoginView());

      case settingsView:
        return MaterialPageRoute(builder: (_) => const SettingsView());

      case addTaskCategoryView:
        return MaterialPageRoute(builder: (_) => const AddTaskCategoryView());

      case teamsHub:
        return MaterialPageRoute(builder: (_) => const TeamsHubView());

      case teamDetail:
        if (args is Map) {
          final team = args['team'] as TeamModel;
          final role = args['role'] as TeamRole? ?? TeamRole.member;
          return MaterialPageRoute(
            builder: (_) => TeamDetailView(team: team, myRole: role),
          );
        } else if (args is TeamModel) {
          return MaterialPageRoute(
            builder: (_) => TeamDetailView(team: args, myRole: TeamRole.member),
          );
        }
        return MaterialPageRoute(builder: (_) => const TeamsHubView());

      case editTaskView:
        if (args is TaskModel) {
          return MaterialPageRoute(builder: (_) => EditTaskView(task: args));
        }
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Invalid task data for EditTaskView')),
          ),
        );

      case addTaskView:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: SafeArea(child: AddTaskBottomSheet()),
          ),
        );

      case homeView:
      case '/home':
      case 'home':
      case '/':
        if (args is User) {
          return MaterialPageRoute(
            builder: (_) => HomeView(user: args),
          );
        }
        return MaterialPageRoute(
          builder: (_) => const HomeView(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('${settings.name} not found')),
            appBar: AppBar(title: const Text('Error')),
          ),
        );
    }
  }
}
