import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';
import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:toastification/toastification.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    _firstNameController = TextEditingController(text: profile?.firstName);
    _lastNameController = TextEditingController(text: profile?.lastName);
    _emailController = TextEditingController(
      text: profile?.email ?? ref.read(authProvider).authUser?.email,
    );
    _phoneController = TextEditingController(text: profile?.phone.toString());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .updateProfile(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
        );

    if (!mounted || !success) {
      return;
    }

    toastification.show(
      context: context,
      alignment: .bottomCenter,
      type: ToastificationType.success,
      description: const Text('Profile updated successfully!'),
      icon: const Icon(Icons.check_circle_outline_rounded),
      autoCloseDuration: const Duration(seconds: 3),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final header = MediaQuery.sizeOf(context).height * 0.25125;

    ref.listen<AuthState>(authProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final nextError = next.errorMessage;
      if (nextError != null && nextError != previousError) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text("Update Error"),
          description: Text(nextError),
          icon: const Icon(Icons.error_outline_rounded),
          style: ToastificationStyle.flatColored,
          alignment: Alignment.bottomCenter,
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
        );
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
                    "Edit your Relief Haven profile.",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _EditProfileForm(
              formKey: _formKey,
              firstNameController: _firstNameController,
              lastNameController: _lastNameController,
              emailController: _emailController,
              phoneController: _phoneController,
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

class _EditProfileForm extends StatelessWidget {
  const _EditProfileForm({
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.phoneController,
    required this.height,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
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
              textInputAction: TextInputAction.done,
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
            const SizedBox(height: 35),
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
              child: Text(isSubmitting ? "Saving changes..." : "Save changes"),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
