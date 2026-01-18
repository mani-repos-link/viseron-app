import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:dpad/dpad.dart';
import 'providers/app_state.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ViseronApp());
}

class ViseronApp extends StatelessWidget {
  const ViseronApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: DpadNavigator(
        enabled: true,
        child: MaterialApp(
          title: 'Viseron TV',
          theme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.robotoTextTheme(
              Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
            ),
            useMaterial3: true,
            focusColor: Colors.blue.withValues(alpha: 0.4),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Keep the screen on for TV monitoring
    WakelockPlus.enable();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().loadSettingsAndConnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = context.select<AppState, bool>((s) => s.isConnected);
    
    if (isConnected) {
      return const HomeScreen();
    }
    return const LoginScreen();
  }
}
