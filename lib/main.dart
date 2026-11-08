import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/services/supabase_auth_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_screen.dart';
import 'features/chat/screens/matches_screen.dart';
import 'features/matching/controllers/match_controller.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/profile/presentation/user_profile_screen.dart';
import 'features/swipe_deck/presentation/swipe_deck_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize live Supabase Client if not in local mock demo mode
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
  } catch (_) {
    // Safe fallback for offline demo or test environments
  }

  runApp(
    const ProviderScope(
      child: RoomSyncApp(),
    ),
  );
}

class RoomSyncApp extends StatelessWidget {
  const RoomSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

/// Listens to live Supabase Auth state and routes unauthenticated users to AuthScreen
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    if (AppConstants.useMockData || !authService.isClientReady) {
      return const MainNavigationShell();
    }

    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (authState) {
        final session = authState.session;
        if (session != null) {
          return const MainNavigationShell();
        }
        return const AuthScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchProvider);
    final matchCount = matchState.matches.length;

    final screens = [
      SwipeDeckScreen(
        onNavigateToMatches: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      const MatchesScreen(),
      OnboardingScreen(
        onFinish: () {
          setState(() {
            _currentIndex = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Preferences updated! Matches recalculated.'),
              backgroundColor: AppColors.scoreHigh,
            ),
          );
        },
      ),
      const UserProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.flame),
              activeIcon: Icon(LucideIcons.flame, color: AppColors.primary),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(LucideIcons.messageCircle),
                  if (matchCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$matchCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(LucideIcons.messageCircle, color: AppColors.primary),
              label: 'Matches',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.sliders),
              activeIcon: Icon(LucideIcons.sliders, color: AppColors.primary),
              label: 'Habits',
            ),
            const BottomNavigationBarItem(
              icon: Icon(LucideIcons.user),
              activeIcon: Icon(LucideIcons.user, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
