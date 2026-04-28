import 'package:flutter/material.dart';

class CustomTxtFormFields extends StatefulWidget {
  final Icon? leadingIcon;
  final String labelText;
  final String hintText;
  final Icon? trailingIcon;
  final bool obscureText;
  final bool enabledField;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const CustomTxtFormFields({
    super.key,
    this.leadingIcon,
    this.labelText = "",
    required this.hintText,
    this.trailingIcon,
    this.obscureText = false,
    this.enabledField = true,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
  });

  @override
  State<CustomTxtFormFields> createState() => _CustomTxtFormFieldsState();
}

class _CustomTxtFormFieldsState extends State<CustomTxtFormFields> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final canToggleObscure = widget.obscureText;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: _obscureText,
      obscuringCharacter: '*',
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        icon: widget.leadingIcon,
        labelText: widget.labelText,
        hintText: widget.hintText,
        suffixIcon: canToggleObscure
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
              )
            : widget.trailingIcon,
        enabled: widget.enabledField,
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
