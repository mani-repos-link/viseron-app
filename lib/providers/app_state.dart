import 'package:flutter/foundation.dart';
import '../models/camera.dart';
import '../services/viseron_api.dart';
import '../services/storage_service.dart';
import '../core/exceptions.dart';

class AppState extends ChangeNotifier {
  final ViseronApi _api = ViseronApi();
  final StorageService _storage = StorageService();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Camera> _cameras = [];
  List<Camera> get cameras => _cameras;

  String? _error;
  String? get error => _error;

  ViseronApi get api => _api;

  Future<void> loadSettingsAndConnect() async {
    _setLoading(true);
    _error = null;
    
    try {
      final settings = await _storage.getConnectionDetails();
      if (settings != null) {
        _api.setConnectionDetails(
          settings['host'],
          settings['port'],
          settings['username'],
          settings['password'],
        );
        
        await _api.login();
        _isConnected = true;
        await fetchCameras();
      }
    } catch (e) {
      if (kDebugMode) print('Auto-login failed: $e');
      // Do not set global error on auto-login failure, just stay disconnected
      // The user can try manual login
    } finally {
      _setLoading(false);
    }
  }

  /// returns true if successful, false if failed (error is set in state)
  Future<bool> connect(String host, int? port, String user, String pass) async {
    _setLoading(true);
    _error = null;
    
    try {
      _api.setConnectionDetails(host, port, user, pass);
      await _api.login();
      
      // Save only on success
      await _storage.saveConnectionDetails(host, port, user, pass);
      _isConnected = true;
      await fetchCameras();
      return true;
      
    } on AuthException catch (e) {
      _error = 'Authentication failed: ${e.message}';
    } on NetworkException catch (e) {
      _error = 'Connection error: ${e.message}';
    } on ServerException catch (e) {
      _error = 'Server error: ${e.message}';
    } catch (e) {
      _error = 'Unexpected error: $e';
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> fetchCameras() async {
    try {
      _cameras = await _api.getCameras();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error fetching cameras: $e');
      if (e is AuthException) {
        _isConnected = false;
        _error = 'Session expired. Please log in again.';
      } else {
        _error = 'Failed to load cameras.';
      }
      notifyListeners();
    }
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void logout() {
    _isConnected = false;
    _cameras = [];
    _error = null;
    notifyListeners();
  }
}
