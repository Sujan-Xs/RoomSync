import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  SupabaseClient? get _client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  User? get currentUser => _client?.auth.currentUser;
  String? get currentUserId => _client?.auth.currentUser?.id;
  bool get isClientReady => _client != null;

  Stream<AuthState> get authStateChanges {
    final client = _client;
    if (client == null) {
      return const Stream.empty();
    }
    return client.auth.onAuthStateChange;
  }

  Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String name,
    int age = 25,
  }) async {
    final client = _client;
    if (client == null) return null;

    final res = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'age': age},
    );

    if (res.user != null) {
      try {
        await client.from('profiles').insert({
          'user_id': res.user!.id,
          'name': name,
          'age': age,
          'budget': 1500.0,
          'location': 'New York, NY',
          'sleep_start': '23:00',
          'sleep_end': '07:00',
          'cleanliness_score': 4,
          'smoking': 'nonSmoker',
          'pets': 'petFriendly',
          'is_verified': false,
          'avatar_url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
        });
      } catch (_) {
        // Table insert handled by database trigger or existing row
      }
    }
    return res;
  }

  Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) return null;

    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    final client = _client;
    if (client == null) return;
    await client.auth.signOut();
  }
}

final authServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
