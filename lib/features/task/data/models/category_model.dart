import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final int colorValue;
  final int iconCode;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.iconCode,
  });

  Color get color => Color(colorValue);

  IconData get icon {
    return _iconLookup[iconCode] ?? Icons.category_outlined;
  }

  static const Map<int, IconData> _iconLookup = {
    0xe59c: Icons.shopping_basket_outlined,
    0xe6f2: Icons.work_outline,
    0xe28f: Icons.fitness_center_outlined,
    0xe117: Icons.brush_outlined,
    0xe559: Icons.school_outlined,
    0xe137: Icons.campaign_outlined,
    0xe415: Icons.music_note_outlined,
    0xe25b: Icons.favorite_border,
    0xe40f: Icons.movie_outlined,
    0xe318: Icons.home_outlined,
    0xe0ef: Icons.book_outlined,
    0xe29d: Icons.flight_takeoff,
    0xe360: Icons.laptop,
    0xe17e: Icons.code,
    0xe180: Icons.coffee,
    0xe4a1: Icons.pets,
  };

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconCode': iconCode,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['colorValue'] as int,
      iconCode: map['iconCode'] as int,
    );
  }

  static List<CategoryModel> get defaultCategories => [
        CategoryModel(
          id: 'grocery',
          name: 'Grocery',
          colorValue: 0xFFCCFF80,
          iconCode: Icons.shopping_basket_outlined.codePoint,
        ),
        CategoryModel(
          id: 'work',
          name: 'Work',
          colorValue: 0xFFFF9680,
          iconCode: Icons.work_outline.codePoint,
        ),
        CategoryModel(
          id: 'sport',
          name: 'Sport',
          colorValue: 0xFF80FFFF,
          iconCode: Icons.fitness_center_outlined.codePoint,
        ),
        CategoryModel(
          id: 'design',
          name: 'Design',
          colorValue: 0xFF80FFD9,
          iconCode: Icons.brush_outlined.codePoint,
        ),
        CategoryModel(
          id: 'university',
          name: 'University',
          colorValue: 0xFF809CFF,
          iconCode: Icons.school_outlined.codePoint,
        ),
        CategoryModel(
          id: 'social',
          name: 'Social',
          colorValue: 0xFFFF80EB,
          iconCode: Icons.campaign_outlined.codePoint,
        ),
        CategoryModel(
          id: 'music',
          name: 'Music',
          colorValue: 0xFFFC80FF,
          iconCode: Icons.music_note_outlined.codePoint,
        ),
        CategoryModel(
          id: 'health',
          name: 'Health',
          colorValue: 0xFF80FFA3,
          iconCode: Icons.favorite_border.codePoint,
        ),
        CategoryModel(
          id: 'movie',
          name: 'Movie',
          colorValue: 0xFF80D1FF,
          iconCode: Icons.movie_outlined.codePoint,
        ),
        CategoryModel(
          id: 'home',
          name: 'Home',
          colorValue: 0xFFFF9980,
          iconCode: Icons.home_outlined.codePoint,
        ),
      ];
}
