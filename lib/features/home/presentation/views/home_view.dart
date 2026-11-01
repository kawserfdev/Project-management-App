import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/core/utils/responsive.dart';
import 'package:task_manager_app/features/calender/presentation/views/calender_view.dart';
import 'package:task_manager_app/features/focus/presentation/manager/focus_cubit.dart';
import 'package:task_manager_app/features/focus/presentation/views/focus_view.dart';
import 'package:task_manager_app/features/home/presentation/manager/logic/navigation/navigation_cubit.dart';
import 'package:task_manager_app/features/home/presentation/widgets/add_note_bottom_sheet.dart';
import 'package:task_manager_app/features/index/presentation/views/index_view.dart';
import 'package:task_manager_app/features/profile/presentation/views/profile_view.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_state.dart';
import 'package:task_manager_app/features/workspace/presentation/widgets/hierarchy_selector_sheet.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key, this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: _HomeViewContent(user: user),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent({this.user});
  final dynamic user;

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserData();
    });
  }

  Future<void> _syncUserData() async {
    String? uid;
    if (widget.user != null) {
      try {
        uid = widget.user.uid;
      } catch (_) {
        try {
          uid = widget.user['id'];
        } catch (_) {}
      }
    }
    if (uid == null || uid.isEmpty) {
      final session = await SessionManager.getUserSession();
      uid = session['id'];
    }

    if (mounted && uid != null && uid.isNotEmpty) {
      context.read<TaskCubit>().init(userId: uid);
      context.read<FocusCubit>().init(userId: uid);
    }
  }

  void _openAddTask(BuildContext context) {
    final isDesktopOrTablet = !Responsive.isMobile(context);
    if (isDesktopOrTablet) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: const Material(
                color: AppColors.textFieldBackgroundColor,
                child: SingleChildScrollView(child: AddTaskBottomSheet()),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) => const AddTaskBottomSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    return BlocBuilder<NavigationCubit, int>(
      builder: (context, activeIndex) {
        final contentStack = IndexedStack(
          index: activeIndex,
          children: [
            const IndexView(),
            CalenderView(user: widget.user),
            FocusView(user: widget.user),
            ProfileView(user: widget.user),
          ],
        );

        // --- 1. DESKTOP LAYOUT (Side Drawer + Content Area) ---
        if (isDesktop) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                _buildDesktopSidebar(context, activeIndex),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.textFieldBackgroundColor),
                Expanded(child: contentStack),
              ],
            ),
          );
        }

        // --- 2. TABLET LAYOUT (NavigationRail + Content Area) ---
        if (isTablet) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Row(
              children: [
                _buildTabletNavigationRail(context, activeIndex),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.textFieldBackgroundColor),
                Expanded(child: contentStack),
              ],
            ),
          );
        }

        // --- 3. MOBILE LAYOUT (Classic BottomNavigationBar + FAB) ---
        return Scaffold(
          resizeToAvoidBottomInset: false,
          floatingActionButton: FloatingActionButton(
            elevation: 4,
            tooltip: 'Add Task',
            backgroundColor: AppColors.primaryColor,
            shape: const CircleBorder(),
            onPressed: () => _openAddTask(context),
            child: const Icon(Iconsax.add, color: Colors.white, size: 28),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          body: contentStack,
          bottomNavigationBar: BottomNavigationBar(
            elevation: 8,
            backgroundColor: AppColors.navBar,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.lightGrey,
            type: BottomNavigationBarType.fixed,
            onTap: (index) {
              context.read<NavigationCubit>().navigateTo(index);
            },
            currentIndex: activeIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Iconsax.home),
                label: 'Index',
                activeIcon: Icon(Iconsax.home_15),
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.calendar_1),
                label: 'Calendar',
                activeIcon: Icon(Iconsax.calendar_2),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                activeIcon: Icon(Icons.timer_rounded),
                label: 'Focus',
              ),
              BottomNavigationBarItem(
                icon: Icon(Iconsax.user),
                activeIcon: Icon(Iconsax.profile_2user5),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabletNavigationRail(BuildContext context, int activeIndex) {
    return NavigationRail(
      backgroundColor: AppColors.textFieldBackgroundColor,
      selectedIndex: activeIndex,
      onDestinationSelected: (idx) {
        context.read<NavigationCubit>().navigateTo(idx);
      },
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: AppColors.primaryColor),
      unselectedIconTheme: const IconThemeData(color: AppColors.lightGrey),
      selectedLabelTextStyle: TextStyle(color: AppColors.primaryColor, fontSize: 11.sp, fontWeight: FontWeight.bold),
      unselectedLabelTextStyle: TextStyle(color: AppColors.lightGrey, fontSize: 11.sp),
      leading: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: FloatingActionButton.small(
          elevation: 2,
          tooltip: 'Add Task',
          backgroundColor: AppColors.primaryColor,
          onPressed: () => _openAddTask(context),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Iconsax.home),
          selectedIcon: Icon(Iconsax.home_15),
          label: Text('Index'),
        ),
        NavigationRailDestination(
          icon: Icon(Iconsax.calendar_1),
          selectedIcon: Icon(Iconsax.calendar_2),
          label: Text('Calendar'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer_rounded),
          label: Text('Focus'),
        ),
        NavigationRailDestination(
          icon: Icon(Iconsax.user),
          selectedIcon: Icon(Iconsax.profile_2user5),
          label: Text('Profile'),
        ),
      ],
    );
  }

  Widget _buildDesktopSidebar(BuildContext context, int activeIndex) {
    final navCubit = context.read<NavigationCubit>();

    return Container(
      width: 260,
      color: AppColors.textFieldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Iconsax.task_square, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task Manager',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Team Workspace',
                    style: TextStyle(color: AppColors.lightGrey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Workspace Hierarchy Quick Selector
          BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              return InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => Dialog(
                      backgroundColor: Colors.transparent,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: const Material(
                            color: AppColors.textFieldBackgroundColor,
                            child: HierarchySelectorSheet(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(state.selectedWorkspace.icon, size: 16, color: AppColors.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.selectedWorkspace.name,
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.selectedSpace?.name ?? 'All Spaces',
                              style: const TextStyle(color: AppColors.lightGrey, fontSize: 10),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.unfold_more, size: 16, color: AppColors.lightGrey),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Quick "+ Create Task" Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, color: Colors.white, size: 18),
              label: const Text('Create Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () => _openAddTask(context),
            ),
          ),
          const SizedBox(height: 20),

          // Navigation Links
          _desktopNavTile(
            icon: Iconsax.home,
            activeIcon: Iconsax.home_15,
            label: 'Index & Tasks',
            isSelected: activeIndex == 0,
            onTap: () => navCubit.navigateTo(0),
          ),
          _desktopNavTile(
            icon: Iconsax.calendar_1,
            activeIcon: Iconsax.calendar_2,
            label: 'Calendar',
            isSelected: activeIndex == 1,
            onTap: () => navCubit.navigateTo(1),
          ),
          _desktopNavTile(
            icon: Icons.timer_outlined,
            activeIcon: Icons.timer_rounded,
            label: 'Focus Timer',
            isSelected: activeIndex == 2,
            onTap: () => navCubit.navigateTo(2),
          ),
          _desktopNavTile(
            icon: Iconsax.user,
            activeIcon: Iconsax.profile_2user5,
            label: 'Profile & Settings',
            isSelected: activeIndex == 3,
            onTap: () => navCubit.navigateTo(3),
          ),

          const Spacer(),

          // Live Team Status Card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.darkBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Real-Time Sync Active',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // User info footer
          FutureBuilder<Map<String, String?>>(
            future: SessionManager.getUserSession(),
            builder: (context, snapshot) {
              final cached = snapshot.data;
              final name = cached?['displayName'] ?? 'Task Manager User';
              return Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryColor,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _desktopNavTile({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: AppColors.primaryColor.withValues(alpha: 0.3)) : null,
      ),
      child: Material(
        color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: ListTile(
          dense: true,
          leading: Icon(isSelected ? activeIcon : icon, color: isSelected ? AppColors.primaryColor : AppColors.lightGrey, size: 20),
          title: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.lightGrey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
