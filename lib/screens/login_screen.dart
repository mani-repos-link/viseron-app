import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'login_screen_mobile.dart';
import 'login_screen_tv.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static bool _isTVPlatform(BuildContext context) {
    if (!Platform.isAndroid) {
      return false;
    }

    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Android TV typically has width > 1000 or aspect ratio close to 16:9 with large screen
    final isLandscape = width > height;
    final isLargeScreen = width > 1000 || height > 600;

    // Most Android TVs are landscape with width > 1000
    // or have large screen dimensions
    return isLandscape && isLargeScreen;
  }

  @override
  Widget build(BuildContext context) {
    final isTV = _isTVPlatform(context);

    if (kDebugMode) {
      print('Platform detection - Width: ${MediaQuery.of(context).size.width}, Height: ${MediaQuery.of(context).size.height}, IsTV: $isTV');
    }

    return isTV ? const LoginScreenTV() : const LoginScreenMobile();
  }
}
