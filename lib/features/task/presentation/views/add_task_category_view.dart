import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_manager_app/core/constants/app_colors.dart';
import 'package:task_manager_app/core/themes/app_text_themes.dart';
import 'package:task_manager_app/features/task/data/models/category_model.dart';
import 'package:task_manager_app/features/task/presentation/manager/task_cubit.dart';

class AddTaskCategoryView extends StatefulWidget {
  const AddTaskCategoryView({super.key});

  @override
  State<AddTaskCategoryView> createState() => _AddTaskCategoryViewState();
}

class _AddTaskCategoryViewState extends State<AddTaskCategoryView> {
  final _nameController = TextEditingController();
  int _selectedColorValue = 0xFFCCFF80;
  int _selectedIconCode = Icons.category_outlined.codePoint;

  final List<int> _colors = const [
    0xFFCCFF80,
    0xFFFF9680,
    0xFF80FFFF,
    0xFF80FFD9,
    0xFF809CFF,
    0xFFFF80EB,
    0xFFFC80FF,
    0xFF80FFA3,
    0xFF80D1FF,
    0xFFFF9980,
    0xFFFFE57F,
    0xFFB388FF,
  ];

  final List<IconData> _icons = const [
    Icons.shopping_basket_outlined,
    Icons.work_outline,
    Icons.fitness_center_outlined,
    Icons.brush_outlined,
    Icons.school_outlined,
    Icons.campaign_outlined,
    Icons.music_note_outlined,
    Icons.favorite_border,
    Icons.movie_outlined,
    Icons.home_outlined,
    Icons.book_outlined,
    Icons.flight_takeoff,
    Icons.laptop,
    Icons.code,
    Icons.coffee,
    Icons.pets,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter category name')),
      );
      return;
    }

    final newCategory = CategoryModel(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      colorValue: _selectedColorValue,
      iconCode: _selectedIconCode,
    );

    context.read<TaskCubit>().addCategory(newCategory);
    Navigator.pop(context, newCategory);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Category', style: AppTextThemes.font20WhiteRegularWithStyle),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category Name:', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              SizedBox(height: 10.h),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Category name',
                  hintStyle: const TextStyle(color: AppColors.lightGrey),
                  filled: true,
                  fillColor: AppColors.textFieldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Text('Category Icon:', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: _icons.map((icon) {
                  final isSelected = _selectedIconCode == icon.codePoint;
                  return InkWell(
                    onTap: () => setState(() => _selectedIconCode = icon.codePoint),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : AppColors.textFieldBackgroundColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : AppColors.lightGrey,
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              Text('Category Color:', style: TextStyle(color: Colors.white, fontSize: 16.sp)),
              SizedBox(height: 12.h),
              Wrap(
                spacing: 12.w,
                runSpacing: 12.h,
                children: _colors.map((colorVal) {
                  final isSelected = _selectedColorValue == colorVal;
                  return InkWell(
                    onTap: () => setState(() => _selectedColorValue = colorVal),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Color(colorVal),
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, size: 20, color: Colors.black)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 40.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.primaryColor, fontSize: 16.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      onPressed: _saveCategory,
                      child: Text(
                        'Create Category',
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
