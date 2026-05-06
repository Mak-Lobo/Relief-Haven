import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';
import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:toastification/toastification.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Welcome back.')));
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final header = MediaQuery.sizeOf(context).height * 0.25125;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<AuthState>(authProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: Text("Login Error"),
          description: Text(nextError),
          icon: const Icon(Icons.error_outline_rounded),
          style: ToastificationStyle.flatColored,
          alignment: Alignment.bottomCenter,
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surfaceTint,
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            SizedBox(
              height: header,
              child: Column(
                children: [
                  Align(
                    alignment: .topCenter,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: const BorderRadius.all(.circular(15)),
                        ),
                        child: Padding(
                          padding: const .all(5),
                          child: Image.asset(
                            "assets/images/compass_splash.png",
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Welcome back. Login to continue.",
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _LoginForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
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

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.height,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final double height;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceBright,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            CustomTxtFormFields(
              controller: emailController,
              leadingIcon: const Icon(Icons.email),
              labelText: 'Enter email',
              hintText: 'Email',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabledField: !isSubmitting,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) {
                  return 'Please enter your email.';
                }
                if (!email.contains('@')) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
            ),
            const SizedBox(height: 25),
            CustomTxtFormFields(
              controller: passwordController,
              leadingIcon: const Icon(Icons.lock),
              labelText: "Enter Password",
              hintText: "Password",
              trailingIcon: const Icon(Icons.visibility),
              obscureText: true,
              textInputAction: TextInputAction.done,
              enabledField: !isSubmitting,
              validator: (value) {
                if ((value ?? '').isEmpty) {
                  return 'Please enter your password.';
                }
                return null;
              },
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 50),
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
              child: Text(isSubmitting ? "Signing In..." : "Sign In"),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Need an account?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: isSubmitting
                      ? null
                      : () {
                          Navigator.of(
                            context,
                          ).pushReplacementNamed('/registration');
                        },
                  child: Text(
                    'Sign Up',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.primary,
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

// @Preview(name: 'Login Screen')
// Widget loginScreenPreview() =>
//     const ProviderScope(child: MaterialApp(home: LoginScreen()));
