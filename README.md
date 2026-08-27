# 🎯 MiGoalPilot

**MiGoalPilot** is a premium, feature-rich goal planning and savings tracking companion application. Designed to help users visualize and execute their financial objectives, it supports multi-goal tracking, specialized gold-savings trackers, joint couple milestones, "What-If" simulation builders, and AI-driven saving recommendations.

---

## ✨ Features

- 📈 **Goal Planning & Visual Analytics**: Interactive chart visualizations powered by `fl_chart` showing target trajectories and current progress.
- 🟡 **Gold Tracker**: Track goals specifically structured around gold valuations (grams, current spot prices, and real-time remaining values).
- 👥 **Couple Collaboration**: Shared dashboard views to plan, align, and pool savings together with a partner.
- ⚙️ **What-If Simulations**: Play with dynamic parameter shifts (e.g. guest counts, time frame alterations) to visualize impact on target budgets.
- 🧠 **AI Suggestions**: Context-aware saving tips and planning guidance to accelerate milestones.
- 🔒 **Secure Data Storage**: Local caching using `shared_preferences` and industry-grade secure value encryption using `flutter_secure_storage`.

---

## 🛠️ Tech Stack & Packages

- **State Management**: [Riverpod](https://pub.dev/packages/flutter_riverpod) & Riverpod Generator (`riverpod_annotation`)
- **Routing**: [GoRouter](https://pub.dev/packages/go_router)
- **Data Models**: [Freezed](https://pub.dev/packages/freezed) & [JSON Serializable](https://pub.dev/packages/json_serializable) for immutable models
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Typography**: [Google Fonts](https://pub.dev/packages/google_fonts)

---

## 📂 Project Structure

```text
lib/
├── app/                  # Application routing, constants, themes, and configuration
│   ├── constants/        # Global app constants (e.g., app name, storage keys)
│   ├── router/           # GoRouter declarations & main navigation shells
│   └── theme/            # App design system, custom typography, spacing, and colors
├── core/                 # Shared domain logic
│   ├── models/           # Freezed data models (Goals, UserProfile, Savings logs)
│   ├── repositories/     # Data sources & API repositories (Secure storage, remote APIs)
│   ├── viewmodels/       # Riverpod Providers & application state controllers
│   └── widgets/          # Reusable UI component libraries
├── features/             # Feature views & modular screens
│   ├── auth/             # Login, Registration, Password Recovery, Onboarding
│   ├── dashboard/        # Main Dashboard, tracking lists, progress gauges
│   ├── gold/             # Gold-savings tracking screens
│   ├── couple/           # Joint goals & couple pairing views
│   └── profile/          # Profile metrics & settings customization
└── main.dart             # App bootstrap entry point
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the Flutter SDK installed and configured on your system:
- **Flutter SDK**: `^3.12.2` (or compatible Dart version `^3.12.2` up to `<4.0.0`)
- **Android SDK**: Compile SDK API 34+

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone <repository_url>
   cd migoalpilot_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Code Generation**:
   Generate the immutable model wrappers and Riverpod state classes:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Launch Application**:
   Run the project in debug mode on your connected emulator or physical device:
   ```bash
   flutter run
   ```

---

## 🧪 Running Tests

Ensure all units and widget navigations are working correctly by executing:

```bash
flutter test
```
