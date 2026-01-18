class Camera {
  final String identifier;
  final String name;
  final int width;
  final int height;
  final String? accessToken;

  Camera({
    required this.identifier,
    required this.name,
    required this.width,
    required this.height,
    this.accessToken,
  });

  factory Camera.fromJson(Map<String, dynamic> json) {
    return Camera(
      identifier: json['identifier'] ?? 'unknown',
      name: json['name'] ?? 'Unknown Camera',
      width: json['width'] ?? 1920,
      height: json['height'] ?? 1080,
      accessToken: json['access_token'],
    );
  }
}
