<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# Pickleball Scorer App - Copilot Instructions

This is a state-of-the-art Flutter mobile application for scoring pickleball matches with modern, animated UI components.

## Project Structure

- `/lib/models/` - Data models (Match, ScorePoint, ServingTeam)
- `/lib/screens/` - UI screens (Splash, Setup, Scoring, Summary)
- `/lib/widgets/` - Reusable UI components 
- `/lib/providers/` - State management with Provider pattern
- `/lib/services/` - Business logic and data persistence
- `/lib/theme/` - App styling and theme configuration
- `/lib/utils/` - Utility functions and helpers

## Key Design Principles

1. **Modern Sports UI**: Dark theme with neon red/blue accents, inspired by professional sports apps
2. **Smooth Animations**: Use flutter_animate for performance-optimized transitions
3. **Clean Architecture**: Separate concerns with proper layering
4. **Responsive Design**: Support all screen sizes and orientations
5. **Accessibility**: Proper semantic labels and contrast ratios

## Coding Standards

- Use Provider for state management
- Implement proper error handling
- Add comprehensive documentation
- Follow Flutter/Dart naming conventions
- Use const constructors where possible
- Implement proper disposal of controllers

## UI/UX Guidelines

- Primary colors: Red (#FF3B30), Blue (#007AFF), Gold (#FFD60A)
- Typography: Orbitron for headers, Barlow for body text
- Animations: 200ms fast, 300ms normal, 500ms slow
- Corner radius: 15px buttons, 20px cards
- Shadows: Neon glows for interactive elements

## Features to Implement

- Pickleball scoring rules (only serving team scores)
- Live match timeline with point-by-point breakdown
- Match statistics and analytics
- Local data persistence
- Undo/redo functionality
- Match sharing capabilities

When writing code for this project, prioritize performance, maintainability, and user experience.
