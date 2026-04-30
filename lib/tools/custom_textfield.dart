import 'package:flutter/material.dart';

class Customtextfield extends StatelessWidget {
  final String label;
  final type;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLength;




  const Customtextfield({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
     this.type,
    this.obscureText = true,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'this field is required!';
            }
            return null;
          },
      obscureText: obscureText,
      controller: controller,
      keyboardType: type,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color.fromARGB(255, 163, 166, 172)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromARGB(255, 6, 34, 78)),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 238, 236, 236),
      ),
    );
  }
}
