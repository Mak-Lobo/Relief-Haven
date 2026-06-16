import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';
import '../services/requests/base.dart';
import '../services/auth/session_storage.dart';
import '../services/requests/user_requests.dart';

final userRequestsProvider = Provider<UserRequests>((ref) {
  return UserRequests();
});

final sessionStorageProvider = Provider<SessionStorage>((ref) {
  return SessionStorage();
});

final authProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthState {
  const AuthState({
    this.isInitializing = false,
    this.isSubmitting = false,
    this.authUser,
    this.profile,
    this.errorMessage,
  });

  final bool isInitializing;
  final bool isSubmitting;
  final User? authUser;
  final UserModel? profile;
  final String? errorMessage;

  bool get isAuthenticated => authUser != null;

  String get displayName {
    final profileName = [
      profile?.firstName,
      profile?.lastName,
    ]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');

    if (profileName.isNotEmpty) {
      return profileName;
    }

    final authMetadataName = authUser?.userMetadata?['name'];
    if (authMetadataName is String && authMetadataName.trim().isNotEmpty) {
      return authMetadataName.trim();
    }

    final email = authUser?.email;
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'there';
  }

  AuthState copyWith({
    bool? isInitializing,
    bool? isSubmitting,
    User? authUser,
    bool clearAuthUser = false,
    UserModel? profile,
    bool clearProfile = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      authUser: clearAuthUser ? null : (authUser ?? this.authUser),
      profile: clearProfile ? null : (profile ?? this.profile),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends Notifier<AuthState> {
  late final UserRequests _userRequests;
  late final SessionStorage _sessionStorage;
  late final SupabaseClient _supabase;
  bool _bootstrapped = false;
  StreamSubscription<dynamic>? _authSubscription;

  @override
  AuthState build() {
    _userRequests = ref.watch(userRequestsProvider);
    _sessionStorage = ref.watch(sessionStorageProvider);
    _supabase = Supabase.instance.client;

    _authSubscription ??= _supabase.auth.onAuthStateChange.listen((event) async {
      final session = event.session;

      if (session != null) {
        await _sessionStorage.persistSession(session);
      } else if (event.event == AuthChangeEvent.signedOut) {
        await _sessionStorage.clear();
      }
    });

    ref.onDispose(() async {
      await _authSubscription?.cancel();
      _authSubscription = null;
    });

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(_bootstrapSession);
    }

    return AuthState(
      authUser: _supabase.auth.currentUser,
      isInitializing: true,
    );
  }

  Future<void> _bootstrapSession() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        await initialize();
        return;
      }

      final persistedSession = await _sessionStorage.readPersistedSession();
      if (persistedSession == null || persistedSession.isEmpty) {
        state = state.copyWith(
          isInitializing: false,
          clearAuthUser: true,
          clearProfile: true,
          clearError: true,
        );
        return;
      }

      await _supabase.auth.recoverSession(persistedSession);
      await initialize();
    } catch (error) {
      await _sessionStorage.clear();
      state = state.copyWith(
        isInitializing: false,
        clearAuthUser: true,
        clearProfile: true,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> initialize() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      state = state.copyWith(
        isInitializing: false,
        clearAuthUser: true,
        clearProfile: true,
        clearError: true,
      );
      return;
    }

    state = state.copyWith(
      isInitializing: true,
      authUser: currentUser,
      clearError: true,
    );

    try {
      final profile = await _userRequests.fetchUserData(currentUser.id);
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _sessionStorage.persistSession(session);
      }
      state = state.copyWith(
        isInitializing: false,
        authUser: currentUser,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitializing: false,
        authUser: currentUser,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final response = await _userRequests.signIn(
        email: email,
        password: password,
      );
      final authUser = response.user ?? _supabase.auth.currentUser;
      UserModel? profile;
      if (authUser != null) {
        profile = await _userRequests.fetchUserData(authUser.id);
      }
      final session = response.session ?? _supabase.auth.currentSession;
      if (session != null) {
        await _sessionStorage.persistSession(session);
      }

      _bootstrapped = true;
      state = state.copyWith(
        isSubmitting: false,
        isInitializing: false,
        authUser: authUser,
        profile: profile,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phone,
  }) async {
    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();
    final trimmedPhone = phone.trim();

    if (trimmedFirstName.isEmpty || trimmedLastName.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please provide both your first and last name.',
      );
      return false;
    }

    if (password != confirmPassword) {
      state = state.copyWith(errorMessage: 'Passwords do not match.');
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(trimmedPhone)) {
      state = state.copyWith(
        errorMessage: 'Phone number must contain digits only.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final response = await _userRequests.signUp(
        email: email,
        password: password,
        name: '$trimmedFirstName $trimmedLastName',
        phone: int.parse(trimmedPhone),
      );

      final authUser = response.user ?? _supabase.auth.currentUser;
      UserModel? profile;
      if (authUser != null) {
        profile = await _userRequests.fetchUserData(authUser.id);
      }
      final session = response.session ?? _supabase.auth.currentSession;
      if (session != null) {
        await _sessionStorage.persistSession(session);
      }

      _bootstrapped = true;
      state = state.copyWith(
        isSubmitting: false,
        isInitializing: false,
        authUser: authUser,
        profile: profile,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();
    final trimmedEmail = email.trim();
    final trimmedPhone = phone.trim();

    if (trimmedFirstName.isEmpty ||
        trimmedLastName.isEmpty ||
        trimmedEmail.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please provide your name and email address.',
      );
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(trimmedPhone)) {
      state = state.copyWith(
        errorMessage: 'Phone number must contain digits only.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final authUser = state.authUser;
      if (authUser == null) {
        throw const RequestException('You must be logged in to update your profile.');
      }

      final profile = await _userRequests.updateProfile(
        userId: authUser.id,
        firstName: trimmedFirstName,
        lastName: trimmedLastName,
        email: trimmedEmail,
        phone: int.parse(trimmedPhone),
      );

      state = state.copyWith(
        isSubmitting: false,
        profile: profile,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
      return false;
    }
  }

  Future<void> refreshProfile() async {
    final authUser = state.authUser ?? _supabase.auth.currentUser;
    if (authUser == null) {
      return;
    }

    state = state.copyWith(
      isInitializing: true,
      authUser: authUser,
      clearError: true,
    );

    try {
      final profile = await _userRequests.fetchUserData(authUser.id);
      state = state.copyWith(
        isInitializing: false,
        authUser: authUser,
        profile: profile,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitializing: false,
        authUser: authUser,
        errorMessage: _friendlyError(error),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _userRequests.signOut();
      await _sessionStorage.clear();
      _bootstrapped = true;
      state = state.copyWith(
        isSubmitting: false,
        isInitializing: false,
        clearAuthUser: true,
        clearProfile: true,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _friendlyError(error),
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  String _friendlyError(Object error) {
    if (error is RequestException) {
      return error.message;
    }
    if (error is AuthException) {
      return error.message;
    }
    return error.toString().replaceFirst('Exception: ', '');
  }
}
