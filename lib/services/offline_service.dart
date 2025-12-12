import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/queue_token_model.dart';

class OfflineService {
  static const String _tokensKey = 'offline_tokens';
  static const String _lastSyncKey = 'last_sync_time';

  /// Save tokens to local storage for offline access
  Future<void> saveTokensOffline(List<QueueTokenModel> tokens) async {
    final prefs = await SharedPreferences.getInstance();
    final tokensJson = tokens.map((t) => t.toMap()).toList();
    await prefs.setString(_tokensKey, jsonEncode(tokensJson));
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get tokens from local storage
  Future<List<QueueTokenModel>> getOfflineTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final tokensString = prefs.getString(_tokensKey);
    
    if (tokensString == null) return [];
    
    final List<dynamic> tokensJson = jsonDecode(tokensString);
    return tokensJson.map((json) => QueueTokenModel.fromMap(json, json['id'])).toList();
  }

  /// Check if data is stale (older than 5 minutes)
  Future<bool> isDataStale() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSync = prefs.getInt(_lastSyncKey);
    
    if (lastSync == null) return true;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = now - lastSync;
    
    return diff > (5 * 60 * 1000); // 5 minutes
  }

  /// Clear offline data
  Future<void> clearOfflineData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokensKey);
    await prefs.remove(_lastSyncKey);
  }

  /// Save a single token for offline queue generation
  Future<void> saveOfflineQueueRequest({
    required String clinicId,
    required String doctorId,
    required String departmentId,
    required String patientId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRequests = prefs.getStringList('pending_queue_requests') ?? [];
    
    final request = jsonEncode({
      'clinicId': clinicId,
      'doctorId': doctorId,
      'departmentId': departmentId,
      'patientId': patientId,
      'timestamp': DateTime.now().toIso8601String(),
    });
    
    pendingRequests.add(request);
    await prefs.setStringList('pending_queue_requests', pendingRequests);
  }

  /// Get pending offline queue requests
  Future<List<Map<String, dynamic>>> getPendingQueueRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final pendingRequests = prefs.getStringList('pending_queue_requests') ?? [];
    
    return pendingRequests.map((r) => jsonDecode(r) as Map<String, dynamic>).toList();
  }

  /// Clear pending queue requests after sync
  Future<void> clearPendingQueueRequests() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_queue_requests');
  }
}
