import 'package:flutter/material.dart';

class TextfieldLogin extends StatefulWidget {
  final String hintText;
  final bool obsecuretext;
  final TextEditingController controller;
  final Widget? prefixIcon;

  const TextfieldLogin({
    super.key,
    required this.hintText,
    required this.obsecuretext,
    required this.controller,
    this.prefixIcon,
  });

  @override
  _TextfieldLoginState createState() => _TextfieldLoginState();
}

class _TextfieldLoginState extends State<TextfieldLogin> {
  late bool _obscureText;

  static const Color _lightFieldBg = Color(0xFFF3F6FA);
  static const Color _ateneoBlue = Color(0xFF003A70);
  static const Color _grayBorder = Color(0xFFD0D5DD);
  static const Color _grayIcon = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obsecuretext;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: TextField(
        obscureText: _obscureText,
        controller: widget.controller,
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 12, right: 8),
                  child: IconTheme(
                    data: const IconThemeData(color: _ateneoBlue),
                    child: widget.prefixIcon!,
                  ),
                )
              : null,
          suffixIcon: widget.obsecuretext
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: _ateneoBlue,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                )
              : null,
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: _lightFieldBg,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _grayBorder, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: _ateneoBlue, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        ),
      ),
    );
  }
}
