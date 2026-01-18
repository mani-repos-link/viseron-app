import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/camera.dart';
import '../widgets/camera_card.dart';
import 'player_screen.dart';
import 'grid_view_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cameras = context.select<AppState, List<Camera>>((s) => s.cameras);
    final api = context.read<AppState>().api;
    final client = api.client;
    final headers = api.getCameraHeaders();

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Viseron?'),
            content: const Text('Are you sure you want to exit the application?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );
        if (shouldExit ?? false) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Viseron Cameras'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<AppState>().fetchCameras(),
            ),
            IconButton(
              icon: const Icon(Icons.grid_on),
              tooltip: 'Grid View',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GridViewScreen(cameras: cameras),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AppState>().logout(),
            ),
          ],
        ),
        body: cameras.isEmpty
            ? const Center(child: Text('No cameras found. Check connection or config.'))
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  childAspectRatio: 16 / 9,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: cameras.length,
                itemBuilder: (context, index) {
                  final camera = cameras[index];
                  return CameraCard(
                    camera: camera,
                    snapshotUrl: api.getSnapshotUrl(camera.identifier),
                    client: client,
                    headers: headers,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayerScreen(
                            camera: camera,
                            client: client, // Pass client to player
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}