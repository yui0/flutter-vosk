# ✨ AiMemo: Your Intelligent Audio Assistant ✨

Welcome to **AiMemo**! This Flutter app leverages the power of Vosk speech recognition to provide seamless audio transcription and file processing capabilities. With support for multiple models and real-time recognition, you can unlock the potential of AI-driven speech services effortlessly.

---

## 📚 Features

- ✨ **Real-time Speech Recognition**: Recognize and transcribe audio in real-time.
- 🔗 **Multi-Model Support**: Choose from a variety of Vosk models for accurate recognition.
- 🎤 **Record Audio**: Start and stop audio recording directly from the app.
- 💾 **File Upload & Recognition**: Upload audio files for quick transcription.
- ✅ **FFmpeg Integration**: Converts files to PCM format for smooth processing.
- ✨ **Intuitive Interface**: Easy-to-use design for effortless navigation.

---

## 📚 How to Install

1. 🔹 Ensure you have Flutter installed. Refer to the [Flutter installation guide](https://flutter.dev/docs/get-started/install).
2. 🔹 Clone this repository:
   ```bash
   git clone https://github.com/yui0/flutter-vosk
   ```
3. 🔹 Navigate to the project directory:
   ```bash
   cd flutter-vosk
   ```
4. 🔹 Install dependencies:
   ```bash
   flutter pub get
   ```
5. 🏢 Run the app:
   ```bash
   flutter run
   ```

---

## 🎤 Usage Guide

### 🔄 Model Initialization
1. Select a Vosk model from the dropdown menu.
2. The app will load the model and initialize the recognizer.

### 🎧 Real-Time Recognition
1. 🔊 Press the "Start Recognition" button to begin.
2. 🎤 Speak into your device and view partial and final results on the screen.
3. ⏹ Press "Stop Recognition" to end the session.

### 💾 File Upload & Recognition
1. 🗎 Upload an audio file using the "Upload and Recognize Audio" button.
2. ⚪ The app converts the file to PCM format using FFmpeg.
3. 🗞️ View the transcription results on the main screen.

---

## ⚙️ Requirements

- Flutter
- Linux or Android/iOS device or emulator
- FFmpeg for file processing

---

## ⚡ Troubleshooting

- ⚠ If the app displays "Error," verify that:
  - FFmpeg is properly initialized.
  - The selected model is available and correctly loaded.
- 🚫 For Linux users, ensure `ffmepg` is installed for recording.

---

## 🌐 Contributing

We welcome contributions! Feel free to:
- 🌈 Submit bug reports.
- 🔧 Suggest new features.
- ✨ Open pull requests with your enhancements.

---

## ❤️ Credits

Built with 💖 by [Yuichiro Nakada/Berry Japan LLC]. Powered by:
- 📷 Flutter
- ⚡ Vosk
- 🎤 Record Plugin
- 🎥 FFmpeg Helper

---

## 🔗 License

This project is licensed under the MIT License. See the `LICENSE` file for details.

Enjoy using **AiMemo**! 🌟

## 📖 References

- https://www.narakeet.com/app/text-to-audio/
- https://zenn.dev/itsuki9180/articles/f0f5e409a9c808
