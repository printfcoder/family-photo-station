// Device Discovery Service - Abstract Interface
// English comments as per project rules

import 'dart:convert';

/// Device information model
class DeviceInfo {
  final String id;
  final String name;
  final String type; // 'desktop', 'mobile', 'server'
  final String address; // IP address or hostname
  final int port;
  final Map<String, dynamic> metadata;
  final bool isOnline;
  final DateTime lastSeen;
  
  DeviceInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.port,
    this.metadata = const {},
    this.isOnline = true,
    required this.lastSeen,
  });
  
  // Convert to JSON for serialization
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'address': address,
    'port': port,
    'metadata': metadata,
    'isOnline': isOnline,
    'lastSeen': lastSeen.toIso8601String(),
  };
  
  // Create from JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      address: json['address'],
      port: json['port'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      isOnline: json['isOnline'] ?? true,
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }
}

/// Device discovery status
enum DiscoveryStatus {
  idle,
  scanning,
  discovered,
  error,
  connected,
}

/// Discovery configuration
class DiscoveryConfig {
  final Duration scanTimeout;
  final int maxRetries;
  final bool autoConnect;
  final List<String> preferredDevices;
  
  const DiscoveryConfig({
    this.scanTimeout = const Duration(seconds: 10),
    this.maxRetries = 3,
    this.autoConnect = true,
    this.preferredDevices = const [],
  });
}

/// Abstract device discovery service interface
abstract class DeviceDiscoveryService {
  /// Current discovery status
  DiscoveryStatus get status;
  
  /// List of discovered devices
  List<DeviceInfo> get discoveredDevices;
  
  /// Currently connected device
  DeviceInfo? get connectedDevice;
  
  /// Error message if any
  String get errorMessage;
  
  /// Discovery progress (0.0 to 1.0)
  double? get progress;
  
  /// Initialize the discovery service
  Future<void> initialize();
  
  /// Start device discovery
  Future<void> startDiscovery({DiscoveryConfig? config});
  
  /// Stop device discovery
  Future<void> stopDiscovery();
  
  /// Connect to a specific device
  Future<bool> connectToDevice(DeviceInfo device);
  
  /// Disconnect from current device
  Future<void> disconnect();
  
  /// Get device by ID
  DeviceInfo? getDeviceById(String deviceId);
  
  /// Check if device is reachable
  Future<bool> checkDeviceReachability(DeviceInfo device);
  
  /// Get connection status
  bool get isConnected => connectedDevice != null;
  
  /// Get discovery status
  bool get isScanning => status == DiscoveryStatus.scanning;
  
  /// Get error status
  bool get hasError => status == DiscoveryStatus.error;
}

/// Device connection event
class DeviceConnectionEvent {
  final DeviceInfo device;
  final bool connected;
  final String? error;
  
  DeviceConnectionEvent({
    required this.device,
    required this.connected,
    this.error,
  });
}

/// QR code data model for device connection
class DeviceQRData {
  final String deviceId;
  final String name;
  final String address;
  final int port;
  final String type;
  final Map<String, dynamic> metadata;
  
  DeviceQRData({
    required this.deviceId,
    required this.name,
    required this.address,
    required this.port,
    required this.type,
    this.metadata = const {},
  });
  
  // Convert to JSON string for QR code
  String toJsonString() {
    return '''{
      "deviceId": "$deviceId",
      "name": "$name",
      "address": "$address",
      "port": $port,
      "type": "$type",
      "metadata": ${_encodeMetadata(metadata)}
    }''';
  }
  
  // Create from JSON string
  factory DeviceQRData.fromJsonString(String jsonString) {
    final json = _parseJsonString(jsonString);
    return DeviceQRData(
      deviceId: json['deviceId'],
      name: json['name'],
      address: json['address'],
      port: json['port'],
      type: json['type'],
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }
  
  static Map<String, dynamic> _parseJsonString(String jsonString) {
    // Simple JSON parsing for QR code data
    return jsonString
        .replaceAll('\n', '')
        .replaceAll(' ', '')
        .replaceAll('{"', '{"')
        .replaceAll('":"', '":"')
        .replaceAll('","', '","')
        .replaceAll('"}', '"}')
        .split(',')
        .fold<Map<String, dynamic>>({}, (map, entry) {
          final parts = entry.split(':');
          if (parts.length == 2) {
            final key = parts[0].replaceAll('"', '').replaceAll('{', '');
            var value = parts[1].replaceAll('"', '').replaceAll('}', '');
            
            // Handle different value types
            if (value == 'true' || value == 'false') {
              map[key] = value == 'true';
            } else if (int.tryParse(value) != null) {
              map[key] = int.parse(value);
            } else {
              map[key] = value;
            }
          }
          return map;
        });
  }
  
  static String _encodeMetadata(Map<String, dynamic> metadata) {
    if (metadata.isEmpty) return '{}';
    
    final entries = metadata.entries.map((entry) {
      final value = entry.value is String ? '"${entry.value}"' : entry.value;
      return '"${entry.key}":$value';
    }).join(',');
    
    return '{$entries}';
  }
}