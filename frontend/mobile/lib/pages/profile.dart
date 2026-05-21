import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:relief_haven_mobile/utils/elevated_button.dart';
import 'package:relief_haven_mobile/common_widgets/shimmer_loading.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final authState = ref.watch(authProvider);

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
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        title: Text(
          "Account Profile",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.onPrimary,
          ),
        ),
        centerTitle: true,
        surfaceTintColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        actions: [
          IconButton(
            onPressed: authState.isInitializing
                ? null
                : () => ref.read(authProvider.notifier).refreshProfile(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh profile',
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: authState.isInitializing && authState.profile == null
            ? const ProfileShimmer()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _ProfileCard(authState: authState),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard({required this.authState});

  final AuthState authState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final profile = authState.profile;

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
          Center(child: _ProfileAvatar(displayName: authState.displayName)),
          const SizedBox(height: 10),
          _ProfileField(
            label: 'First Name',
            value: profile?.firstName ?? _firstToken(authState.displayName),
          ),
          const SizedBox(height: 28),
          _ProfileField(
            label: 'Last Name',
            value: profile?.lastName ?? _remainingTokens(authState.displayName),
          ),
          const SizedBox(height: 28),
          _ProfileField(
            label: 'Phone Number',
            value: profile != null ? '+254${profile.phone}' : 'Not available',
          ),
          const SizedBox(height: 28),
          _ProfileField(
            label: 'Email Address',
            value:
                profile?.email ?? authState.authUser?.email ?? 'Not available',
          ),
          const SizedBox(height: 28),
          _ProfileField(
            label: 'Created at',
            value: profile != null
                ? DateFormat('d MMM, yyyy').format(profile.createdAt)
                : 'Not available',
          ),
          const SizedBox(height: 28),
          _ProfileField(
            label: 'Updated at',
            value: profile != null
                ? DateFormat('d MMM, yyyy').format(profile.updatedAt)
                : 'Not available',
          ),
          const SizedBox(height: 18),
          if (authState.errorMessage != null && profile == null)
            Text(
              authState.errorMessage!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.error),
            ),
          const SizedBox(height: 24),
          _ProfileActions(
            isSubmitting: authState.isSubmitting,
            onRefresh: () => ref.read(authProvider.notifier).refreshProfile(),
            onSignOut: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }

  String _firstToken(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty ? parts.first : 'Not available';
  }

  String _remainingTokens(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) {
      return 'Not available';
    }
    return parts.sublist(1).join(' ');
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initials = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? 'RH' : initials,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colors.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({required this.label, required this.value});

  final String label;
  final String value;

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
  const _ProfileActions({
    required this.isSubmitting,
    required this.onRefresh,
    required this.onSignOut,
  });

  final bool isSubmitting;
  final VoidCallback onRefresh;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.refresh_rounded),
                Text(
                  'Refresh',
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onSignOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Icon(Icons.logout_rounded),
                Text(
                  isSubmitting ? 'Working...' : 'Log out',
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
    Scaffold(
      body: Center(
        child: _ProfileActions(
          isSubmitting: false,
          onRefresh: () {},
          onSignOut: () {},
        ),
      ),
    ),
  );
}

@Preview(name: 'Profile Screen')
Widget profileScreenPreview() {
  return _buildPreviewApp(const ProfileScreen());
}

Widget _buildPreviewApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
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
    ),
  );
}
