import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';
import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:toastification/toastification.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .signUp(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          phone: _phoneController.text,
        );

    if (!mounted || !success) {
      return;
    }

    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final header = MediaQuery.sizeOf(context).height * 0.25125;

    ref.listen<AuthState>(authProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(nextError)));
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            SizedBox(
              height: header,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(
                            "assets/images/compass_splash.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Create account with Relief Haven.",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _RegistrationForm(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              emailController: _emailController,
              phoneController: _phoneController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              height: MediaQuery.of(context).size.height - header,
              isSubmitting: authState.isSubmitting,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationForm extends StatelessWidget {
  const _RegistrationForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.height,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final double height;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: const .vertical(top: Radius.circular(15)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTxtFormFields(
              controller: firstNameController,
              leadingIcon: const Icon(Icons.person_2),
              labelText: 'Enter first name',
              hintText: 'First name',
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: lastNameController,
              leadingIcon: const Icon(Icons.person_2),
              labelText: "Enter last name",
              hintText: "Last name",
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: emailController,
              leadingIcon: const Icon(Icons.email),
              labelText: "Enter email address",
              hintText: "Email address",
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Please enter your email address.';
                }
                if (!email.contains('@')) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: phoneController,
              leadingIcon: const Icon(Icons.phone),
              labelText: "Enter phone number",
              hintText: "7** *** *** or 1** *** ***",
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                final phone = value?.trim() ?? '';
                if (phone.isEmpty) {
                  return 'Please enter your phone number.';
                }
                if (!RegExp(r'^\d+$').hasMatch(phone)) {
                  return 'Phone number must contain digits only.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: passwordController,
              leadingIcon: const Icon(Icons.lock),
              labelText: "Enter password",
              hintText: "Password",
              trailingIcon: const Icon(Icons.visibility),
              obscureText: true,
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                if ((value ?? '').length < 6) {
                  return 'Password must be at least 6 characters.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: confirmPasswordController,
              leadingIcon: const Icon(Icons.lock_outline),
              labelText: "Reenter password",
              hintText: "Password",
              trailingIcon: const Icon(Icons.visibility),
              obscureText: true,
              textInputAction: TextInputAction.done,
              enabledField: !isSubmitting,
              validator: (value) {
                if ((value ?? '') != passwordController.text) {
                  return 'Passwords do not match.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.primary,
                ),
                foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              child: Text(isSubmitting ? "Creating Account..." : "Sign Up"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: isSubmitting
                      ? null
                      : () {
                          Navigator.of(context).pushReplacementNamed('/login');
                        },
                  child: Text(
                    'Sign In',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
