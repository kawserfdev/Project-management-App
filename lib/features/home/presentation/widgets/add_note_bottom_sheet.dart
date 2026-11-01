import 'package:flutter/material.dart';
import 'package:task_manager_app/features/home/presentation/widgets/add_task_form.dart';

class AddTaskBottomSheet extends StatelessWidget {
  const AddTaskBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: const SingleChildScrollView(
        child: AddTaskForm(),
      ),
    );
  }
}
