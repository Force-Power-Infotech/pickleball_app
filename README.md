# Pickleball Scorer Pro 🏓

A next-generation Flutter app for scoring pickleball matches, featuring a premium metallic sports UI, smooth animations, and advanced match analytics. Designed for players, coaches, and fans who want a visually striking, intuitive, and reliable scoring experience.

---

## ✨ Key Features

### Core Functionality

- **Official Pickleball Scoring**: Only the serving team scores, with support for 11, 18, or 21-point matches.
- **Live Match Timeline**: Point-by-point breakdown with rally details and animated transitions.
- **Undo/Redo**: Instantly correct mistakes with a robust history system.
- **Match Statistics**: View rally percentages, serve streaks, and match duration.
- **Serving Indicators**: Animated paddle icons show who’s serving.
- **Match Sharing**: Export summaries and stats to share with friends or coaches.

### Modern UI/UX

- **Metallic Sports Theme**: Sleek metallic surfaces, chrome gradients, and reflective highlights for a premium look.
- **Vivid Accents**: Neon red, blue, and gold highlights for teams and actions.
- **Responsive Layout**: Optimized for all devices and orientations.
- **Custom Typography**: Orbitron for headers, Barlow for body text.
- **Smooth Animations**: Fast, normal, and slow transitions using `flutter_animate`.
- **Haptic Feedback**: Tactile responses for key actions.
- **Accessibility**: Semantic labels and high-contrast elements.

### Technical Features

- **Local Data Persistence**: Matches are saved and can be resumed anytime.
- **Provider State Management**: Clean, scalable architecture.
- **Comprehensive Error Handling**: Robust user feedback and error recovery.

---

## 🏗️ Project Structure

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
├── providers/        # State management (Provider pattern)
│   └── match_provider.dart
├── services/         # Business logic and data persistence
│   └── storage_service.dart
├── theme/            # App styling and theme configuration
│   └── app_theme.dart
├── utils/            # Utility functions and helpers
└── main.dart         # App entry point
```

---

## 🎨 Design System

- **Metallic Surfaces**: Chrome gradients, brushed metal backgrounds, and reflective highlights.
- **Primary Red**: `#FF3B30` (Team A, main actions)
- **Primary Blue**: `#007AFF` (Team B, secondary actions)
- **Accent Gold**: `#FFD60A` (Highlights, celebrations)
- **Background**: Metallic silver/grey gradients
- **Card Surface**: Polished metallic panels
- **Corner Radius**: 15px (buttons), 20px (cards)
- **Shadows/Glows**: Neon and metallic glows for interactive elements

**Typography**:  
- Headlines: Orbitron (Bold, Futuristic)  
- Body: Barlow (Clean, Readable)  
- Scores: Orbitron (Extra Bold, Large)

**Animation Timing**:  
- Fast: 200ms  
- Normal: 300ms  
- Slow: 500ms

---

## 🏓 Scoring Rules

- Only the serving team can score points.
- Serving team wins rally: +1 point, continues serving.
- Receiving team wins rally: gains serve, no point.
- Match ends when a team reaches the target score (11, 18, or 21).

---

## 📲 Getting Started

### Prerequisites

- Flutter SDK (3.8.1+)
- Dart SDK
- Android Studio or VS Code (with Flutter extensions)
- iOS Simulator or Android Emulator

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

- `provider`: State management
- `flutter_animate`: High-performance animations
- `google_fonts`: Orbitron, Barlow
- `shared_preferences`: Local data persistence
- `intl`: Date/time formatting

---

## 🖥️ Usage Guide

1. **Splash Screen**: Animated metallic logo and loading.
2. **Match Setup**: Enter team names, select target score, choose first server.
3. **Game Scoring**: Tap to score, view live timeline, see serving indicators.
4. **Score Summary**: Toggle timeline for all match events.
5. **End Game**: Winner celebration, detailed stats, and sharing options.

---

## 🧩 Customization

- **Theme**: Edit `/lib/theme/app_theme.dart` for metallic colors, gradients, and fonts.
- **Animations**: Adjust durations and curves in widgets and screens.
- **Persistence**: Modify `/lib/services/storage_service.dart` for custom storage.

---

## 🧪 Testing

Run all tests with:
```bash
flutter test
```

---

## 🛠 Troubleshooting

- **Build errors**: Ensure Flutter and Dart SDKs are up to date.
- **Font issues**: Run `flutter pub get` and check internet connection.
- **Persistence issues**: Clear app data or reinstall.

---

## 🤝 Contributing

We welcome contributions! Please fork the repo, create a feature branch, and submit a pull request. See `CONTRIBUTING.md` for guidelines.

---

## 📄 License

MIT License. See `LICENSE` for details.

---

## 🙏 Credits

- UI Inspiration: Nike Training Club, F1 Mobile App, metallic sports dashboards
- Icons: Material Design Icons
- Fonts: Google Fonts (Orbitron, Barlow)
- Animations: flutter_animate

---

Built with ❤️ for the pickleball community. Enjoy your matches! 🏓
