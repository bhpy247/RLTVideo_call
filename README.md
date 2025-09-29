# Flutter Video Call Application with Agora RTC Engine

A production-ready Flutter video calling application with Agora RTC Engine integration, REST API integration, and offline caching capabilities.

## Features

**Authentication & Login**
- Email and password authentication
- Form validation
- Integration with REST API
- Token-based authentication with SharedPreferences

**Video Calling (Agora RTC Engine)**
- One-to-one video calling
- Join channels with channel names
- Local and remote video streams
- Mute/unmute audio controls
- Enable/disable video controls
- Camera switching (front/back)
- Speaker/earpiece toggle
- Screen sharing capability
- Real-time participant tracking

**User List**
- Fetch users from ReqRes API
- Display users with avatar and name
- Offline caching with Hive
- Pull-to-refresh functionality
- Initiate video calls from user list

**Store-Ready Features**
- Splash screen
- App icon configuration
- Proper permissions handling (Camera, Microphone)
- App versioning
- Orientation change handling
- Background/foreground state management

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Xcode (for iOS development)
- An Agora account (free tier available)

## Installation & Setup

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd videocall
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Generate Required Files

For Hive cache models, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Agora Setup (REQUIRED)

#### Create Agora Account

1. Go to [Agora Console](https://console.agora.io/)
2. Sign up for a free account
3. Create a new project
4. Get your **App ID** from the project dashboard

#### Configure App ID

**Option 1: For Testing (No Token)**

Open `lib/backend/agora/agora_controller.dart` and replace:

```dart
static const String appId = "YOUR_AGORA_APP_ID";
```

With your actual App ID:

```dart
static const String appId = "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6";
```

For testing, you can use Agora without a token server. The free tier supports:
- Up to 10,000 minutes/month
- Testing with channel names
- All features enabled

**Option 2: For Production (With Token Server)**

For production apps, you should implement token authentication:

1. Set up a token server (Node.js/Python/Go) using Agora's token generation libraries
2. Generate tokens dynamically based on user/channel
3. Update the `joinChannel` method to fetch and use tokens

```dart
// Fetch token from your server
// final token = await yourBackendApi.getAgoraToken(
//   channelName: channelName,
//   uid: uid,
// );
//
// await _engine!.joinChannel(
//   token: token,  // Use the generated token
//   channelId: channelName,
//   uid: uid,
//   options: const ChannelMediaOptions(...),
// );
```

### 5. Configure API Endpoints

Update `lib/api/api_endpoints.dart` with your backend URLs:

```dart
class ApiEndpoints {
  static const String baseUrl = "YOUR_BACKEND_URL";
  
  String apiPostLoginDetails() => "$baseUrl/auth/login";
  String apiRegisterUser() => "$baseUrl/auth/register";
  String apiGetUser(String userId) => "$baseUrl/users/$userId";
  String apiUpdateUser(String userId) => "$baseUrl/users/$userId";
}
```

### 6. App Icon Setup

Place your app icons in:
- `assets/icons/app_icon.png` (1024x1024 px)
- `assets/icons/app_icon_foreground.png` (Android adaptive icon)

Generate icons:

```bash
flutter pub run flutter_launcher_icons
```

### 7. Splash Screen Setup

Configure your splash screen in:
- Android: `android/app/src/main/res/drawable/launch_background.xml`
- iOS: `ios/Runner/Assets.xcassets/LaunchImage.imageset/`

## Running the Application

### Android

```bash
flutter run
```

For release build:
```bash
flutter build apk --release
```

For app bundle (Play Store):
```bash
flutter build appbundle --release
```

### iOS

```bash
flutter run
```

For release build:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── api/                          # API layer
│   ├── api_call_model.dart
│   ├── api_controller.dart
│   ├── api_endpoints.dart
│   └── rest_client.dart
├── backend/
│   ├── authentication/           # Authentication logic
│   │   ├── authentication_controller.dart
│   │   ├── authentication_provider.dart
│   │   └── authentication_repository.dart
│   ├── agora/                    # Agora RTC integration (NEW)
│   │   ├── agora_controller.dart
│   │   └── agora_provider.dart
│   ├── user_list/                # User list management (NEW)
│   │   ├── user_list_controller.dart
│   │   ├── user_list_model.dart
│   │   ├── user_list_provider.dart
│   │   └── user_list_repository.dart
│   ├── common/
│   │   └── common_provider.dart
│   └── navigation/
│       └── navigation_controller.dart
├── configs/
│   └── constants.dart
├── models/                       # Data models
│   ├── authentication/
│   ├── user_model/
│   └── common/
├── utils/                        # Utility files
│   ├── permissions_helper.dart   # (NEW)
│   ├── my_print.dart
│   └── parsing_helper.dart
└── views/                        # UI Screens
    ├── authentication/
    │   └── screens/
    │       └── login_screen.dart
    ├── video_call/               # (NEW)
    │   └── video_call_screen.dart
    └── user_list/                # (NEW)
        └── user_list_screen.dart
```

## Configuration Files

### Android

**File**: `android/app/src/main/AndroidManifest.xml`

Required permissions (already configured):
- `INTERNET`
- `CAMERA`
- `RECORD_AUDIO`
- `MODIFY_AUDIO_SETTINGS`
- `ACCESS_NETWORK_STATE`
- `WAKE_LOCK`
- `BLUETOOTH` (optional, for audio routing)

### iOS

**File**: `ios/Runner/Info.plist`

Required usage descriptions (already configured):
- `NSCameraUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSLocalNetworkUsageDescription`

## Testing

### Testing Video Calls

**Method 1: Two Physical Devices (Recommended)**
1. Build and install the app on two devices
2. Log in on both devices
3. Both devices join the same channel name (e.g., "test123")
4. You should see each other's video

**Method 2: One Device + Web Demo**
1. Run your Flutter app on a device
2. Open [Agora Web Demo](https://webdemo.agora.io/basicVideoCall/index.html)
3. Enter your App ID and the same channel name
4. You should see each other's video

**Method 3: Two Emulators (Limited)**
- Android emulator doesn't support camera well
- Use iOS Simulator + physical device
- Or use one emulator + web demo

### Channel Names

Channel names can be anything:
- "test123"
- "meeting-room-1"
- "user1-user2-call"
- Generated unique IDs from your backend

Both participants must use the **exact same channel name** to connect.

## App Signing

### Android

1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-keystore>
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

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

### iOS

1. Open project in Xcode: `open ios/Runner.xcworkspace`
2. Select your development team in Signing & Capabilities
3. Configure signing certificates
4. Set unique bundle identifier

## Assumptions & Limitations

### Assumptions

1. **Testing Mode**: Using App ID without token for testing. For production, implement token server.

2. **ReqRes API**: Using ReqRes.in as a fake REST API for user list demonstration. Replace with your actual API.

3. **Channel Names**: Currently using simple string channel names. In production, manage channels through your backend.

4. **Free Tier**: Assumes usage within Agora's free tier (10,000 minutes/month).

### Limitations

1. **Agora Free Tier**:
    - 10,000 minutes per month
    - After that, paid plans required
    - No custom recording without additional setup

2. **Token Authentication**:
    - Not implemented in basic version
    - Required for production apps
    - Need to set up token server

3. **Group Calls**:
    - Current implementation optimized for 1-on-1 calls
    - Can support multiple participants but UI needs adjustment

4. **Offline Mode**:
    - Only user list supports offline caching
    - Video calls require active internet connection

5. **Platform Support**:
    - Fully tested on Android and iOS
    - Web support available but not configured

6. **Call History**:
    - Not implemented
    - Would require backend database

## Agora Features Used

- [x] Video calling (one-to-one)
- [x] Audio muting/unmuting
- [x] Video enable/disable
- [x] Camera switching
- [x] Speaker/earpiece toggle
- [x] Screen sharing
- [x] Participant tracking
- [ ] Recording (requires setup)
- [ ] Beauty filters (available but not implemented)
- [ ] Virtual backgrounds (available but not implemented)

## Store Submission Checklist

### Android (Play Store)

- [x] App icon configured
- [x] Splash screen implemented
- [x] All required permissions declared
- [x] App versioning set up
- [x] ProGuard rules configured
- [ ] Signed APK/App Bundle generated
- [ ] Privacy policy URL (add yours)
- [ ] Store listing prepared

### iOS (App Store)

- [x] App icon configured
- [x] Launch screen implemented
- [x] All usage descriptions provided
- [x] App versioning set up
- [x] Background modes configured
- [ ] Signed IPA generated
- [ ] Privacy policy URL (add yours)
- [ ] Store listing prepared

## Troubleshooting

### Common Issues

**Issue**: "Please set your Agora App ID" error
**Solution**: Open `lib/backend/agora/agora_controller.dart` and set your App ID

**Issue**: Video doesn't show
**Solution**:
- Check permissions are granted
- Verify App ID is correct
- Ensure both devices use the same channel name
- Check internet connection

**Issue**: Can't hear audio
**Solution**:
- Check microphone permission
- Unmute your microphone
- Check speaker/earpiece setting
- Ensure volume is up

**Issue**: Build fails with Hive errors
**Solution**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Issue**: App crashes on orientation change
**Solution**: Lifecycle is properly handled, but ensure no lingering state issues

**Issue**: Screen sharing doesn't work
**Solution**:
- Android: Requires Android 21+
- iOS: Requires iOS 12+
- May need additional permissions

## Dependencies

Key dependencies used:
- `agora_rtc_engine: ^6.3.0` - Video calling SDK
- `shared_preferences: ^2.2.2` - Local storage
- `hive: ^2.2.3` - Offline caching
- `permission_handler: ^11.1.0` - Permissions
- `cached_network_image: ^3.3.0` - Image caching
- `provider: ^6.1.1` - State management

See `pubspec.yaml` for complete list.

## Performance Optimization

- Use `const` constructors where possible
- Implement lazy loading for user lists
- Cache network images
- Dispose controllers properly
- Use `ListView.builder` for large lists
- Enable ProGuard/R8 for release builds

## Security Considerations

1. **Never commit**:
    - Agora App ID (use environment variables in production)
    - API keys
    - Signing keys
    - Backend URLs with credentials

2. **For Production**:
    - Implement token-based authentication
    - Use HTTPS for all API calls
    - Implement SSL pinning
    - Add ProGuard rules for Android
    - Obfuscate code

3. **Privacy**:
    - Add privacy policy
    - Clearly explain data collection
    - Get user consent for camera/microphone
    - Comply with GDPR/CCPA if applicable

## Cost Estimation

### Agora Pricing (as of 2024)

**Free Tier:**
- 10,000 minutes/month free
- Suitable for testing and small apps

**Paid Plans:**
- Audio: $0.99 per 1,000 minutes
- Video SD: $3.99 per 1,000 minutes
- Video HD: $8.99 per 1,000 minutes
- Screen sharing: $1.99 per 1,000 minutes

Calculate your costs at: https://www.agora.io/en/pricing/

## Future Enhancements

- [ ] Group video calls (3+ participants)
- [ ] Chat functionality during calls
- [ ] Call recording
- [ ] Virtual backgrounds
- [ ] Beauty filters
- [ ] Noise cancellation
- [ ] Picture-in-picture mode
- [ ] Call history with local database
- [ ] Push notifications for incoming calls
- [ ] In-app messaging
- [ ] Call quality statistics
- [ ] Network quality indicators

## Resources

- [Agora Documentation](https://docs.agora.io/)
- [Flutter Plugin Documentation](https://docs.agora.io/en/video-calling/get-started/get-started-sdk)
- [API Reference](https://api-ref.agora.io/en/voice-sdk/flutter/6.x/API/rtc_api_overview.html)
- [Sample Projects](https://github.com/AgoraIO-Extensions/Agora-Flutter-SDK)
- [Community Forum](https://www.agora.io/en/community/)

## Support

For issues and questions:
- Check the troubleshooting section
- Review Agora documentation
- Visit Agora community forum
- Open an issue in the repository

## License

[Add your license here]

## Contributors

[Add contributors here]

---

**Note**: This application is ready for store submission after you:
1. Set your Agora App ID
2. Configure your backend API
3. Add app icons
4. Sign the app
5. Create store listing materials
6. Add privacy policy

For production use, implement proper security measures, token authentication, and follow platform-specific guidelines.