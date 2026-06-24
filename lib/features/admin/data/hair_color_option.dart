import 'package:flutter/material.dart';

class HairColorOption {
  const HairColorOption({
    required this.company,
    required this.category,
    required this.code,
    required this.name,
    required this.previewColor,
  });

  final String company;
  final String category;
  final String code;
  final String name;
  final Color previewColor;

  String get fullName => '$code $name';
}
