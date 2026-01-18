import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/camera.dart';
import '../providers/app_state.dart';
import '../widgets/live_camera_view.dart';
import 'player_screen.dart';

class GridViewScreen extends StatelessWidget {
  final List<Camera> cameras;

  const GridViewScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    final api = context.read<AppState>().api;
    final headers = api.getCameraHeaders();
    final client = api.client;

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
          title: const Text('All Cameras'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 16 / 9,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: cameras.length,
        itemBuilder: (context, index) {
          final camera = cameras[index];
          final snapshotUrl = api.getSnapshotUrl(camera.identifier);

          return Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  (event.logicalKey == LogicalKeyboardKey.select ||
                   event.logicalKey == LogicalKeyboardKey.enter ||
                   event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerScreen(
                      camera: camera,
                      client: client,
                    ),
                  ),
                );
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: Builder(
              builder: (context) {
                final isFocused = Focus.of(context).hasFocus;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(
                          camera: camera,
                          client: client,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: isFocused
                          ? Border.all(color: Colors.white, width: 4)
                          : null,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _StaggeredLiveCameraView(
                          snapshotUrl: snapshotUrl,
                          headers: headers,
                          delayMilliseconds: index * 500,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              camera.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    color: Colors.black,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }
}

class _StaggeredLiveCameraView extends StatefulWidget {
  final String snapshotUrl;
  final Map<String, String> headers;
  final int delayMilliseconds;

  const _StaggeredLiveCameraView({
    required this.snapshotUrl,
    required this.headers,
    required this.delayMilliseconds,
  });

  @override
  State<_StaggeredLiveCameraView> createState() => _StaggeredLiveCameraViewState();
}

class _StaggeredLiveCameraViewState extends State<_StaggeredLiveCameraView> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMilliseconds), () {
      if (mounted) {
        setState(() {
          _ready = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return LiveCameraView(
      snapshotUrl: widget.snapshotUrl,
      headers: widget.headers,
      refreshInterval: const Duration(seconds: 3),
    );
  }
}
