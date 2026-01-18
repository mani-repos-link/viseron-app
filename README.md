# Viseron Mobile & Android TV App

![Viseron Logo](assets/logo/viseron-logo.svg)

A Flutter application for Android TV and mobile devices that connects to your Viseron NVR instance to view camera feeds and live streams.

**Note:** This is an unofficial community app for Viseron. For the main Viseron NVR project, visit [roflcoopter/viseron](https://github.com/roflcoopter/viseron).

## Features

- Android TV
- Mobile-friendly touch interface
- JWT-based authentication with automatic login
- Live camera snapshot feeds with configurable refresh rates
- Grid view for multiple cameras simultaneously
- Full-screen video player
- HLS video streaming support
- Automatic connection persistence (remember credentials)


## Prerequisites

- Flutter SDK 3.10.7 or higher
- Android Studio or VS Code with Flutter extensions
- A running Viseron instance

## Installation

1. Clone the repository:
```bash
git clone git@github.com:mani-repos-link/viseron-app.git
cd viseron
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For Android/Android TV
flutter run -d android

# For iOS
flutter run -d ios

# Build release APK for Android TV
flutter build apk --release
```

## Configuration

On first launch, enter your Viseron connection details:

- **Host/Ip**: Your Viseron instance URL (e.g., `https://viseron.example.com`)
- **Port**: (Optional) Custom port if not using standard ports
- **Username**: Your Viseron username
- **Password**: Your Viseron password

Credentials are saved locally and you'll be automatically logged in on subsequent app launches.

## Android TV Usage

The app automatically detects Android TV and provides an optimized interface:

- **D-pad Up/Down**: Navigate between fields and buttons
- **OK/Select**: Edit field or activate button
- **Back**: Exit edit mode or return to previous screen

### Navigation

- **Login Screen**: Navigate between Host, Username, Password fields and Connect button. Press OK to edit any field in a dialog.
- **Home Screen**: Navigate between camera cards
- **Grid View**: Navigate between cameras, press OK to view full-screen
- **Player**: Press Back to return to grid view

## Mobile Usage

On mobile devices, the app provides a traditional touch interface:

- **Tap** any field to edit with keyboard
- **Tap Connect** button to login
- **Tap** camera cards to navigate
- Standard mobile gestures throughout

## Architecture

### Key Components

- **ViseronAPI** (`lib/services/viseron_api.dart`): Handles authentication and API requests
- **AppState** (`lib/providers/app_state.dart`): Global state management using Provider
- **LoginScreen** (`lib/screens/login_screen.dart`): Platform detection router
- **LoginScreenTV** (`lib/screens/login_screen_tv.dart`): TV-optimized login with dialog-based editing
- **LoginScreenMobile** (`lib/screens/login_screen_mobile.dart`): Mobile login with standard form
- **HomeScreen** (`lib/screens/home_screen.dart`): Camera grid with thumbnail previews
- **GridViewScreen** (`lib/screens/grid_view_screen.dart`): All cameras live view with staggered loading
- **PlayerScreen** (`lib/screens/player_screen.dart`): Full-screen video player

### Authentication Flow

1. User enters credentials on login screen
2. App sends POST request to `/api/v1/auth/login`
3. Viseron returns JWT split across:
   - Response body: `header.payload`
   - Cookie: `signature_cookie` (signature part)
4. App combines parts into full JWT token
5. Subsequent requests include full JWT in `Authorization: Bearer` header
6. Additional cookies (`static_asset_key`, `_xsrf`) are managed for snapshot access
7. Credentials saved to SharedPreferences for auto-login

### Performance Optimizations

- **Staggered Loading**: Camera initialization is delayed by 500ms per camera to prevent overwhelming the connection
- **Adaptive Refresh Rates**:
  - Single camera view: 200ms (~5 FPS)
  - Grid view: 3 seconds per camera
  - Thumbnails: 5 seconds
- **Error Handling**: Failed cameras retry every 10 seconds without blocking others

## Dependencies

- `flutter`: SDK
- `provider`: State management
- `http`: HTTP client
- `shared_preferences`: Local storage for credentials
- `video_player`: Video playback
- `chewie`: Video player controls
- `google_fonts`: Typography
- `dpad`: Android TV D-pad navigation support

## Building for Production

### Android TV APK

```bash
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### Signing the APK

For production release, configure signing in `android/app/build.gradle`:

```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Troubleshooting

### Authentication Fails

- Verify Viseron instance is accessible from your network
- Check username and password are correct
- Ensure Viseron authentication is enabled
- Check app logs for detailed error messages

### Cameras Not Showing

- Check that the authenticated user has camera access permissions in Viseron
- Verify cameras are configured and online in Viseron
- Check app logs for API errors

### Grid View Shows Only Some Cameras

- This is normal during staggered loading (cameras load 500ms apart)
- If cameras remain blank, check network bandwidth and Viseron server resources

### Video Playback Issues

- Ensure HLS streaming is enabled in Viseron camera configuration
- Check that the camera is recording and accessible
- Verify network connectivity and bandwidth

### Wrong Login Screen on TV

- The app auto-detects platform based on screen size
- TV detection: Android device with landscape orientation and width > 1000 or height > 600
- Check logs for "Platform detection" message to see detected screen size

## Development

### Setting Up Development Environment

1. Install Flutter SDK 3.10.7 or higher
2. Install Android Studio with Flutter and Dart plugins
3. Clone the repository
4. Run `flutter pub get` to install dependencies

### Running on Android TV Wirelessly

You can deploy and debug on Android TV without a USB cable using ADB over network:

#### Enable ADB on your TV

1. On your Android TV, go to **Settings** > **Device Preferences** > **About**
2. Click on **Build** 7 times to enable Developer Options
3. Go back to **Device Preferences** > **Developer options**
4. Enable **USB debugging** and **Network debugging**
5. Note your TV's IP address (Settings > Network & Internet > Your WiFi network)

#### Connect from your computer

```bash
# Make sure your computer and TV are on the same network
# Replace TV_IP_ADDRESS with your TV's actual IP address

# Connect to TV via ADB
adb connect TV_IP_ADDRESS:5555

# Verify connection
adb devices

# You should see your TV listed, e.g.:
# TV_IP_ADDRESS:5555    device

# Now you can run the app wirelessly
flutter run -d TV_IP_ADDRESS:5555

# Or build and install APK
flutter build apk --release
adb -s TV_IP_ADDRESS:5555 install build/app/outputs/flutter-apk/app-release.apk
```

#### Troubleshooting ADB Connection

If connection fails:
```bash
# Disconnect first
adb disconnect TV_IP_ADDRESS:5555

# Restart ADB server
adb kill-server
adb start-server

# Try connecting again
adb connect TV_IP_ADDRESS:5555
```

### Hot Reload on TV

Once connected wirelessly, you can use Flutter's hot reload:
```bash
# Run in debug mode
flutter run -d TV_IP_ADDRESS:5555

# Press 'r' in terminal to hot reload
# Press 'R' in terminal to hot restart
```



## Community & Contributing

This is a **community project** and we welcome contributions from everyone! Whether you're fixing bugs, adding features, improving documentation, or helping other users.

### How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on:
- Setting up development environment
- Reporting bugs and requesting features
- Submitting pull requests
- Code style and standards
- Testing requirements

### Areas That Need Help

We especially welcome contributions for:
- Video player improvements
- Settings screen
- Camera grouping/organization
- Localization/translations
- iOS support
- Documentation and tutorials

### Code of Conduct

This project follows a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold this code.

### Quick Start for Contributors

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/viseron-app.git`
3. Install dependencies: `flutter pub get`
4. Run the app: `flutter run`
5. Make changes and test
6. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed instructions.

## Viseron Community

This app is designed to work with [Viseron](https://github.com/roflcoopter/viseron), an open-source NVR with support for AI object detection.

### Related Projects
- **Viseron NVR**: [roflcoopter/viseron](https://github.com/roflcoopter/viseron) - The main Viseron project
- **Viseron Docs**: [viseron.netlify.app](https://viseron.netlify.app/) - Official documentation

### Community Links
- **Viseron Discord**: Join the community for support and discussions
- **Report Issues**: Use GitHub Issues for bugs and feature requests
- **Discussions**: Use GitHub Discussions for questions and ideas

## Support

- **App Issues**: Open an issue on this repository
- **Viseron Server Issues**: Refer to the main Viseron project
- **General Help**: Join the Viseron community Discord

## Roadmap

Planned features and improvements:
- [ ] Enhanced video player with HLS streaming
- [ ] Settings screen for customization
- [ ] Camera grouping and organization
- [ ] Multi-language support
- [ ] iOS version
- [ ] Motion detection notifications
- [ ] Recording playback

See [Issues](../../issues) for more details and to vote on features.

## License

MIT License - see [LICENSE](LICENSE) file for details

This project is not affiliated with or endorsed by the official Viseron project.

## Acknowledgments

- Built with Flutter for cross-platform support
- Uses the [dpad package](https://pub.dev/packages/dpad) for Android TV navigation
- Designed for the [Viseron NVR system](https://github.com/roflcoopter/viseron)
- Community icon and assets by Viseron project
- Thanks to all contributors!
