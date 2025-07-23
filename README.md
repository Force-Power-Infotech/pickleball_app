# Pickleball Scorer Pro 🏓

A state-of-the-art Flutter mobile application for scoring pickleball matches with modern, animated UI inspired by professional sports apps like Nike Training Club and F1.

## ✨ Features

### Core Functionality
- **Professional Pickleball Scoring**: Implements official pickleball rules where only the serving team can score points
- **Live Match Timeline**: Real-time point-by-point breakdown with detailed rally information
- **Multiple Game Modes**: Support for 11, 18, or 21 point matches
- **Undo/Redo Functionality**: Easily correct scoring mistakes
- **Match Statistics**: Comprehensive analytics including rally win percentages and match duration

### Modern UI/UX
- **Dark Sports Theme**: Sleek dark interface with neon red/blue accents and gold highlights
- **Smooth Animations**: Performance-optimized transitions using flutter_animate
- **Split-Screen Layout**: Dedicated team areas with large, readable scores
- **Serving Indicators**: Animated paddle icons show which team is currently serving
- **Responsive Design**: Optimized for all screen sizes and orientations

### Technical Features
- **Local Data Persistence**: Matches are automatically saved and can be resumed
- **State Management**: Clean architecture using Provider pattern
- **Modern Typography**: Orbitron and Barlow fonts for a professional sports aesthetic
- **Haptic Feedback**: Tactile responses for button interactions
- **Match Sharing**: Export match summaries and statistics

## 🏗 Architecture

### Project Structure
```
lib/
├── models/           # Data models (Match, ScorePoint, ServingTeam)
├── screens/          # UI screens (Splash, Setup, Scoring, Summary)
│   ├── splash_screen.dart
│   ├── match_setup_screen.dart
│   ├── game_scoring_screen.dart
│   └── end_game_summary_screen.dart
├── widgets/          # Reusable UI components
│   ├── animated_button.dart
│   ├── custom_text_field.dart
│   └── score_summary_panel.dart
├── providers/        # State management
│   └── match_provider.dart
├── services/         # Business logic and data persistence
│   └── storage_service.dart
├── theme/           # App styling and theme configuration
│   └── app_theme.dart
└── main.dart        # App entry point
```

### Design Patterns
- **Provider Pattern**: For state management and dependency injection
- **Repository Pattern**: Clean separation of data access logic
- **Widget Composition**: Modular, reusable UI components
- **Animation Controllers**: Managed lifecycle for smooth transitions

## 🎯 Screen Flow

1. **Splash Screen**: Animated intro with logo fade-in and loading
2. **Match Setup Screen**: Configure teams, target score (11/18/21), and first serving team
3. **Game Scoring Screen**: Live scoring with split layout and serving indicators
4. **Score Summary Panel**: Toggleable timeline view of all match events
5. **End Game Summary**: Winner celebration with detailed match statistics

## 🏓 Pickleball Scoring Rules

The app implements official pickleball scoring rules:

- **Only the serving team can score points**
- **Serving team wins rally**: Gets 1 point and continues serving
- **Receiving team wins rally**: Gets the serve but no point is awarded
- **Match ends**: When a team reaches the target score (11, 18, or 21)

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/pickleball_app.git
   cd pickleball_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Dependencies
- **provider**: State management
- **flutter_animate**: High-performance animations
- **google_fonts**: Typography (Orbitron, Barlow)
- **shared_preferences**: Local data persistence
- **intl**: Date/time formatting

## 🎨 Design System

### Color Palette
- **Primary Red**: #FF3B30 (Team A, Primary actions)
- **Primary Blue**: #007AFF (Team B, Secondary actions)
- **Accent Gold**: #FFD60A (Highlights, Celebrations)
- **Dark Background**: #0A0A0A (Main background)
- **Card Surface**: #1C1C1E (Card backgrounds)

### Typography
- **Headlines**: Orbitron (Bold, Futuristic)
- **Body Text**: Barlow (Clean, Readable)
- **Scores**: Orbitron (Extra Bold, Large)

### Animation Timing
- **Fast**: 200ms (Button interactions)
- **Normal**: 300ms (Screen transitions)
- **Slow**: 500ms (Complex animations)

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📱 Platform Support

- ✅ **Android**: API 21+ (Android 5.0+)
- ✅ **iOS**: iOS 12.0+
- 🚧 **Web**: Planned for future release
- 🚧 **Desktop**: Planned for future release

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests for any improvements.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏆 Credits

- **UI Inspiration**: Nike Training Club, F1 Mobile App
- **Icons**: Material Design Icons
- **Fonts**: Google Fonts (Orbitron, Barlow)
- **Animation Framework**: flutter_animate

---

Built with ❤️ for the pickleball community. Enjoy your matches! 🏓
