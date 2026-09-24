import 'package:flutter/material.dart';

class GameDefinition {
  const GameDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    this.screenBuilder,
    this.externalUri,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final WidgetBuilder? screenBuilder;
  final Uri? externalUri;
}
