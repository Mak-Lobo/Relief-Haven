import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionStorage {
  static const _sessionKey = 'auth.session.json';
  static const _accessTokenKey = 'auth.jwt.access_token';
  static const _refreshTokenKey = 'auth.jwt.refresh_token';

  Future<void> persistSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionJson = jsonEncode(session.toJson());

    await prefs.setString(_sessionKey, sessionJson);
    await prefs.setString(_accessTokenKey, session.accessToken);

    if (session.refreshToken case final refreshToken?) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    } else {
      await prefs.remove(_refreshTokenKey);
    }
  }

  Future<String?> readPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionKey);
  }

  Future<String?> readAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
