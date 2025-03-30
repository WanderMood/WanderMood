import 'package:flutter/material.dart';

class Mood {
  final String name;
  final IconData icon;
  final String description;
  final Color color;

  const Mood({
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });

  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      name: json['name'] as String,
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      description: json['description'] as String,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'icon': icon.codePoint,
      'description': description,
      'color': color.value,
    };
  }

  @override
  String toString() => name;
} 