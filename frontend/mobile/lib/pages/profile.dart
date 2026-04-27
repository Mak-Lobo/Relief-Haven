import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:relief_haven_mobile/utils/elevated_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "Account Profile",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: _ProfileCard(),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _ProfileAvatar()),
          const SizedBox(height: 10),
          const _ProfileField(label: 'First Name', value: 'Mark'),
          const SizedBox(height: 28),
          const _ProfileField(label: 'Last Name', value: 'Njoroge'),
          const SizedBox(height: 28),
          const _ProfileField(label: 'Phone Number', value: '+254722000000'),
          const SizedBox(height: 28),
          const _ProfileField(
            label: 'Email Address',
            value: 'markknjoroge03@gmail.com',
          ),
          const SizedBox(height: 28),
          const _ProfileField(label: 'Created at', value: '4 Apr, 2026'),
          const SizedBox(height: 28),
          const _ProfileField(label: 'Updated at', value: '4 Apr, 2026'),
          const SizedBox(height: 42),
          const _ProfileActions(),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person_rounded, color: colors.onPrimaryContainer),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ProfileActions extends StatelessWidget {
  const _ProfileActions();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                const Icon(Icons.edit),
                Text(
                  'Edit Profile',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onError,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                const Icon(Icons.logout_rounded),
                Text(
                  'Log out',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onError,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

@Preview(name: 'ProfileActions')
Widget profileActionsPreview() {
  return _buildPreviewApp(
    Scaffold(body: Center(child: const _ProfileActions())),
  );
}

@Preview(name: 'Profile Screen')
Widget profileScreenPreview() {
  return _buildPreviewApp(const ProfileScreen());
}

Widget _buildPreviewApp(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0277BD),
        brightness: Brightness.light,
      ),
      brightness: Brightness.light,
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(),
      elevatedButtonTheme: customElevatedBtnTheme,
    ),
    home: child,
  );
}
