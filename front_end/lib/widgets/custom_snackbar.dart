import 'package:flutter/material.dart';

class CustomSnackbar extends SnackBar {
  final String text;
  final Color? color;

  CustomSnackbar({
    required this.text,
    this.color = Colors.blue,
    Duration duration = const Duration(seconds: 4),
  }) : super(
          content: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(15),
          elevation: 6,
        );

  SnackBar build() {
    return this;
  }
}
