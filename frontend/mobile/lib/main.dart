import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:logger/logger.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:relief_haven_mobile/pages/registration.dart';
import 'package:relief_haven_mobile/pages/edit_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

import 'package:relief_haven_mobile/common_widgets/shimmer_loading.dart';
import 'package:relief_haven_mobile/pages/chat.dart';
import 'package:relief_haven_mobile/pages/donations.dart';
import 'package:relief_haven_mobile/pages/home.dart';
import 'package:relief_haven_mobile/pages/login.dart';
import 'package:relief_haven_mobile/pages/profile.dart';
import 'package:relief_haven_mobile/providers/auth_provider.dart';
import 'package:relief_haven_mobile/providers/theme_provider.dart';
import 'package:relief_haven_mobile/services/requests/base.dart';
import 'package:relief_haven_mobile/utils/elevated_button.dart';

Mixpanel? mixpanel;
bool _identified = false;

void _identifyUser(String? userId) {
  if (_identified || userId == null) return;
  _identified = true;
  mixpanel?.identify(userId);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  await FMTCObjectBoxBackend().initialise();
  await const FMTCStore('mapCache').manage.create();
  await dotenv.load(fileName: ".env");

  final logger = Logger();
  final base = Base();
  final url = dotenv.env['SUPABASE_URL']!;
  final anonKey = dotenv.env['SUPABASE_ANON_KEY']!;

  mixpanel = await Mixpanel.init(
    dotenv.env['MIXPANEL_TOKEN'] ?? '',
    trackAutomaticEvents: true,
  ); // ★ ADDED
  logger.d('Mixpanel initialized');

  await Supabase.initialize(url: url, anonKey: anonKey);
  logger.d('Supabase initialized');
  logger.i('Backend URL: ${base.baseURL}');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return ToastificationWrapper(
      config: ToastificationConfig(
        animationDuration: const Duration(milliseconds: 500),
      ),
      child: MaterialApp(
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
        themeMode: themeMode,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/registration': (context) => const RegistrationScreen(),
          '/edit-profile': (context) => const EditProfileScreen(),
          '/home': (context) => const HomeScreen(),
        },
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isInitializing) {
      return const ShimmerLoading();
    }

    if (!authState.isAuthenticated) {
      return const LoginScreen();
    }

    _identifyUser(authState.displayName);

    return const AppShell();
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
