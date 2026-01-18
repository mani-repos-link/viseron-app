import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../models/camera.dart';
import '../providers/app_state.dart';
import '../widgets/live_camera_view.dart';

class PlayerScreen extends StatelessWidget {
  final Camera camera;
  final http.Client client;

  const PlayerScreen({
    super.key,
    required this.camera,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    final api = context.read<AppState>().api;
    final snapshotUrl = api.getSnapshotUrl(camera.identifier);
    final headers = api.getCameraHeaders();

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.escape ||
             event.logicalKey == LogicalKeyboardKey.backspace)) {
          Navigator.of(context).pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(camera.name),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: LiveCameraView(
            snapshotUrl: snapshotUrl,
            headers: headers,
          ),
        ),
      ),
    );
  }
}
