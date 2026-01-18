import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveCameraView extends StatefulWidget {
  final String snapshotUrl;
  final Map<String, String> headers;
  final Duration refreshInterval;

  const LiveCameraView({
    super.key,
    required this.snapshotUrl,
    this.headers = const {},
    this.refreshInterval = const Duration(milliseconds: 200),
  });

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> {
  Timer? _timer;
  Uint8List? _imageBytes;
  bool _error = false;
  int _requestCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSnapshot();
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _timer?.cancel();
    final interval = _error
        ? const Duration(seconds: 10)
        : widget.refreshInterval;

    _timer = Timer.periodic(interval, (timer) {
      if (mounted) {
        _fetchSnapshot();
      }
    });
  }

  Future<void> _fetchSnapshot() async {
    try {
      final url = '${widget.snapshotUrl}?rand=${DateTime.now().millisecondsSinceEpoch}';

      _requestCount++;

      final response = await http.get(
        Uri.parse(url),
        headers: widget.headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Snapshot request timeout');
        },
      );

      if (response.statusCode == 200 && mounted) {
        final wasError = _error;
        setState(() {
          _imageBytes = response.bodyBytes;
          _error = false;
        });
        if (wasError) {
          _startRefreshTimer();
        }
      } else if (mounted && _imageBytes == null) {
        final wasError = _error;
        setState(() {
          _error = true;
        });
        if (!wasError) {
          _startRefreshTimer();
        }
      }
    } catch (e) {
      if (mounted && _imageBytes == null) {
        final wasError = _error;
        setState(() {
          _error = true;
        });
        if (!wasError) {
          _startRefreshTimer();
        }
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
    if (_error) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                'Error loading camera stream',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_imageBytes == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Image.memory(
      _imageBytes!,
      fit: BoxFit.contain,
      gaplessPlayback: true,
    );
  }
}
