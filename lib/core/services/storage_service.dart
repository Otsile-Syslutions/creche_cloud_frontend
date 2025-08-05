// lib/core/services/storage_service.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService extends GetxService {
  static StorageService get to => Get.find();
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializePrefs();
  }

  // FIXED: Proper initialization with error handling and status tracking
  Future<void> _initializePrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize SharedPreferences: $e');
      rethrow;
    }
  }

  // FIXED: Ensure prefs are initialized before any operation
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _prefs == null) {
      await _initializePrefs();
    }
  }

  // String operations - FIXED: Added initialization check
  Future<void> setString(String key, String value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, value);
  }

  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  // Int operations - FIXED: Added initialization check
  Future<void> setInt(String key, int value) async {
    await _ensureInitialized();
    await _prefs!.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt(key);
  }

  // Bool operations - FIXED: Added initialization check
  Future<void> setBool(String key, bool value) async {
    await _ensureInitialized();
    await _prefs!.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs!.getBool(key);
  }

  // Double operations - FIXED: Added initialization check
  Future<void> setDouble(String key, double value) async {
    await _ensureInitialized();
    await _prefs!.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  // Object operations (JSON) - FIXED: Added initialization check
  Future<void> setObject(String key, Map<String, dynamic> value) async {
    await _ensureInitialized();
    await _prefs!.setString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  // List operations - FIXED: Added initialization check
  Future<void> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    await _prefs!.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  // Remove operations - FIXED: Added initialization check
  Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }

  // Check if key exists - FIXED: Added initialization check
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  // Get all keys - FIXED: Added initialization check
  Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }

  // ADDED: Check if service is properly initialized
  bool get isInitialized => _isInitialized && _prefs != null;

  // ADDED: Manual initialization method for critical paths
  Future<void> ensureInitialized() async {
    await _ensureInitialized();
  }
}