import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/camera.dart';

class CameraCard extends StatefulWidget {
  final Camera camera;
  final VoidCallback onTap;
  final String snapshotUrl;
  final http.Client client;
  final Map<String, String> headers;

  const CameraCard({
    super.key,
    required this.camera,
    required this.onTap,
    required this.snapshotUrl,
    required this.client,
    required this.headers,
  });

  @override
  State<CameraCard> createState() => _CameraCardState();
}

class _CameraCardState extends State<CameraCard> {
  Timer? _timer;
  Image? _image;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _fetchSnapshot();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _fetchSnapshot();
      }
    });
  }

  Future<void> _fetchSnapshot() async {
    try {
      final url = Uri.parse('${widget.snapshotUrl}?rand=${DateTime.now().millisecondsSinceEpoch}');

      final response = await widget.client.get(url, headers: widget.headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Snapshot request timeout');
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          setState(() {
            _image = Image.memory(
              response.bodyBytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          });
        }
      }
    } catch (e) {
      if (_image == null) {
        print('Exception fetching snapshot for ${widget.camera.name}: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select ||
             event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.gameButtonA)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      onFocusChange: (value) {
        setState(() {
          _isFocused = value;
        });
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: _isFocused
              ? const BorderSide(color: Colors.white, width: 3)
              : BorderSide.none,
        ),
        elevation: _isFocused ? 8 : 2,
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: _image ?? const Center(
                  child: Icon(Icons.videocam, color: Colors.white54, size: 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.camera.name,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}