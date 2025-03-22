import 'package:flutter/material.dart';

class CustomSnackbar {
  final String text;
  final Color? color;
  final Duration duration;

  CustomSnackbar({
    required this.text,
    this.color,
    this.duration = const Duration(seconds: 2),
  });

  SnackBar build() {
    return SnackBar(
      content: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color ?? Colors.blue[700],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      duration: duration,
      margin: EdgeInsets.all(16),
      elevation: 4,
    );
  }
}
