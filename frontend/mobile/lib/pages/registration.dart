import 'package:flutter/material.dart';

import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var header = MediaQuery.sizeOf(context).height * 0.25;

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
                    alignment: .topCenter,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const .all(5),
                          child: Image.asset("assets/images/compass.png"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Create account with Relief Haven.",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight(600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SampleForm(height: MediaQuery.of(context).size.height - header),
          ],
        ),
      ),
    );
  }
}

class SampleForm extends StatelessWidget {
  final double height;

  const SampleForm({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    // var containerHeight = MediaQuery.of(context).size.height * 0.56;

    return Container(
      // decoration: BoxDecoration(borderRadius: .vertical(top: .circular(15)),
      height: height,
      padding: const .symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Form(
            child: Column(
              children: [
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.person_2),
                  labelText: 'Enter first name',
                  hintText: 'First name',
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.person_2),
                  labelText: "Enter last name",
                  hintText: "Last name",
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.email),
                  labelText: "Enter email address",
                  hintText: "Email address",
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.phone),
                  labelText: "Enter phone number",
                  hintText: "Phone number",
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.person_2),
                  labelText: "Enter password",
                  hintText: "Password",
                  trailingIcon: Icon(Icons.visibility),
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.person_2),
                  labelText: "Reenter password",
                  hintText: "Password",
                  trailingIcon: Icon(Icons.visibility),
                  obscureText: true,
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: WidgetStateProperty.all(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  child: Text("Sign Up"),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        print("Tapped. Going to login page....");
                      },
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
