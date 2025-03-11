import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback handleSignin;
  final bool flag;
  const AuthButton({super.key, required this.handleSignin, this.flag = true});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: handleSignin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        'Sign ${(flag) ? 'In' : 'Up'}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
