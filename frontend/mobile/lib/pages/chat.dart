import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:relief_haven_mobile/utils/elevated_button.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "HavenBot",
          style: Theme.of(
            context,
          ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: .spaceAround,
                children: [_WelcomeCopy(), const _PromptCard()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: 118,
      color: colors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onPrimary,
            size: 34,
          ),
          const SizedBox(width: 18),
          Text(
            'HavenBot',
            style: textTheme.headlineMedium?.copyWith(
              color: colors.onPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          Icon(Icons.menu_rounded, color: colors.onPrimary, size: 40),
        ],
      ),
    );
  }
}

class _WelcomeCopy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          'Welcome, Mark, to HavenBot.',
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'How can we be of service to you?🙂',
          textAlign: TextAlign.center,
          style: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const .all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ask HavenBot, for example, how to stop nose bleeding?',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton.filled(
              onPressed: () {},
              iconSize: 20,
              style: IconButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                minimumSize: const Size(24, 24),
              ),
              icon: const Icon(Icons.file_upload_outlined),
            ),
          ),
        ],
      ),
    );
  }
}

@Preview(name: 'Chat Screen')
Widget chatScreenPreview() {
  return _buildPreviewApp(const ChatScreen());
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
