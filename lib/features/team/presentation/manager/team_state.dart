import 'package:equatable/equatable.dart';
import 'package:task_manager_app/features/team/data/models/team_member_model.dart';
import 'package:task_manager_app/features/team/data/models/team_model.dart';

abstract class TeamState extends Equatable {
  const TeamState();
  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {
  const TeamInitial();
}

class TeamLoading extends TeamState {
  const TeamLoading();
}

class TeamsLoaded extends TeamState {
  final List<TeamModel> teams;
  const TeamsLoaded(this.teams);
  @override
  List<Object?> get props => [teams];
}

class TeamDetailLoaded extends TeamState {
  final TeamModel team;
  final List<TeamMemberModel> members;
  const TeamDetailLoaded({required this.team, required this.members});
  @override
  List<Object?> get props => [team, members];
}

class TeamActionSuccess extends TeamState {
  final String message;
  final TeamModel? team;
  const TeamActionSuccess({required this.message, this.team});
  @override
  List<Object?> get props => [message, team];
}

class TeamError extends TeamState {
  final String message;
  const TeamError(this.message);
  @override
  List<Object?> get props => [message];
}

