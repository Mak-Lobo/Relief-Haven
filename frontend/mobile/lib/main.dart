import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relief_haven_mobile/pages/chat.dart';
import 'package:relief_haven_mobile/pages/donations.dart';
import 'package:relief_haven_mobile/pages/home.dart';
import 'package:relief_haven_mobile/pages/profile.dart';
import 'package:relief_haven_mobile/utils/elevated_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Relief Haven',
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
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0277BD),
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        useMaterial3: true,
        textTheme: GoogleFonts.dmSansTextTheme(),
        elevatedButtonTheme: customElevatedBtnTheme,
      ),
      themeMode: .light,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    HomeScreen(),
    DonationScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: colors.surfaceContainerLow,
          indicatorColor: colors.secondaryContainer,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final color = states.contains(WidgetState.selected)
                ? colors.onSecondaryContainer
                : colors.onSurfaceVariant;
            return IconThemeData(color: color, size: 30);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return Theme.of(context).textTheme.titleSmall?.copyWith(
              color: states.contains(WidgetState.selected)
                  ? colors.onSurface
                  : colors.onSurfaceVariant,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.wallet_outlined),
              selectedIcon: Icon(Icons.wallet_rounded),
              label: 'Donation',
            ),
            NavigationDestination(
              icon: Icon(Icons.support_agent_outlined),
              selectedIcon: Icon(Icons.support_agent),
              label: 'HavenBot',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
