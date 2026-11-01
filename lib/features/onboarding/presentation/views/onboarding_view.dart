import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_constants.dart';
import 'package:task_manager_app/core/constants/app_strings.dart';
import 'package:task_manager_app/core/routes/routes.dart';
import 'package:task_manager_app/core/services/session_manager.dart';
import 'package:task_manager_app/core/widgets/app_button_widget.dart';
import 'package:task_manager_app/core/widgets/text_button_widget.dart';
import 'package:task_manager_app/features/onboarding/presentation/widgets/on_boarding_dot_navigation.dart';
import 'package:task_manager_app/features/onboarding/presentation/widgets/onboarding_page_view.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late PageController controller;
  late ValueNotifier<int> pageIndexNotifier;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    pageIndexNotifier =
        ValueNotifier<int>(0); // Initialize with initial page index
    controller.addListener(() {
      pageIndexNotifier.value = controller.page!.round();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    pageIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0.h, horizontal: 16.0.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButtonWidget(
                        text: AppStrings.back,
                        onPressed: () {
                          controller.previousPage(
                            duration: duration,
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      TextButtonWidget(
                        text: AppStrings.skip,
                        onPressed: () async {
                          await SessionManager.saveGuestSession();
                          if (context.mounted) {
                            Navigator.pushReplacementNamed(
                              context,
                              Routes.homeView,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: OnboardingPageView(
                      pageController: controller,
                    ),
                  ),
                  OnboardingDotIndicator(
                    pageController: controller,
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: pageIndexNotifier,
                    builder: (context, value, child) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24.0.h),
                        child: AppButtonWidget(
                          text: pageIndexNotifier.value == 2
                              ? AppStrings.getStarted
                              : AppStrings.next,
                          width: pageIndexNotifier.value == 2
                              ? 151.0.w
                              : double.infinity,
                          onTap: () async {
                            if (pageIndexNotifier.value != 2) {
                              controller.nextPage(
                                duration: duration,
                                curve: Curves.easeInOut,
                              );
                            } else {
                              await SessionManager.setOnboardingCompleted(true);
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  Routes.registerView,
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
