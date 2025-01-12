import 'package:flutter/material.dart';

class Task {
  final String title;
  final String description;
  final int reward;
  final String url;
  final IconData icon;
  bool isCompleted;
  int lastOpened; // Add the lastOpened property

  Task({
  required this.title,
  required this.description,
  required this.reward,
  required this.url,
  required this.icon,
  this.isCompleted = false,
  this.lastOpened = 0,  // Initialize with 0, indicating it hasn't been opened yet
  });
}