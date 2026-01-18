import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/camera.dart';
import '../core/exceptions.dart';

class ViseronApi {
  static const String _clientId = "viseron_tv_app";
  static const Duration _timeout = Duration(seconds: 10);

  String? _baseUrl;
  String? _username;
  String? _password;

  http.Client _client;

  ViseronApi({http.Client? client}) : _client = client ?? http.Client();
  http.Client get client => _client;

  String? _jwtHeader;
  String? _jwtPayload;
  String? _xsrfToken;
  final Map<String, String> _cookies = {};

  void setConnectionDetails(String host, int? port, String user, String pass) {
    _client.close();
    _client = http.Client();
    
    _baseUrl = _constructBaseUrl(host, port);
    _username = user;
    _password = pass;
    _clearAuth();
  }

  String _constructBaseUrl(String host, int? port) {
    if (host.startsWith("http://") || host.startsWith("https://")) {
      var url = host;
      if (port != null) url = '$url:$port';
      return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    }
    
    final scheme = (port == 443) ? 'https' : 'http';
    var url = '$scheme://$host';
    if (port != null && port != 80 && port != 443) {
      url = '$url:$port';
    }
    return url;
  }
  
  void _clearAuth() {
    _jwtHeader = null;
    _jwtPayload = null;
    _xsrfToken = null;
    _cookies.clear();
  }

  Map<String, String> get _authHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
    
    if (_jwtHeader != null && _jwtPayload != null) {
      headers['Authorization'] = 'Bearer $_jwtHeader.$_jwtPayload';
    }
    
    if (_xsrfToken != null) {
      headers['X-XSRFToken'] = _xsrfToken!;
    }
    
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }
    
    return headers;
  }

  Future<bool> checkConnection() async {
    try {
      await login();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> login() async {
    if (_baseUrl == null) throw NetworkException('Connection details not set');
    _clearAuth();
    
    try {
      final probeUrl = Uri.parse('$_baseUrl/api/v1/auth/enabled');
      final probeResponse = await _client.get(probeUrl).timeout(_timeout);

      _updateCookies(probeResponse);

      final loginUrl = Uri.parse('$_baseUrl/api/v1/auth/login');
      final body = jsonEncode({
        "username": _username,
        "password": _password,
        "client_id": _clientId
      });
      
      final loginResponse = await _client.post(
        loginUrl,
        headers: _authHeaders,
        body: body
      ).timeout(_timeout);

      _updateCookies(loginResponse);
      
      if (loginResponse.statusCode == 200) {
        final data = jsonDecode(loginResponse.body);
        if (data is Map && data.containsKey('header') && data.containsKey('payload')) {
          _jwtHeader = data['header'];
          _jwtPayload = data['payload'];
          return;
        }
        throw ServerException('Invalid login response format');
      } else if (loginResponse.statusCode == 401 || loginResponse.statusCode == 403) {
        throw AuthException('Invalid credentials', loginResponse.statusCode);
      } else {
        throw ServerException('Login failed', loginResponse.statusCode);
      }
      
    } on SocketException {
      throw NetworkException('Could not connect to server. Check IP/Port.');
    } on http.ClientException {
      throw NetworkException('Network error occurred.');
    } on FormatException {
      throw ServerException('Bad response from server.');
    } catch (e) {
      if (e is ViseronException) rethrow;
      throw NetworkException('Unexpected error: $e');
    }
  }

  Future<List<Camera>> getCameras() async {
    if (_baseUrl == null) throw NetworkException('Not connected');

    if (_jwtHeader == null) {
      await login();
    }
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/api/v1/cameras'), 
        headers: _authHeaders
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<Camera> cameras = [];
        
        if (data is Map<String, dynamic>) {
          data.forEach((key, value) {
             cameras.add(_parseCamera(key, value));
          });
        }
        return cameras;
      } else if (response.statusCode == 401) {
        throw AuthException('Session expired', 401);
      } else {
        throw ServerException('Failed to load cameras', response.statusCode);
      }
    } catch (e) {
      if (e is ViseronException) rethrow;
      throw NetworkException('Error fetching cameras: $e');
    }
  }
  
  Camera _parseCamera(String identifier, dynamic data) {
    if (data is Map<String, dynamic>) {
      data['identifier'] = identifier;
      return Camera.fromJson(data);
    }
    return Camera(
      identifier: identifier,
      name: identifier,
      width: 1920,
      height: 1080,
    );
  }

  void _updateCookies(http.Response response) {
    final setCookie = response.headers['set-cookie'];
    if (setCookie != null) {
      _extractAndStoreCookie(setCookie, '_xsrf');
      _extractAndStoreCookie(setCookie, 'signature_cookie');
      _extractAndStoreCookie(setCookie, 'refresh_token');
      _extractAndStoreCookie(setCookie, 'static_asset_key');
      _extractAndStoreCookie(setCookie, 'user');
    }
  }

  void _extractAndStoreCookie(String allCookies, String name) {
    final pattern = RegExp('$name=([^;,]+)');
    final match = pattern.firstMatch(allCookies);
    if (match != null && match.group(1) != null) {
      _cookies[name] = match.group(1)!;
      if (name == '_xsrf') {
        _xsrfToken = match.group(1)!;
      }
    }
  }

  String getSnapshotUrl(String cameraIdentifier) {
    return '$_baseUrl/api/v1/camera/$cameraIdentifier/snapshot';
  }

  Map<String, String> getCameraHeaders() {
    final headers = <String, String>{};
    if (_cookies.isNotEmpty) {
      headers['Cookie'] = _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    }
    return headers;
  }
}