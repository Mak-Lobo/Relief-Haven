import 'package:flutter/material.dart';

class CustomTxtFormFields extends StatelessWidget {
  Icon? leadingIcon;
  final String labelText;
  final String hintText;
  Icon? trailingIcon;
  bool? obscureText, enabledField;

  CustomTxtFormFields({
    super.key,
    this.leadingIcon,
    this.labelText = "",
    required this.hintText,
    this.trailingIcon,
    this.obscureText = false,
    this.enabledField = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText!,
      obscuringCharacter: '*',
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        icon: leadingIcon,
        labelText: labelText,
        hintText: hintText,
        suffixIcon: trailingIcon,
        enabled: enabledField!,
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
