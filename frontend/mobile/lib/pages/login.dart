import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:relief_haven_mobile/common_widgets/custom_input_fields.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var header = MediaQuery.sizeOf(context).height * 0.25;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceTint,
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
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          borderRadius:
                              BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset("assets/images/compass.png"),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "Welcome back. Login to continue.",
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
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Form(
            child: Column(
              children: [
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.email),
                  labelText: 'Enter email',
                  hintText: 'Email',
                ),
                const SizedBox(height: 25),
                CustomTxtFormFields(
                  leadingIcon: Icon(Icons.lock),
                  labelText: "Enter Password",
                  hintText: "Password",
                  trailingIcon: Icon(Icons.visibility),
                  obscureText: true,
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      log(
                        "Tapped ",
                        time: DateTime.now(),
                        name: "Forgot Password",
                        level: 1,
                      );
                    },
                    child: Text(
                      'Forgot Password?',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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
                  child: Text("Sign In"),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        log(
                          "Tapped. Going to login page....",
                          time: DateTime.now(),
                          name: "Navigation",
                          level: 1,
                        );
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

@Preview(name: 'Login Screen')
Widget loginScreenPreview() => const LoginScreen();
