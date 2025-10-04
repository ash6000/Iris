# Voice Mode Setup Instructions

## Required Info.plist Permissions

To enable voice features in the iOS app, you need to add the following permissions to your `Info.plist` file:

### 1. Microphone Usage Description
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to your microphone to record voice messages and enable voice conversations with Iris.</string>
```

### 2. Speech Recognition (Optional - for enhanced features)
```xml
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to provide better voice interaction with Iris.</string>
```

## How to Add These Permissions:

1. Open your project in Xcode
2. Navigate to your app's `Info.plist` file
3. Right-click and select "Open As" > "Source Code"
4. Add the XML entries above inside the `<dict>` tag
5. Save the file

## Alternative Method (Xcode GUI):

1. Open `Info.plist` in Xcode
2. Click the "+" button to add a new row
3. Type "Privacy - Microphone Usage Description"
4. Set the value to: "This app needs access to your microphone to record voice messages and enable voice conversations with Iris."

## Testing Permissions:

After adding the permissions, the app will automatically request microphone access when the user first tries to use voice features. The app includes proper permission handling to guide users through the process.

## Voice Features Available:

- 🎤 **Voice Recording**: Hold to record voice messages
- 🗣️ **Speech-to-Text**: Convert voice to text using OpenAI Whisper
- 🔊 **Text-to-Speech**: Iris responds with voice using OpenAI TTS
- 🎵 **6 Voice Options**: Choose from alloy, echo, fable, onyx, nova, shimmer
- ⚡ **Real-time Visual Feedback**: Waveform animation during recording
- 📱 **Background Handling**: Proper audio session management