// Device Discovery Controller
// English comments as per project rules

import 'package:family_photo_mobile/core/services/device_discovery_service.dart';
import 'package:family_photo_mobile/core/services/lan_device_discovery_service.dart';

/// Controller for managing device discovery and connection
class DeviceDiscoveryController {
  late DeviceDiscoveryService _discoveryService;
  
  // UI state
  bool _isInitialized = false;
  bool _showConnectionGuide = false;
  String _selectedDeviceId = '';
  
  DeviceDiscoveryController() {
    _initializeDiscoveryService();
  }
  
  void dispose() {
    _discoveryService.disconnect();
  }
  
  /// Initialize the discovery service
  Future<void> _initializeDiscoveryService() async {
    try {
      // Create appropriate discovery service
      _discoveryService = LanDeviceDiscoveryService();
      
      // Initialize the service
      await _discoveryService.initialize();
      _isInitialized = true;
      
      // Check for previously connected device
      await _checkForPreviousConnection();
      
    } catch (e) {
      // Handle initialization error
      print('Initialization failed: ${e.toString()}');
    }
  }
  
  /// Start device discovery
  Future<void> startDiscovery() async {
    if (!_isInitialized) {
      await _initializeDiscoveryService();
    }
    
    await _discoveryService.startDiscovery();
  }
  
  /// Stop device discovery
  Future<void> stopDiscovery() async {
    await _discoveryService.stopDiscovery();
  }
  
  /// Connect to a device using QR code data
  Future<bool> connectWithQRCode(String qrData) async {
    try {
      final qrInfo = DeviceQRData.fromJsonString(qrData);
      
      // Create device info from QR data
      final device = DeviceInfo(
        id: qrInfo.deviceId,
        name: qrInfo.name,
        type: qrInfo.type,
        address: qrInfo.address,
        port: qrInfo.port,
        metadata: qrInfo.metadata,
        lastSeen: DateTime.now(),
      );
      
      // Connect to the device
      return await _discoveryService.connectToDevice(device);
      
    } catch (e) {
      print('QR code connection failed: ${e.toString()}');
      return false;
    }
  }
  
  /// Connect to a specific device
  Future<bool> connectToDevice(String deviceId) async {
    final device = _discoveryService.getDeviceById(deviceId);
    if (device == null) {
      print('Device not found');
      return false;
    }
    
    _selectedDeviceId = deviceId;
    return await _discoveryService.connectToDevice(device);
  }
  
  /// Disconnect from current device
  Future<void> disconnect() async {
    _selectedDeviceId = '';
    await _discoveryService.disconnect();
  }
  
  /// Manual connection with IP address
  Future<bool> connectManually(String ipAddress, int port) async {
    try {
      final device = DeviceInfo(
        id: 'manual-$ipAddress',
        name: 'Manual Connection',
        type: 'desktop',
        address: ipAddress,
        port: port,
        metadata: {'connectionType': 'manual'},
        lastSeen: DateTime.now(),
      );
      
      return await _discoveryService.connectToDevice(device);
      
    } catch (e) {
      print('Manual connection failed: ${e.toString()}');
      return false;
    }
  }
  
  /// Check for previously connected device and auto-reconnect
  Future<void> _checkForPreviousConnection() async {
    // This would check local storage for last connected device
    // For now, we'll skip this functionality
    print('Auto-reconnect functionality not implemented yet');
  }
  
  Map<String, dynamic> _parseDeviceJson(String jsonString) {
    // Simple JSON parsing for device data
    return jsonString
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
  
  /// Show connection guide
  void showConnectionGuide() {
    _showConnectionGuide = true;
  }
  
  /// Hide connection guide
  void hideConnectionGuide() {
    _showConnectionGuide = false;
  }
  
  /// Clear error message
  void clearError() {
    // Error message is read-only from service
  }
  
  // Getters for UI
  DiscoveryStatus get discoveryStatus => _discoveryService.status;
  List<DeviceInfo> get discoveredDevices => _discoveryService.discoveredDevices;
  DeviceInfo? get connectedDevice => _discoveryService.connectedDevice;
  String get errorMessage => _discoveryService.errorMessage;
  double? get discoveryProgress => _discoveryService.progress;
  bool get isInitialized => _isInitialized;
  bool get showConnectionGuide => _showConnectionGuide;
  String get selectedDeviceId => _selectedDeviceId;
  bool get isConnected => _discoveryService.isConnected;
  bool get isScanning => _discoveryService.isScanning;
  bool get hasError => _discoveryService.hasError;
}