import 'package:flutter/material.dart';

class CustomSnackbar {
  final String text;
  final Color? color;
  const CustomSnackbar({required this.text, this.color});

  SnackBar build() {
    return SnackBar(
      duration: Duration(milliseconds: 600),
      content: Text(text),
      backgroundColor: color ?? Colors.blue[400],
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
