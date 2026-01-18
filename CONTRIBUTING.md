# Contributing to Viseron App

Thank you for your interest in contributing to the Viseron mobile and Android TV app! This document provides guidelines and information for contributors.

## About This Project

This is a community-driven Flutter application that provides a mobile and Android TV interface for viewing cameras from Viseron NVR instances. The app is designed to work alongside the main Viseron project.

## Getting Started

### Prerequisites

- Flutter SDK 3.10.7 or higher
- Android Studio or VS Code with Flutter extensions
- A running Viseron instance for testing
- Basic knowledge of Flutter/Dart

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/viseron-app.git
   cd viseron
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Run the app:
   ```bash
   flutter run
   ```

### Testing on Android TV

See the README for instructions on connecting to Android TV wirelessly via ADB.

## How to Contribute

### Reporting Bugs

Before creating a bug report:
- Check existing issues to avoid duplicates
- Test on the latest version
- Gather relevant information (device, Android version, logs)

Create a detailed bug report including:
- Steps to reproduce
- Expected behavior
- Actual behavior
- Device information
- Screenshots if applicable
- Error logs

### Suggesting Features

Feature requests are welcome! Please:
- Check if the feature has already been requested
- Describe the feature and its benefits

### Pull Requests

1. **Create an Issue First**: Discuss major changes before coding
2. **Fork & Branch**: Create a feature branch from `main`
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Code**: Follow the coding standards below
4. **Test**: Test on both mobile and TV if possible
5. **Commit**: Use clear commit messages
   ```bash
   git commit -m "Add feature: camera zoom support"
   ```
6. **Push**: Push to your fork
   ```bash
   git push origin feature/amazing-feature
   ```
7. **Pull Request**: Open a PR with clear description

### Coding Standards

#### Flutter/Dart Style
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter analyze` to check for issues
- Format code with `flutter format .`

#### Code Organization
- Keep widgets small and focused
- Separate business logic from UI
- Use providers for state management
- Add comments for complex logic only

#### Platform Considerations
- **TV Navigation**: All interactive elements must work with D-pad or navigatble
- **Mobile Touch**: All features must work with touch input/tap
- **Responsive Design**: Support different screen sizes
- **Platform Detection**: Use the existing platform detection system

#### Testing Requirements
- Test on Android mobile
- Test on Android TV if changes affect TV UI
- Ensure auto-login works
- Test with multiple cameras
- Test error scenarios (server down, wrong credentials)

### Areas That Need Help

We especially welcome contributions in these areas:

#### High Priority
- [ ] Video player improvements (better HLS support)
- [ ] Offline camera detection and error handling
- [ ] Settings screen (refresh rates, quality options)
- [ ] Camera grouping/organization
- [ ] Search/filter cameras
- [ ] Performance optimizations for many cameras

#### Medium Priority
- [ ] Localization/translations
- [ ] Dark/light theme support
- [ ] Camera controls (PTZ if supported by Viseron)
- [ ] Notification support
- [ ] Motion detection indicators
- [ ] Recording playback
- [ ] Screenshot/snapshot save

#### Nice to Have
- [ ] iOS support
- [ ] Tablet-optimized layouts
- [ ] Picture-in-picture mode
- [ ] Widget for home screen/notifications on wear os?

### Documentation

Help improve documentation:
- Update README if you add features
- Update CONTRIBUTING.md if process changes
- Create or update screenshots
- Write tutorials or guides

## Code Review Process

1. Maintainers will review your PR
2. Address any requested changes
3. Once approved, it will be merged
4. Your contribution will be credited

## Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Focus on constructive feedback
- Give credit where due
- Follow the [Code of Conduct](CODE_OF_CONDUCT.md)

## Building for Release

### For Testing (Debug Build)
```bash
flutter build apk --debug
```

### For Production (Release Build)
```bash
flutter build apk --release
```

Or App Bundle for Play Store:
```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── core/
│   └── exceptions.dart           # Custom exception classes
├── models/
│   ├── camera.dart               # Camera data model
│   └── connection_settings.dart  # Connection settings model
├── providers/
│   └── app_state.dart            # Global app state management
├── screens/
│   ├── login_screen.dart         # Platform detection router
│   ├── login_screen_mobile.dart  # Mobile login UI
│   ├── login_screen_tv.dart      # TV login UI with dialogs
│   ├── home_screen.dart          # Main camera grid
│   ├── grid_view_screen.dart     # Multi-camera live view
│   └── player_screen.dart        # Full-screen camera
├── services/
│   ├── viseron_api.dart          # Viseron API client
│   └── storage_service.dart      # Local storage wrapper
├── widgets/
│   ├── camera_card.dart          # Camera thumbnail widget
│   └── live_camera_view.dart     # Live snapshot view
└── main.dart                     # App entry point
```

## Architecture Decisions

### Why Flutter?
- Cross-platform (Android, iOS, TV)
- Fast development
- Native performance

### Why Dual Login Screens?
- TV navigation requires different UX
- Touch vs D-pad input needs different approaches
- Automatic platform detection provides best experience

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Create an Issue
- **Chat**: Join the Viseron Discord/community channels
- **Docs**: Check the README and code comments

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be:
- Listed in the README
- Credited in release notes
- Appreciated by the community!
