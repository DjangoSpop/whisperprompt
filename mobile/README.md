# AI Whisperer - Flutter Mobile App

Voice-powered AI prompt generation app. Speak your prompts instead of typing them!

## Features

- 🎤 **Voice Input**: Record voice for template variables
- 📋 **8 MVP Templates**: Pre-built templates across 5 categories
- 📊 **History Tracking**: Save and favorite your prompts
- 🔊 **Text-to-Speech**: Listen to generated prompts
- 🎨 **Beautiful UI**: Modern, professional design with smooth animations
- 🔐 **Secure**: JWT authentication with secure storage

## Screenshots

[Screenshots will be added here]

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode for device deployment
- Backend API running (see backend/README.md)

### Installation

1. **Clone the repository**
   ```bash
   cd mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configure API endpoint**

   Edit `lib/config/api_config.dart`:
   ```dart
   static const String devBaseUrl = 'http://YOUR_IP:8000';
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── config/              # Configuration files
│   ├── api_config.dart  # API endpoints
│   └── theme.dart       # App theme & colors
├── models/              # Data models
│   ├── user.dart
│   ├── template.dart
│   ├── session.dart
│   └── history.dart
├── services/            # Services layer
│   ├── api_service.dart     # API communication
│   ├── storage_service.dart # Local storage
│   ├── voice_service.dart   # Voice recording
│   └── tts_service.dart     # Text-to-speech
├── screens/             # UI screens
│   ├── splash/
│   ├── auth/
│   ├── home/
│   ├── templates/
│   ├── session/
│   ├── history/
│   └── profile/
├── widgets/             # Reusable widgets
├── app.dart             # App configuration
└── main.dart            # App entry point
```

## Design System

### Colors

- **Primary**: #6366F1 (Indigo)
- **Secondary**: #EC4899 (Pink)
- **Success**: #10B981 (Green)
- **Error**: #EF4444 (Red)

### Typography

- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular, Medium, SemiBold, Bold

### Spacing

- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- XXL: 48px

## State Management

This app uses **Riverpod** for state management:

```dart
// Example provider
final userProvider = FutureProvider<User>((ref) async {
  final storage = ref.read(storageServiceProvider);
  final apiService = ApiService(storage);
  return await apiService.getProfile();
});
```

## API Integration

### Authentication

```dart
// Login
final tokens = await apiService.login(
  username: 'testuser',
  password: 'password123',
);

// The tokens are automatically saved to secure storage
```

### Creating a Session

```dart
// 1. Create session with template
final session = await apiService.createSession('email-writer');

// 2. Upload voice for each variable
final voiceInput = await apiService.uploadVoice(
  sessionId: session.id,
  variableName: 'topic',
  audioFilePath: recordingPath,
);

// 3. Generate prompt
final result = await apiService.generatePrompt(session.id);
```

## Voice Recording

```dart
final voiceService = VoiceService();

// Start recording
await voiceService.startRecording();

// Stop and get file path
final path = await voiceService.stopRecording();

// Upload to API
await apiService.uploadVoice(
  sessionId: sessionId,
  variableName: 'topic',
  audioFilePath: path,
);
```

## Text-to-Speech

```dart
final ttsService = ref.read(ttsServiceProvider);

// Speak text
await ttsService.speak('Your generated prompt here...');

// Stop speaking
await ttsService.stop();

// Adjust rate
await ttsService.setSpeechRate(0.5); // 0.0 to 1.0
```

## Building for Production

### Android

```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Permissions

### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>We need microphone access to record your voice for prompt generation</string>
```

## Dependencies

### Core
- `flutter_riverpod` - State management
- `dio` - HTTP client
- `hive` - Local database

### UI/UX
- `google_fonts` - Typography
- `flutter_animate` - Animations
- `shimmer` - Loading states

### Features
- `record` - Voice recording
- `flutter_tts` - Text-to-speech
- `flutter_secure_storage` - Secure token storage
- `share_plus` - Sharing functionality

## Troubleshooting

### "Failed to connect to API"

1. Check backend is running
2. Verify API URL in `api_config.dart`
3. For Android emulator, use `10.0.2.2` instead of `localhost`
4. For iOS simulator, use `localhost` or your machine's IP

### "Microphone permission denied"

1. Check permissions in AndroidManifest.xml / Info.plist
2. Request permissions at runtime
3. Check device settings

### "Build failed"

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## Performance Tips

1. **Image Optimization**: Use `cached_network_image` for remote images
2. **List Performance**: Use `ListView.builder` for long lists
3. **State Management**: Keep providers focused and granular
4. **Animations**: Use `AnimatedWidget` for simple animations

## Future Enhancements

- [ ] Custom template creation
- [ ] Offline mode with sync
- [ ] Dark mode support
- [ ] Multiple language support
- [ ] Advanced voice settings
- [ ] Prompt editing before save
- [ ] Team collaboration features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## License

MIT License - See LICENSE file for details

---

**Built with ❤️ using Flutter**

For backend documentation, see `backend/README.md`
