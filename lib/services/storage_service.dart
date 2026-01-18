import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyHost = 'viseron_host';
  static const String _keyPort = 'viseron_port';
  static const String _keyUser = 'viseron_user';
  static const String _keyPass = 'viseron_pass';

  Future<void> saveConnectionDetails(String host, int? port, String user, String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, host);
    if (port != null) {
      await prefs.setInt(_keyPort, port);
    } else {
      await prefs.remove(_keyPort);
    }
    await prefs.setString(_keyUser, user);
    await prefs.setString(_keyPass, pass);
  }

  Future<Map<String, dynamic>?> getConnectionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_keyHost);
    final port = prefs.getInt(_keyPort);
    if (host != null) {
      return {
        'host': host,
        'port': port,
        'username': prefs.getString(_keyUser) ?? '',
        'password': prefs.getString(_keyPass) ?? '',
      };
    }
    return null;
  }
}
