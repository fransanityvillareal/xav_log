import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final Color? buttonColor;
  final Color? textColor;
  final EdgeInsetsGeometry? paddingVertical;

  const LoginButton({
    super.key,
    required this.text,
    required this.onTap,
    this.buttonColor,
    this.textColor,
    this.paddingVertical = const EdgeInsets.symmetric(vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final Color defaultButtonColor = const Color(0xFF003A70); // Ateneo Blue
    final Color defaultTextColor = Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: paddingVertical,
        decoration: BoxDecoration(
          color: buttonColor ?? defaultButtonColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? defaultTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
