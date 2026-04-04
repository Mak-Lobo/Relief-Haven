import 'package:flutter/material.dart';

class CustomTxtFormFields extends StatelessWidget {
  final Icon leadingIcon;
  final String labelText;
  final String hintText;
  Icon? trailingIcon;
  bool? obscureText;

  CustomTxtFormFields({
    super.key,
    required this.leadingIcon,
    required this.labelText,
    required this.hintText,
    this.trailingIcon,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText!,
      obscuringCharacter: '*',
      decoration: InputDecoration(
        icon: leadingIcon,
        labelText: labelText,
        hintText: hintText,
        suffixIcon: trailingIcon,
        hintStyle: TextStyle(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.75),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
    );
  }
}
