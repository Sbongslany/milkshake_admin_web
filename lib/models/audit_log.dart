
import 'dart:convert';

class AuditLog {
  final String id;
  final dynamic user;
  final String action;
  final String entity;
  final DateTime timestamp;
  final List<Map<String, dynamic>> changes;

  AuditLog({
    required this.id,
    this.user,
    required this.action,
    required this.entity,
    required this.timestamp,
    required this.changes,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['_id'] as String,
      user: json['user'],
      action: json['action'] as String,
      entity: json['entity'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      changes: (json['changes'] as List?)?.map((c) => c as Map<String, dynamic>).toList() ?? [],
    );
  }

  String get userName {
    if (user is Map<String, dynamic>) {
      return user['name'] ?? user['email'] ?? 'Unknown User';
    }
    if (user is String && user.isNotEmpty) {
      return 'User ${user.substring(user.length - 6)}';
    }
    return 'System';
  }

  String formatChange(Map<String, dynamic> change) {
    final field = change['field'] as String? ?? 'Unknown';
    final oldValue = _formatValue(change['oldValue']);
    final newValue = _formatValue(change['newValue']);
    return '$field: $oldValue → $newValue';
  }

  String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is Map || value is List) {
      try {
        return const JsonEncoder.withIndent('  ').convert(value);
      } catch (_) {
        return value.toString();
      }
    }
    return value.toString();
  }
}