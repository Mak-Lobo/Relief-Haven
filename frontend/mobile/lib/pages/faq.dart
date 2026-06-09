import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relief Haven FAQ'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      body: Markdown(
        data: _faqContent,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
          h2: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.secondary,
            fontWeight: FontWeight.bold,
            height: 2.0,
          ),
          h3: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.onSurface),
          p: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: colors.onSurface,
          ),

          listBullet: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colors.primary),
        ),
      ),
    );
  }

  static const String _faqContent = '''
# HavenBot Assistant

Hello! I am **HavenBot**, your friendly assistant for Relief Haven. I'm here to help you stay safe and informed during emergencies.

## Emergency Response

### What should I do during a flood?
*   Move to higher ground immediately.
*   Avoid walking or driving through floodwaters.
*   Turn off electricity and gas if safe to do so.
*   Keep your emergency kit ready.

### How to stay safe during a fire?
*   Stay low to the floor where the air is cleaner.
*   Touch doors with the back of your hand before opening; if hot, find another exit.
*   Once outside, stay outside and call emergency services.

### What about earthquakes?
*   **Drop** to your hands and knees.
*   **Cover** your head and neck.
*   **Hold on** until the shaking stops.

## First Aid Guidance

### Basic Wound Care
*   Wash hands before treating.
*   Apply gentle pressure to stop bleeding.
*   Clean the wound with clean water.
*   Apply an antibiotic ointment and cover with a bandage.

### Treating Burns
*   Run cool (not cold) water over the burn for 10-20 minutes.
*   Do not apply ice, butter, or ointments.
*   Cover loosely with a sterile dressing.

## Shelter Procedures

### How do I find a shelter?
*   Check the home screen map for nearby shelters.
*   Shelters are color-coded for your convenience:
    *   **Green**: Open and has available space.
    *   **Orange**: Almost full.
    *   **Red**: Full or temporarily inactive.

### What should I bring to a shelter?
*   Identification documents.
*   Essential medications.
*   Personal hygiene items.
*   Extra clothing and blankets if possible.

## About Relief Haven
Relief Haven is dedicated to providing real-time disaster response and navigation to safe zones in Kenya. We prioritize your safety and strive to keep information accurate and up-to-date.

**Important**: In life-threatening situations, always contact local emergency responders immediately.
''';
}
