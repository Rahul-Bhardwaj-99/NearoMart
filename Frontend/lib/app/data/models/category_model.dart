import 'package:flutter/material.dart';

class CategoryModel {
  final String? id;
  final String name;
  final String? iconName;
  final IconData? icon;

  CategoryModel({this.id, required this.name, this.iconName, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      iconName: json['icon'],
      icon: _getIconData(json['icon']),
    );
  }

  static IconData _getIconData(String? name) {
    switch (name) {
      case 'shopping_cart': return Icons.shopping_cart_outlined;
      case 'water_drop': return Icons.water_drop_outlined;
      case 'bakery_dining': return Icons.bakery_dining_outlined;
      case 'eco': return Icons.eco_outlined;
      case 'medical_services': return Icons.medical_services_outlined;
      default: return Icons.category_outlined;
    }
  }
}
