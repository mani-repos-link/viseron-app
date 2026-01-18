class ConnectionSettings {
  final String host;
  final int port;
  final String username;
  final String password;

  ConnectionSettings({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  String get baseUrl => 'http://$host:$port';
}
