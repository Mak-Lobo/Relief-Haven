import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/user_model.dart';
import 'base.dart';

final _logger = Logger();

class UserRequests extends Base {
  static const _mobileRole = 'civilian';
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required int phone,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedName = name.trim();
    final splitName = _splitName(trimmedName);

    if (trimmedName.isEmpty) {
      throw const RequestException('Please provide your name.');
    }

    if (trimmedEmail.isEmpty) {
      throw const RequestException('Please provide your email address.');
    }

    if (password.isEmpty) {
      throw const RequestException('Please provide your password.');
    }

    try {
      final response = await _supabase.auth.signUp(
        email: trimmedEmail,
        password: password,
        data: {
          'name': trimmedName,
          'first_name': splitName.firstName,
          'last_name': splitName.lastName,
          'role': _mobileRole,
        },
      );

      final user = response.user;
      if (user == null) {
        throw const RequestException(
          'Registration completed, but no user record was returned.',
        );
      }

      await _mirrorUserToBackend(
        id: user.id,
        name: trimmedName,
        email: trimmedEmail,
        phone: phone,
      );

      return response;
    } on DioException catch (error) {
      final mappedError = mapDioException(
        error,
        fallbackMessage:
            'Account created, but syncing your profile to the backend failed.',
      );
      _logger.e('Sign up sync error', error: mappedError);
      throw mappedError;
    } on AuthException catch (error) {
      _logger.e('Sign up auth error', error: error);
      throw RequestException(error.message);
    } catch (error, stackTrace) {
      _logger.e('Sign up error', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final trimmedEmail = email.trim();
      if (trimmedEmail.isEmpty) {
        throw const RequestException('Please provide your email address.');
      }

      if (password.isEmpty) {
        throw const RequestException('Please provide your password.');
      }

      final response = await _supabase.auth.signInWithPassword(
        email: trimmedEmail,
        password: password,
      );
      _logger.i('Sign in successful. User: ${response.user?.email}');
      return response;
    } on AuthException catch (error) {
      _logger.e('Sign in auth error', error: error);
      throw RequestException(error.message);
    } catch (error, stackTrace) {
      _logger.e('Sign in error', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _logger.i('Signing out. User: ${_supabase.auth.currentUser?.email}');
      await _supabase.auth.signOut();
    } on AuthException catch (error) {
      _logger.e('Sign out auth error', error: error);
      throw RequestException(error.message);
    } catch (error, stackTrace) {
      _logger.e('Sign out error', error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<UserModel?> _mirrorUserToBackend({
    required String id,
    required String name,
    required String email,
    required int phone,
  }) async {
    final splitName = _splitName(name);

    try {
      final response = await dio.post(
        '/users/sync',
        data: {
          'user_id': id,
          'first_name': splitName.firstName,
          'last_name': splitName.lastName,
          'email': email,
          'phone': phone,
          'role': _mobileRole,
          'county_work': null,
        },
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map<String, dynamic>) {
        _logger.i(
          'Account created successfully. User ${splitName.firstName} ${splitName.lastName}',
        );
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (error) {
      throw mapDioException(
        error,
        fallbackMessage:
            'Account created, but syncing your profile to the backend failed.',
      );
    }
  }

  Future<UserModel?> fetchUserData(String id) async {
    final trimmedId = id.trim();
    if (trimmedId.isEmpty) {
      throw const RequestException(
        'A user id is required to fetch profile data.',
      );
    }

    try {
      final response = await dio.get('/users/$trimmedId');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (error) {
      final mappedError = mapDioException(
        error,
        fallbackMessage: 'Unable to load your profile right now.',
      );
      _logger.e('Error fetching user data', error: mappedError);
      throw mappedError;
    }
  }

  Future<UserModel?> fetchCurrentUserData() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return null;
    }
    return fetchUserData(currentUser.id);
  }

  _SplitName _splitName(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return const _SplitName(firstName: '', lastName: '');
    }

    if (parts.length == 1) {
      return _SplitName(firstName: parts.first, lastName: parts.first);
    }

    return _SplitName(
      firstName: parts.first,
      lastName: parts.sublist(1).join(' '),
    );
  }
}

class _SplitName {
  const _SplitName({required this.firstName, required this.lastName});

  final String firstName;
  final String lastName;
}
