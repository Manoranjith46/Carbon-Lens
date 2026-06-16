# 🌿 CarbonLens — Complete Flutter Frontend Explanation

> **A beginner-to-advanced tutorial** that explains every single file in the CarbonLens Flutter frontend.  
> Read this from top to bottom like a textbook — each section builds on the previous one.

---

## 📖 Table of Contents

1. [What is CarbonLens?](#1-what-is-carbonlens)
2. [Flutter Basics You Need First](#2-flutter-basics-you-need-first)
3. [Project Structure Overview](#3-project-structure-overview)
4. [pubspec.yaml — The Project's Identity Card](#4-pubspecyaml--the-projects-identity-card)
5. [main.dart — Where Everything Begins](#5-maindart--where-everything-begins)
6. [Data Layer — Models & Mock Data](#6-data-layer--models--mock-data)
7. [Theme System — Colors, Status, and Adaptive Theming](#7-theme-system--colors-status-and-adaptive-theming)
8. [State Management — Providers (Riverpod)](#8-state-management--providers-riverpod)
9. [Navigation — Router (GoRouter)](#9-navigation--router-gorouter)
10. [Reusable Widgets — Premium Cards & Shared Widgets](#10-reusable-widgets--premium-cards--shared-widgets)
11. [Screens — Splash Screen](#11-screens--splash-screen)
12. [Screens — Onboarding Flow](#12-screens--onboarding-flow)
13. [Screens — Dashboard (Home)](#13-screens--dashboard-home)
14. [Screens — Track Screen](#14-screens--track-screen)
15. [Screens — Insights Screen](#15-screens--insights-screen)
16. [Screens — Goals Screen](#16-screens--goals-screen)
17. [Screens — Profile Screen](#17-screens--profile-screen)
18. [Advanced Patterns Used in This Project](#18-advanced-patterns-used-in-this-project)
19. [How Data Flows Through the App](#19-how-data-flows-through-the-app)
20. [Summary & What to Learn Next](#20-summary--what-to-learn-next)

---

## 1. What is CarbonLens?

**CarbonLens** is a personal carbon footprint tracker app. It lets users:

- **Onboard** with lifestyle questions (travel, diet, home, shopping)
- **Track** daily carbon-emitting activities (transport, food, energy, etc.)
- **View a Dashboard** showing weekly carbon footprint vs. a target limit
- **See Insights** with charts and category breakdowns
- **Set Goals** for carbon reduction
- **Manage a Profile** with theme switching and data management

Think of it like a "fitness tracker" but for your carbon emissions instead of steps.

---

## 2. Flutter Basics You Need First

Before diving into the code, here are the essential Flutter concepts you'll encounter:

### 2.1 Widgets — Everything is a Widget

In Flutter, **everything you see on screen is a Widget**. A button, a text, a layout, a screen — all widgets.

```
Widget
├── StatelessWidget  → Doesn't change once built (e.g., a label)
├── StatefulWidget   → Can change and rebuild (e.g., a form)
└── ConsumerWidget   → Riverpod's version of StatelessWidget (reads state)
```

### 2.2 StatelessWidget vs StatefulWidget

```dart
// StatelessWidget — "I display data but don't change on my own"
class Greeting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Hello!');
  }
}

// StatefulWidget — "I have internal state that can change"
class Counter extends StatefulWidget {
  @override
  State<Counter> createState() => _CounterState();
}
class _CounterState extends State<Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
    return Text('Count: $count');
  }
}
```

### 2.3 BuildContext

`BuildContext` is a handle to the widget's location in the widget tree. You use it to access things like:
- `Theme.of(context)` — get the current theme
- `MediaQuery.of(context)` — get screen size
- `Navigator.of(context)` — navigate between pages

### 2.4 The `const` Keyword

When you see `const` in Flutter, it means the widget is created at **compile time**, not at runtime. This is a performance optimization — Flutter can reuse the widget instead of rebuilding it.

```dart
const Text('Hello')     // ✅ Created once, reused
Text('Hello')           // ❌ Created every time build() runs
```

### 2.5 Dart's Named Parameters

Flutter heavily uses **named parameters** with `{}`:

```dart
// Definition
class MyWidget extends StatelessWidget {
  final String title;         // required
  final Color? color;         // optional (nullable)
  
  const MyWidget({
    required this.title,      // 'required' = must provide
    this.color,               // optional, defaults to null
  });
}

// Usage
MyWidget(title: 'Hello', color: Colors.red)
MyWidget(title: 'Hello')  // color will be null
```

### 2.6 Dart's Cascade Notation (`..`)

```dart
final list = [3, 1, 2]
  ..sort()           // sort the list IN-PLACE
  ..add(4);          // then add 4 to it
// list is now [1, 2, 3, 4]
```

### 2.7 Dart's `switch` Expressions (Dart 3)

This project uses Dart 3's pattern matching:

```dart
// Old way (statement)
switch (status) {
  case 'safe': return Colors.green;
  case 'danger': return Colors.red;
  default: return Colors.grey;
}

// New way (expression) — used heavily in this project
final color = switch (status) {
  'safe' => Colors.green,
  'danger' => Colors.red,
  _ => Colors.grey,         // _ means "anything else"
};
```

### 2.8 Dart Records `(value1, value2)`

Dart 3 introduces records — lightweight tuples:

```dart
final tab = ('/home', Icons.home, 'Home');
print(tab.$1);  // '/home'
print(tab.$2);  // Icons.home
print(tab.$3);  // 'Home'
```

---

## 3. Project Structure Overview

Here's the folder structure inside `client/lib/`:

```
lib/
├── main.dart                          ← 🚀 Entry point
│
├── data/                              ← 📦 Data layer
│   ├── models/
│   │   └── models.dart                ← Data classes (Activity, Goal, etc.)
│   ├── mock/
│   │   └── mock_data.dart             ← Emission factors & calculations
│   └── repositories/                  ← (empty — for future API calls)
│
├── providers/
│   └── providers.dart                 ← 🧠 State management (Riverpod)
│
├── router/
│   └── app_router.dart                ← 🗺️ Navigation (GoRouter)
│
├── theme/
│   ├── carbon_colors.dart             ← 🎨 All color tokens
│   ├── carbon_status.dart             ← 🚦 Status enum & helpers
│   └── carbon_theme.dart              ← 🎯 ThemeData builder
│
├── widgets/
│   ├── premium_cards.dart             ← 💎 Reusable premium UI widgets
│   └── shared_widgets.dart            ← 🔧 Shared utility widgets
│
└── screens/
    ├── splash/
    │   └── splash_screen.dart         ← 🌊 Launch/loading screen
    ├── onboarding/
    │   ├── onboarding_screen.dart     ← 📝 4-step questionnaire
    │   └── onboarding_result_screen.dart ← 📊 Shows estimated footprint
    ├── dashboard/
    │   └── dashboard_screen.dart      ← 🏠 Main home screen
    ├── track/
    │   └── track_screen.dart          ← ➕ Log activities
    ├── insights/
    │   └── insights_screen.dart       ← 📈 Charts & breakdowns
    ├── goals/
    │   └── goals_screen.dart          ← 🎯 Set & track goals
    └── profile/
        └── profile_screen.dart        ← 👤 User settings & info
```

**Why this structure?** This follows the **feature-first** approach:
- `data/` holds the "brain" (models, business logic)
- `providers/` manages state
- `theme/` handles visual identity
- `widgets/` has reusable building blocks
- `screens/` contains full pages

---

## 4. pubspec.yaml — The Project's Identity Card

**File:** `client/pubspec.yaml`

`pubspec.yaml` is like `package.json` in JavaScript or `requirements.txt` in Python. It defines your project's name, version, and all dependencies.

```yaml
name: carbon_lens                                    # Project name
description: "CarbonLens - Personal carbon footprint tracker"
publish_to: 'none'                                   # Not published to pub.dev
version: 1.0.0+1                                     # Version number + build number
```

**`name: carbon_lens`** — This is the Dart package name. When you do `import 'package:carbon_lens/...'`, this is what you're referencing.

**`publish_to: 'none'`** — Tells Dart "don't try to publish this to pub.dev" (the Dart package registry). This is a private app.

**`version: 1.0.0+1`** — The `1.0.0` is the semantic version (major.minor.patch). The `+1` is the build number (used by app stores).

### Environment

```yaml
environment:
  sdk: ^3.12.2
```

This says "I need Dart SDK version 3.12.2 or higher." The `^` means "compatible with" (any 3.x.x version ≥ 3.12.2).

### Dependencies Explained

Each dependency is a package your app uses. Let's break them all down:

```yaml
dependencies:
  flutter:
    sdk: flutter                    # The Flutter framework itself

  cupertino_icons: ^1.0.8           # iOS-style icons (fallback for Apple look)

  # State Management
  flutter_riverpod: ^2.6.1          # Riverpod — manages app state reactively
  riverpod_annotation: ^2.6.1       # Annotations for Riverpod code generation

  # Navigation
  go_router: ^14.8.1                # Declarative URL-based routing

  # Typography
  google_fonts: ^6.2.1              # Use Google Fonts (like "Inter") easily

  # Charts
  fl_chart: ^0.70.2                 # Beautiful, customizable chart widgets

  # Local Storage
  shared_preferences: ^2.5.3        # Save simple key-value data locally

  # Utilities
  uuid: ^4.5.1                      # Generate unique IDs (for activities, goals)
  intl: ^0.20.2                     # Internationalization & date formatting

  # UI Components
  flutter_svg: ^2.0.17              # Render SVG images
  percent_indicator: ^4.2.5         # Circular/linear progress indicators
  flutter_animate: ^4.5.2           # Easy staggered animations
  shimmer: ^3.0.0                   # Shimmer loading effects
```

#### What each package does in the app:

| Package | What it does in CarbonLens |
|---------|---------------------------|
| `flutter_riverpod` | Stores activities, profile, goals in memory; triggers UI updates |
| `go_router` | Manages `/splash` → `/onboarding` → `/home` navigation flow |
| `google_fonts` | Uses "Inter" font everywhere for clean typography |
| `fl_chart` | Draws the pie chart on the Insights screen |
| `shared_preferences` | Saves onboarding answers locally so they persist across restarts |
| `uuid` | Generates unique IDs like `'3f2504e0-4f89-11d3-9a0c-...'` for each activity |
| `percent_indicator` | Draws the circular progress ring on the Dashboard hero card |
| `flutter_animate` | Fade-in, slide, and scale animations throughout the app |

### Assets

```yaml
flutter:
  uses-material-design: true       # Enable Material Design icons

  assets:
    - assets/icons/                 # Directory for custom icon files
    - assets/images/                # Directory for image files
```

This tells Flutter to bundle the files in `assets/icons/` and `assets/images/` into the app. You can then load them with `Image.asset('assets/images/logo.png')`.

---

## 5. main.dart — Where Everything Begins

**File:** `client/lib/main.dart`

This is the **entry point** of the entire Flutter application. When your app launches, Dart looks for the `main()` function and runs it.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'providers/providers.dart';
import 'theme/carbon_theme.dart';
```

### Imports Explained

| Import | What it provides |
|--------|-----------------|
| `flutter/material.dart` | All Material Design widgets (`Scaffold`, `Text`, `Container`, etc.) |
| `flutter/services.dart` | System services like screen orientation control |
| `flutter_riverpod` | The `ProviderScope` and `ConsumerWidget` classes |
| `router/app_router.dart` | Our custom navigation router |
| `providers/providers.dart` | Our state management providers |
| `theme/carbon_theme.dart` | Our custom theme builder |

### The `main()` Function

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
```

**`WidgetsFlutterBinding.ensureInitialized()`** — This is required when you need to call platform-specific code (like setting orientation) BEFORE `runApp()`. It initializes Flutter's binding to the underlying platform (Android/iOS).

**When do you need it?** Whenever you use any platform plugin (SharedPreferences, camera, etc.) before `runApp()`.

```dart
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
```

**`SystemChrome.setPreferredOrientations`** — Locks the app to **portrait mode only** (no landscape). The user can hold the phone upright or upside-down, but not sideways. This is common for mobile-first apps where the UI is designed for portrait.

```dart
  runApp(
    const ProviderScope(
      child: CarbonLensApp(),
    ),
  );
}
```

**`runApp()`** — This is THE function that starts your Flutter app. It takes a single widget and makes it the root of the widget tree.

**`ProviderScope`** — This is Riverpod's "container". It must wrap your entire app. It holds all the state that your providers create. Without this, `ref.watch()` and `ref.read()` won't work anywhere in your app.

Think of `ProviderScope` as a "warehouse" where all your app's data is stored, and every widget can go to this warehouse to get what it needs.

### The CarbonLensApp Widget

```dart
class CarbonLensApp extends ConsumerWidget {
  const CarbonLensApp({super.key});
```

**`ConsumerWidget`** — This is Riverpod's version of `StatelessWidget`. The difference? It gives you a `WidgetRef ref` parameter in `build()` so you can read providers.

**`{super.key}`** — Dart 3 shorthand. It means "pass the `key` parameter up to the parent class constructor." Every widget can have a `Key` for Flutter's diffing algorithm.

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final carbonStatus = ref.watch(carbonStatusProvider);
    final themeModeSetting = ref.watch(themeModeProvider);
```

**`ref.watch()`** — This is the magic of Riverpod. It does two things:
1. **Reads** the current value of the provider
2. **Subscribes** to changes — when the provider's value changes, this widget automatically rebuilds

So `ref.watch(carbonStatusProvider)` says "give me the current carbon status, AND rebuild me whenever it changes."

```dart
    // Convert ThemeModeSetting to Flutter ThemeMode
    final themeMode = switch (themeModeSetting) {
      ThemeModeSetting.system => ThemeMode.system,
      ThemeModeSetting.light => ThemeMode.light,
      ThemeModeSetting.dark => ThemeMode.dark,
    };
```

This converts our custom `ThemeModeSetting` enum to Flutter's built-in `ThemeMode` enum. We use our own enum so we can store it in Riverpod independently.

```dart
    return MaterialApp.router(
      title: 'CarbonLens',
      debugShowCheckedModeBanner: false,
      theme: CarbonTheme.light(carbonStatus),
      darkTheme: CarbonTheme.dark(carbonStatus),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

**`MaterialApp.router()`** — This is the root widget for a Material Design app that uses declarative routing (GoRouter). Let's break down each parameter:

| Parameter | What it does |
|-----------|-------------|
| `title` | App title (shown in task switcher on Android) |
| `debugShowCheckedModeBanner` | `false` removes the red "DEBUG" banner in the corner |
| `theme` | The light theme — built dynamically based on carbon status! |
| `darkTheme` | The dark theme — also dynamic |
| `themeMode` | Which theme to use: system/light/dark |
| `routerConfig` | The GoRouter that handles page navigation |

> **🔑 Key Insight:** Notice that `CarbonTheme.light(carbonStatus)` takes the current carbon status as input. This means the app's **entire color scheme changes** based on whether you're within your carbon limit (green), near the limit (amber), or over the limit (red). This is called the "Adaptive Colour System."

---

## 6. Data Layer — Models & Mock Data

### 6.1 models.dart — The Data Blueprint

**File:** `client/lib/data/models/models.dart`

Models are **plain Dart classes** that define the shape of your data. They don't have any UI or business logic — they just describe "what does an Activity look like?" or "what does a Goal contain?"

#### Enums — Defining Fixed Categories

```dart
/// Carbon tracking activity categories.
enum ActivityCategory {
  transport,
  food,
  homeEnergy,
  purchases,
  waste,
}
```

**What is an `enum`?** An enum (short for "enumeration") is a type that has a fixed set of possible values. Think of it as a multiple-choice question where the answer can only be one of the listed options.

**Why use enums instead of strings?**
- ✅ Compile-time safety — typos are caught immediately
- ✅ Autocomplete in your IDE
- ✅ `switch` statements can check you covered all cases
- ❌ With strings, you could accidentally write `'transprt'` and get a bug

The project defines several enums:

```dart
enum ConfidenceLevel {
  confirmed,    // User manually confirmed this data
  connected,    // Data came from a connected service
  detected,     // Automatically detected (e.g., GPS)
  estimated,    // Calculated from general patterns
  defaultAssumption,  // Used a default value
}

enum SourceType {
  manual,          // User typed it in
  routine,         // From a saved routine
  detection,       // Auto-detected
  integration,     // From a connected app
  weeklyCheckIn,   // From weekly review
}
```

**Sub-type enums** break down each category into specific types:

```dart
enum TransportType {
  walking, cycling, motorcycle, car, carpool,
  taxi, autoRickshaw, bus, train, metro,
  domesticFlight, internationalFlight,
}

enum FoodType {
  plantBased, vegetarian, eggBased, chicken,
  fish, redMeat, dairy, foodWaste,
}

enum HomeEnergyType {
  electricity, cookingGas, airConditioner,
  heating, majorAppliance, renewableEnergy,
}

enum PurchaseType {
  clothing, electronics, furniture,
  onlineDelivery, personalProducts, generalShopping,
}

enum WasteType {
  generalWaste, recycled, composting,
  foodWaste, electronicWaste,
}
```

#### The Activity Class — A Single Tracked Event

```dart
class Activity {
  final String id;
  final ActivityCategory category;
  final String activityType;
  final double quantity;
  final String unit;
  final DateTime activityTime;
  final SourceType sourceType;
  final ConfidenceLevel confidenceLevel;
  final double? calculatedKgCo2e;
  final double? lowerEstimate;
  final double? upperEstimate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
```

Let's understand every field:

| Field | Type | What it represents | Example |
|-------|------|--------------------|---------| 
| `id` | `String` | Unique identifier | `'a1b2c3d4-...'` |
| `category` | `ActivityCategory` | Which main category | `ActivityCategory.transport` |
| `activityType` | `String` | Specific sub-type | `'car'`, `'bus'`, `'chicken'` |
| `quantity` | `double` | How much | `15.0` (km), `1.0` (meal) |
| `unit` | `String` | Unit of measurement | `'km'`, `'meals'`, `'kWh'` |
| `activityTime` | `DateTime` | When it happened | `DateTime.now()` |
| `sourceType` | `SourceType` | How it was recorded | `SourceType.manual` |
| `confidenceLevel` | `ConfidenceLevel` | How sure we are | `ConfidenceLevel.confirmed` |
| `calculatedKgCo2e` | `double?` | Calculated CO₂ in kg | `2.55` |
| `lowerEstimate` | `double?` | Low end of range | `2.04` |
| `upperEstimate` | `double?` | High end of range | `3.06` |
| `metadata` | `Map?` | Extra data | `{'passengers': 3}` |
| `createdAt` | `DateTime` | When record was created | `DateTime(2025, 1, 15)` |
| `updatedAt` | `DateTime` | When last modified | `DateTime(2025, 1, 15)` |

**Why `final`?** All fields are `final`, meaning they can't be changed after the object is created. This makes `Activity` **immutable** — once you create one, you can't modify it. Instead, you create a new copy with changes.

**Why `double?` with the `?`?** The `?` makes the type **nullable**. `double` must always have a value, but `double?` can be `null`. The calculated CO₂ starts as `null` and gets filled in later when we compute it.

#### The Constructor

```dart
  const Activity({
    required this.id,
    required this.category,
    required this.activityType,
    required this.quantity,
    required this.unit,
    required this.activityTime,
    this.sourceType = SourceType.manual,       // default value
    this.confidenceLevel = ConfidenceLevel.confirmed,  // default value
    this.calculatedKgCo2e,                     // nullable, no default needed
    this.lowerEstimate,
    this.upperEstimate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });
```

**`required this.id`** — You MUST provide an `id` when creating an Activity.  
**`this.sourceType = SourceType.manual`** — If you don't provide `sourceType`, it defaults to `manual`.  
**`this.calculatedKgCo2e`** — No `required`, no default → it will be `null` if not provided.

#### The `copyWith` Method — Immutable Updates

```dart
  Activity copyWith({
    String? id,
    ActivityCategory? category,
    String? activityType,
    double? quantity,
    // ... all other fields
  }) {
    return Activity(
      id: id ?? this.id,
      category: category ?? this.category,
      activityType: activityType ?? this.activityType,
      quantity: quantity ?? this.quantity,
      // ... all other fields
    );
  }
```

**What is `copyWith`?** Since `Activity` is immutable (all fields are `final`), you can't do `activity.quantity = 20`. Instead, you create a copy with the change:

```dart
final original = Activity(id: '1', category: ..., quantity: 10, ...);
final updated = original.copyWith(quantity: 20);
// original.quantity is still 10
// updated.quantity is 20
```

**The `??` operator** means "use the left value if it's not null, otherwise use the right value":
```dart
id: id ?? this.id
// If a new id was passed, use it. Otherwise, keep the existing id.
```

#### Other Model Classes

**`Routine`** — A saved set of activities for quick re-logging:
```dart
class Routine {
  final String id;
  final String name;
  final List<Activity> activities;   // A routine contains multiple activities
  final List<int> daysOfWeek;        // 1=Monday, 7=Sunday
  final DateTime createdAt;
}
```

**`Goal`** — A user's carbon reduction target:
```dart
class Goal {
  final String id;
  final String title;
  final GoalType goalType;           // weekly, monthly, category-specific
  final ActivityCategory? category;  // Optional: goal for specific category
  final double targetValue;          // The target number (e.g., reduce by 5kg)
  final double baselineValue;        // Starting point
  final double progressValue;        // Current progress
  final DateTime startDate;
  final DateTime endDate;
  final GoalStatus status;           // active, completed, expired
  final DateTime createdAt;
```

The `Goal` class has two computed properties (getters):

```dart
  // Calculated property — computed every time you access it
  double get progressPercent {
    if (targetValue <= 0) return 0;
    return (progressValue / targetValue).clamp(0.0, 1.5);
  }
  // .clamp(0.0, 1.5) means "the result must be between 0.0 and 1.5"
  // It allows going slightly OVER 100% (up to 150%) to show overachievement

  // Arrow syntax getter — same as a method but with no ()
  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  // DateTime.difference() returns a Duration, and .inDays converts it to days
```

**`UserProfile`** — Built from onboarding answers:
```dart
class UserProfile {
  final String userId;
  final String? regionCode;           // 'IN' for India
  final String? dietPattern;          // 'vegetarian', 'mixed', etc.
  final String? travelPattern;        // 'car', 'bus', 'bicycle', etc.
  final String? householdType;        // 'apartment', 'smallHouse', etc.
  final int? householdSize;
  final String? consumptionPattern;   // 'rarely', 'weekly', etc.
  final bool onboardingCompleted;     // Has user finished onboarding?
  final double weeklyBaselineKgCo2e;  // Estimated weekly emissions
  final double? weeklyLimitKgCo2e;    // Target limit to stay under
  final DateTime createdAt;
}
```

**`Recommendation`** — A suggestion to reduce emissions:
```dart
class Recommendation {
  final String id;
  final String title;           // "Take the bus for one trip this week"
  final String description;     // Longer explanation
  final String reason;          // "Car travel is your largest transport source."
  final ActivityCategory category;
  final double estimatedReductionKgCo2e;  // How much this saves
  final String costLevel;       // 'free', 'low', 'medium', 'high'
  final String effortLevel;     // 'low', 'medium', 'high'
  final String? alternativeAction;  // An easier alternative
}
```

### 6.2 mock_data.dart — Emission Calculations

**File:** `client/lib/data/mock/mock_data.dart`

This file provides the **emission factors** — how many kg of CO₂ equivalent (kgCO₂e) each activity produces. Currently it uses hardcoded data (hence "mock"), but in a real app, this would come from an API.

#### MockEmissionFactors — The Carbon Calculator

```dart
class MockEmissionFactors {
  MockEmissionFactors._();  // Private constructor — can't create instances
```

**`MockEmissionFactors._()`** — The `._()` is a **private named constructor**. This means nobody can write `MockEmissionFactors()` to create an instance. Why? Because this class only has `static` members — it's used as a namespace, not an object.

#### Emission Factor Maps

```dart
  /// Transport emission factors (kgCO₂e per km)
  static const Map<String, double> transport = {
    'walking': 0.0,           // Walking = zero emissions
    'cycling': 0.0,           // Cycling = zero emissions
    'motorcycle': 0.065,      // 65g CO₂ per km
    'car': 0.170,             // 170g CO₂ per km
    'carpool': 0.085,         // Half of car (shared)
    'taxi': 0.170,            // Same as car
    'autoRickshaw': 0.060,    // Common in India
    'bus': 0.030,             // Very efficient per passenger
    'train': 0.015,           // Most efficient motorized transport
    'metro': 0.010,           // Even better than train
    'domesticFlight': 0.255,  // High emissions per km
    'internationalFlight': 0.195,  // Slightly lower per km (cruising)
  };
```

**`static const Map<String, double>`** — Let's break this down:
- `static` → belongs to the class, not to an instance
- `const` → the map is created at compile time and never changes
- `Map<String, double>` → a dictionary where keys are Strings, values are doubles

You access it as `MockEmissionFactors.transport['car']` → `0.170`.

Similarly, there are maps for `food`, `homeEnergy`, `purchases`, and `waste`.

#### The `getFactor` Method

```dart
  static double getFactor(ActivityCategory category, String type) {
    switch (category) {
      case ActivityCategory.transport:
        return transport[type] ?? 0.1;  // If type not found, use 0.1
      case ActivityCategory.food:
        return food[type] ?? 0.5;
      case ActivityCategory.homeEnergy:
        return homeEnergy[type] ?? 0.5;
      case ActivityCategory.purchases:
        return purchases[type] ?? 5.0;
      case ActivityCategory.waste:
        return waste[type] ?? 0.3;
    }
  }
```

This is a routing function — given a category and type, it looks up the right emission factor from the right map.

#### The `calculate` Method

```dart
  static double calculate(ActivityCategory category, String type, double quantity) {
    return getFactor(category, type) * quantity;
  }
```

Simple multiplication: **emission factor × quantity = total emissions**.

Example: A 15 km car trip → `0.170 × 15 = 2.55 kgCO₂e`

#### The `estimateWeeklyBaseline` Method

This is the most complex function in the file. It estimates a user's weekly carbon footprint based on their onboarding answers:

```dart
  static double estimateWeeklyBaseline({
    required String travelPattern,
    required String dietPattern,
    required String householdType,
    required String consumptionPattern,
  }) {
    double weekly = 0;

    // Travel contribution (5 days commute)
    switch (travelPattern) {
      case 'car':
        weekly += 0.170 * 15 * 5;  // 0.170 kg/km × 15 km × 5 days = 12.75 kg
        break;
      case 'bus':
        weekly += 0.030 * 15 * 5;  // Much lower: 2.25 kg
        break;
      // ... other cases
    }

    // Food contribution (3 meals × 7 days)
    switch (dietPattern) {
      case 'vegetarian':
        weekly += 0.65 * 3 * 7;   // 0.65 per meal × 3 meals × 7 days = 13.65 kg
        break;
      case 'meatMostDays':
        weekly += 2.00 * 3 * 7;   // 42 kg! — much higher
        break;
      // ... other cases
    }

    // Home energy + consumption + waste are added similarly
    weekly += 3.5;  // Average waste estimate

    return weekly;
  }
```

**The logic:** Add up estimated contributions from travel + food + home energy + shopping + waste to get a total weekly estimate.

#### MockRecommendations — Smart Suggestions

```dart
class MockRecommendations {
  MockRecommendations._();

  static List<Recommendation> getForProfile({
    required String travelPattern,
    required String dietPattern,
  }) {
    final recommendations = <Recommendation>[];

    // Only suggest bus/cycling if user drives
    if (travelPattern == 'car' || travelPattern == 'motorcycle') {
      recommendations.add(const Recommendation(
        id: 'rec_bus_commute',
        title: 'Take the bus for one trip this week',
        description: 'Switching one car trip to public transport can save significant emissions.',
        reason: 'Car travel is your largest transport source.',
        category: ActivityCategory.transport,
        estimatedReductionKgCo2e: 1.8,
        costLevel: 'low',
        effortLevel: 'low',
        alternativeAction: 'Try carpooling instead',
      ));
    }
    // ... more conditional recommendations
    return recommendations;
  }
}
```

**Key pattern:** Recommendations are **personalized** — a vegetarian won't see "try plant-based meals" because they already do that.

---

## 7. Theme System — Colors, Status, and Adaptive Theming

This is one of the most **sophisticated** parts of the app. The entire UI color scheme changes dynamically based on the user's carbon status.

### 7.1 carbon_colors.dart — The Color Palette

**File:** `client/lib/theme/carbon_colors.dart`

This file defines EVERY color used in the app as `static const` values. This is called a **design token system** — instead of writing `Color(0xFF2E7D32)` everywhere, you write `CarbonColors.greenPrimary`.

```dart
class CarbonColors {
  CarbonColors._();  // Private constructor — used as a namespace only
```

#### Color Groups

The colors are organized by **purpose**, not just by hue:

**1. Green — Within Carbon Limit (Safe)**
```dart
  // Light mode green
  static const Color greenPrimary = Color(0xFF2E7D32);        // Main green
  static const Color greenHover = Color(0xFF256628);           // Slightly darker for hover
  static const Color greenPressed = Color(0xFF1B5E20);         // Even darker for press
  static const Color greenContainer = Color(0xFFE8F5E9);       // Light green background
  static const Color greenContainerText = Color(0xFF17451B);   // Text on green background
  static const Color onGreenLight = Color(0xFFFFFFFF);          // White text on green

  // Dark mode green — lighter/brighter versions for dark backgrounds
  static const Color greenPrimaryDark = Color(0xFF66BB6A);
  static const Color greenContainerDark = Color(0xFF173D1B);   // Dark green background
```

**What is `Color(0xFF2E7D32)`?**
- `0x` = hexadecimal number
- `FF` = alpha (opacity) — `FF` means fully opaque (100%)
- `2E7D32` = the actual RGB color in hex
  - `2E` = Red (46 in decimal)
  - `7D` = Green (125 in decimal)  
  - `32` = Blue (50 in decimal)
  - Result: a forest green

**2. Red — Over Carbon Limit**
```dart
  static const Color redPrimary = Color(0xFFC62828);           // Alert red
  static const Color redPrimaryDark = Color(0xFFEF5350);       // Brighter red for dark mode
```

**3. Teal — Neutral (No Baseline Yet)**
```dart
  static const Color tealPrimary = Color(0xFF0F766E);          // Calm teal
```

**4. Amber — Warning (Approaching Limit)**
```dart
  static const Color warningLight = Color(0xFFB26A00);         // Amber warning
```

**5. Neutral Palette — Backgrounds, Text, Borders**
```dart
  // Light mode
  static const Color backgroundLight = Color(0xFFF7FAF7);      // Slightly green-tinted white
  static const Color surfaceLight = Color(0xFFFFFFFF);          // Pure white cards
  static const Color textPrimaryLight = Color(0xFF152019);      // Near-black text
  static const Color textSecondaryLight = Color(0xFF5C685F);    // Grey text
  static const Color borderLight = Color(0xFFD8E1DA);           // Light grey border

  // Dark mode
  static const Color backgroundDark = Color(0xFF0B120D);        // Very dark green-black
  static const Color surfaceDark = Color(0xFF121B14);           // Slightly lighter surface
  static const Color textPrimaryDark = Color(0xFFF2F7F3);       // Off-white text
```

**Why have separate light/dark tokens?** In dark mode, you can't just invert colors. Light green on a dark background looks different than dark green on a light background. Each needs to be hand-picked for good contrast and readability.

**6. Chart Colors — For Category Breakdown**
```dart
  static const Color chartTransportLight = Color(0xFF2563EB);   // Blue for transport
  static const Color chartFoodLight = Color(0xFFD97706);        // Orange for food
  static const Color chartHomeLight = Color(0xFF7C3AED);        // Purple for home energy
  static const Color chartPurchasesLight = Color(0xFFDB2777);   // Pink for purchases
  static const Color chartWasteLight = Color(0xFF0F766E);       // Teal for waste
```

Each category gets a **distinct color** so users can quickly identify categories in charts.

**7. Gradients**
```dart
  static const LinearGradient withinLimitGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B5E20), Color(0xFF43A047)],  // Dark green → Lighter green
  );
```

Gradients are used for the hero card on the dashboard. They go from a darker shade to a lighter shade, creating depth.

### 7.2 carbon_status.dart — The Status Engine

**File:** `client/lib/theme/carbon_status.dart`

This tiny but critical file defines the **carbon status** — the state that drives the entire app's color scheme.

```dart
enum CarbonStatus {
  /// No baseline available — uses teal
  neutral,

  /// 0–79% of carbon limit — uses green
  safe,

  /// 80–100% of carbon limit — green + amber warning
  nearLimit,

  /// Above 100% of carbon limit — uses red
  overLimit,
}
```

**The Status Calculation:**

```dart
CarbonStatus getCarbonStatus(double currentFootprint, double? carbonLimit) {
  if (carbonLimit == null || carbonLimit <= 0) {
    return CarbonStatus.neutral;       // No limit set yet
  }
  final percentage = (currentFootprint / carbonLimit) * 100;
  if (percentage > 100) {
    return CarbonStatus.overLimit;     // Over budget! → RED
  }
  if (percentage >= 80) {
    return CarbonStatus.nearLimit;     // Getting close → GREEN + AMBER warning
  }
  return CarbonStatus.safe;           // All good → GREEN
}
```

**How it works:**
- User's weekly limit is 45 kgCO₂e
- Current footprint is 20 kgCO₂e → `20/45 = 44%` → `safe` (green)
- Current footprint is 40 kgCO₂e → `40/45 = 89%` → `nearLimit` (amber)
- Current footprint is 50 kgCO₂e → `50/45 = 111%` → `overLimit` (red)

**Helper functions:**

```dart
String carbonStatusLabel(CarbonStatus status) {
  switch (status) {
    case CarbonStatus.neutral:   return 'Calculating';
    case CarbonStatus.safe:      return 'Within limit';
    case CarbonStatus.nearLimit: return 'Approaching limit';
    case CarbonStatus.overLimit: return 'Limit exceeded';
  }
}

IconData carbonStatusIcon(CarbonStatus status) {
  switch (status) {
    case CarbonStatus.neutral:   return Icons.explore_outlined;
    case CarbonStatus.safe:      return Icons.check_circle_outline;
    case CarbonStatus.nearLimit: return Icons.warning_amber_rounded;
    case CarbonStatus.overLimit: return Icons.error_outline;
  }
}
```

### 7.3 carbon_theme.dart — Building the Complete Theme

**File:** `client/lib/theme/carbon_theme.dart`

This is the **largest theme file** (502 lines). It takes the `CarbonStatus` and creates a complete `ThemeData` object that Flutter uses to style every widget in the app.

```dart
class CarbonTheme {
  CarbonTheme._();

  /// Creates a light theme for the given carbon status.
  static ThemeData light(CarbonStatus status) {
    final primary = _primaryForStatus(status, Brightness.light);
    final onPrimary = _onPrimaryForStatus(status, Brightness.light);
    final primaryContainer = _primaryContainerForStatus(status, Brightness.light);
    final onPrimaryContainer = _onPrimaryContainerForStatus(status, Brightness.light);
```

**The core idea:** Based on the status, pick different primary colors:
- `neutral` → teal
- `safe`/`nearLimit` → green
- `overLimit` → red

Then build the entire Material 3 color scheme around that primary color.

#### ColorScheme — Material 3's Color System

```dart
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: primary,                               // The main brand color
      onPrimary: onPrimary,                           // Text/icon color ON primary
      primaryContainer: primaryContainer,             // Lighter version for backgrounds
      onPrimaryContainer: onPrimaryContainer,         // Text ON primaryContainer
      secondary: CarbonColors.tealPrimary,            // Secondary accent (always teal)
      onSecondary: CarbonColors.onTealLight,
      tertiary: CarbonColors.warningLight,            // Third color (warning amber)
      error: CarbonColors.redPrimary,                 // Error color (always red)
      surface: CarbonColors.surfaceLight,             // Card/sheet backgrounds
      onSurface: CarbonColors.textPrimaryLight,       // Text on surfaces
      outline: CarbonColors.borderLight,              // Borders
      outlineVariant: CarbonColors.dividerLight,      // Dividers
      shadow: Colors.black.withValues(alpha: 0.08),   // Shadow color
    );
```

**What is Material 3 ColorScheme?** It's a system of ~30 named color roles. Instead of picking colors randomly, you assign colors to roles like "primary", "onPrimary", "surface", etc. Then every Material widget automatically uses the right color.

For example:
- A `FilledButton` uses `primary` as its background and `onPrimary` as its text color
- A `Card` uses `surface` as its background
- An error `TextField` uses `error` for the red underline

#### ThemeData — Styling Every Widget

```dart
    return ThemeData(
      useMaterial3: true,                              // Use Material 3 design
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: CarbonColors.backgroundLight,
      textTheme: _textTheme(CarbonColors.textPrimaryLight),
```

**`useMaterial3: true`** — Enables Material Design 3 (the latest version with rounded corners, new color system, etc.)

#### Component Themes

The `ThemeData` includes specific styling for various widgets:

**AppBar:**
```dart
      appBarTheme: AppBarTheme(
        backgroundColor: CarbonColors.backgroundLight,
        elevation: 0,                    // Flat, no shadow
        scrolledUnderElevation: 0.5,     // Slight shadow when content scrolls under
        centerTitle: false,              // Title aligned to left
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CarbonColors.textPrimaryLight,
        ),
      ),
```

**Cards:**
```dart
      cardTheme: CardThemeData(
        color: CarbonColors.surfaceLight,
        elevation: 0,                    // Flat card (no shadow)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),   // Rounded corners
          side: BorderSide(color: CarbonColors.borderLight, width: 1),  // Border instead of shadow
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
```

**Buttons:**
```dart
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,                   // Dynamic based on status!
          foregroundColor: onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
```

**Navigation Bar:**
```dart
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: CarbonColors.surfaceLight,
        indicatorColor: primaryContainer,             // Highlight color for selected tab
        height: 72,
      ),
```

#### The Dark Theme

The `dark()` method follows the exact same pattern but uses dark-mode colors:

```dart
  static ThemeData dark(CarbonStatus status) {
    // Same structure, but using *Dark color variants
    final primary = _primaryForStatus(status, Brightness.dark);
    // ...
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      surface: CarbonColors.surfaceDark,       // Dark surface
      onSurface: CarbonColors.textPrimaryDark, // Light text
      // ...
    );
  }
```

#### Dynamic Color Selection

```dart
  static Color _primaryForStatus(CarbonStatus status, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    switch (status) {
      case CarbonStatus.neutral:
        return isLight ? CarbonColors.tealPrimary : CarbonColors.tealPrimaryDark;
      case CarbonStatus.safe:
      case CarbonStatus.nearLimit:
        return isLight ? CarbonColors.greenPrimary : CarbonColors.greenPrimaryDark;
      case CarbonStatus.overLimit:
        return isLight ? CarbonColors.redPrimary : CarbonColors.redPrimaryDark;
    }
  }
```

**Notice `case CarbonStatus.safe:` falls through to `case CarbonStatus.nearLimit:`** — Both use green (the warning is shown separately with amber accents).

#### Typography

```dart
  static TextTheme _textTheme(Color baseColor) {
    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 57, fontWeight: FontWeight.w400, ...),
      displayMedium: GoogleFonts.inter(fontSize: 45, ...),
      headlineLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w600, ...),
      // ... all 13 text styles from Material 3's type scale
      labelSmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, ...),
    );
  }
```

This defines a complete typography scale using Google's "Inter" font. Material 3 defines 13 text styles from `displayLarge` (biggest) to `labelSmall` (smallest).

---

## 8. State Management — Providers (Riverpod)

**File:** `client/lib/providers/providers.dart`

This is the **brain** of the application. It manages all the data that can change during the app's lifetime.

### What is Riverpod?

Riverpod is a **state management** library. Think of it like this:

- Without Riverpod: You'd have to pass data down through constructor parameters, widget by widget
- With Riverpod: Data lives in "providers" that any widget can access directly

### Provider Types Used

| Provider Type | What it holds | When to use |
|--------------|---------------|-------------|
| `StateNotifierProvider` | Complex state with methods | Activities list, User profile |
| `Provider` | Computed/derived values | Dashboard stats, Recommendations |
| `StateProvider` | Simple single value | Theme mode setting |

### 8.1 Auth Provider — Anonymous User Identity

```dart
final authProvider = StateNotifierProvider<AuthNotifier, String?>((ref) {
  return AuthNotifier();
});
```

**`StateNotifierProvider<AuthNotifier, String?>`** — This creates a provider that:
- Is managed by `AuthNotifier` (the logic class)
- Holds a `String?` (the user ID, or null if not initialized)

```dart
class AuthNotifier extends StateNotifier<String?> {
  AuthNotifier() : super(null);   // Initial state = null (no user yet)

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('anonymous_user_id');
    if (userId == null) {
      // First time user — generate a new ID
      userId = 'guest_${const Uuid().v4().substring(0, 10)}';
      await prefs.setString('anonymous_user_id', userId);
    }
    state = userId;   // Setting 'state' triggers all watching widgets to rebuild
  }
}
```

**`StateNotifier<String?>`** — This is a class that holds a single piece of state. When you change `state = newValue`, all widgets using `ref.watch(authProvider)` automatically rebuild.

**`super(null)`** — The initial state is `null` (no user ID yet).

**How it works:**
1. On first launch: creates a new guest ID like `'guest_3f2504e0'`
2. Saves it to SharedPreferences (persistent storage)
3. On next launch: reads the existing ID from storage
4. Sets `state = userId` which tells Riverpod "the value changed, notify everyone"

### 8.2 Profile Provider — User's Onboarding Data

```dart
final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<UserProfile?> {
  ProfileNotifier() : super(null);  // null = no profile yet
```

**Key method — `completeOnboarding`:**

```dart
  Future<void> completeOnboarding({
    required String userId,
    required String travelPattern,
    required String dietPattern,
    required String householdType,
    required String consumptionPattern,
  }) async {
    // 1. Calculate estimated weekly footprint from answers
    final baseline = MockEmissionFactors.estimateWeeklyBaseline(
      travelPattern: travelPattern,
      dietPattern: dietPattern,
      householdType: householdType,
      consumptionPattern: consumptionPattern,
    );

    // 2. Create the profile object
    final profile = UserProfile(
      userId: userId,
      regionCode: 'IN',
      travelPattern: travelPattern,
      dietPattern: dietPattern,
      householdType: householdType,
      consumptionPattern: consumptionPattern,
      onboardingCompleted: true,
      weeklyBaselineKgCo2e: baseline,
      weeklyLimitKgCo2e: baseline * 0.9,  // Target 10% reduction!
      createdAt: DateTime.now(),
    );

    // 3. Update state (triggers UI rebuild)
    state = profile;

    // 4. Persist to local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    await prefs.setString('travel_pattern', travelPattern);
    // ... save all fields
  }
```

**The 10% reduction target:** `weeklyLimitKgCo2e: baseline * 0.9` — If the estimated baseline is 50 kgCO₂e/week, the limit is set to 45 kgCO₂e/week (a 10% reduction goal).

### 8.3 Activity Provider — The Activity Log

```dart
final activityProvider = StateNotifierProvider<ActivityNotifier, List<Activity>>((ref) {
  return ActivityNotifier();
});

class ActivityNotifier extends StateNotifier<List<Activity>> {
  ActivityNotifier() : super([]);  // Start with empty list
```

**Adding an activity:**

```dart
  void addActivity(Activity activity) {
    // 1. Calculate CO₂ emissions
    final kgCo2e = MockEmissionFactors.calculate(
      activity.category,
      activity.activityType,
      activity.quantity,
    );
    
    // 2. Create a new list with the activity added (with calculated values)
    state = [
      ...state,                          // All existing activities
      activity.copyWith(
        calculatedKgCo2e: kgCo2e,        // The calculated emission
        lowerEstimate: kgCo2e * 0.8,     // 80% (uncertainty range)
        upperEstimate: kgCo2e * 1.2,     // 120% (uncertainty range)
      ),
    ];
  }
```

**Why `state = [...state, newItem]` instead of `state.add(newItem)`?**

This is **immutable state management**. Riverpod detects changes by checking if the reference changed (like `oldState != newState`). If you just `state.add()`, the list reference stays the same, so Riverpod wouldn't know anything changed! By creating a **new list** with `[...state, newItem]`, the reference changes and Riverpod triggers a rebuild.

**Removing an activity:**

```dart
  void removeActivity(String id) {
    state = state.where((a) => a.id != id).toList();
    // .where() keeps only items that pass the test
    // "keep all activities whose id is NOT the one we're removing"
  }
```

**Filtering by date:**

```dart
  List<Activity> getForDate(DateTime date) {
    return state
        .where((a) =>
            a.activityTime.year == date.year &&
            a.activityTime.month == date.month &&
            a.activityTime.day == date.day)
        .toList();
  }
```

### 8.4 Dashboard Provider — Derived State

This is a **`Provider`** (not `StateNotifierProvider`), meaning it's computed from other providers:

```dart
final dashboardProvider = Provider<DashboardState>((ref) {
  final activities = ref.watch(activityProvider);   // Watch activity list
  final profile = ref.watch(profileProvider);       // Watch user profile
```

**`ref.watch()` inside a Provider** — This creates a dependency chain. Whenever `activityProvider` or `profileProvider` changes, `dashboardProvider` automatically recalculates.

```dart
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);  // Midnight today
  final weekStart = today.subtract(Duration(days: today.weekday - 1));  // Monday
```

**`today.weekday`** returns 1 for Monday, 7 for Sunday. So `today.weekday - 1` gives us how many days to go back to reach Monday.

```dart
  // Today's total
  final todayActivities = activities.where((a) =>
      a.activityTime.year == today.year &&
      a.activityTime.month == today.month &&
      a.activityTime.day == today.day);
  
  final todayTotal = todayActivities.fold<double>(
    0,                                    // Starting value
    (sum, a) => sum + (a.calculatedKgCo2e ?? 0),  // Add each activity's CO₂
  );
```

**`.fold()`** is like JavaScript's `.reduce()`. It starts with `0` and adds each activity's emissions to the running total.

```dart
  // Category breakdown — which category contributes the most?
  final breakdown = <ActivityCategory, double>{};
  for (final a in weekActivities) {
    breakdown[a.category] = (breakdown[a.category] ?? 0) + (a.calculatedKgCo2e ?? 0);
  }
```

This builds a map like `{transport: 15.2, food: 8.5, homeEnergy: 3.0}`.

```dart
  // Find the top category
  ActivityCategory? topCat;
  double topVal = 0;
  for (final entry in breakdown.entries) {
    if (entry.value > topVal) {
      topVal = entry.value;
      topCat = entry.key;
    }
  }

  // Determine carbon status
  final limit = profile?.weeklyLimitKgCo2e;
  final status = getCarbonStatus(weeklyTotal, limit);

  return DashboardState(
    todayFootprint: todayTotal,
    weeklyFootprint: weeklyTotal,
    weeklyLimit: limit,
    topCategory: topCat,
    categoryBreakdown: breakdown,
    carbonStatus: status,
  );
});
```

### 8.5 Other Providers

**Carbon Status Provider** — Just extracts the status from dashboard:
```dart
final carbonStatusProvider = Provider<CarbonStatus>((ref) {
  return ref.watch(dashboardProvider).carbonStatus;
});
```

**Recommendation Provider** — Returns personalized suggestions:
```dart
final recommendationProvider = Provider<List<Recommendation>>((ref) {
  final profile = ref.watch(profileProvider);
  if (profile == null) return [];
  return MockRecommendations.getForProfile(
    travelPattern: profile.travelPattern ?? 'combination',
    dietPattern: profile.dietPattern ?? 'mixed',
  );
});
```

**Goal Provider** — CRUD operations for goals:
```dart
final goalProvider = StateNotifierProvider<GoalNotifier, List<Goal>>((ref) {
  return GoalNotifier();
});

class GoalNotifier extends StateNotifier<List<Goal>> {
  GoalNotifier() : super([]);

  void addGoal(Goal goal) {
    state = [...state, goal];           // Add to immutable list
  }

  void removeGoal(String id) {
    state = state.where((g) => g.id != id).toList();
  }
}
```

**Theme Mode Provider** — Simple state:
```dart
final themeModeProvider = StateProvider<ThemeModeSetting>((ref) {
  return ThemeModeSetting.system;       // Default to system theme
});

enum ThemeModeSetting { system, light, dark }
```

**`StateProvider`** is the simplest provider — just holds a single value. It's good for things like toggles, selections, and simple settings.

---

## 9. Navigation — Router (GoRouter)

**File:** `client/lib/router/app_router.dart`

GoRouter provides **URL-based routing** — each screen has a path like `/home`, `/track`, `/profile`. This is similar to how web apps route.

### Navigator Keys

```dart
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();
```

**`GlobalKey<NavigatorState>`** — These are unique identifiers for two navigators:
1. **Root navigator** — handles full-screen navigation (splash, onboarding)
2. **Shell navigator** — handles tab navigation within the main shell

### Route Configuration

```dart
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',        // App starts at splash screen
    routes: [
```

**`initialLocation: '/splash'`** — When the app opens, it shows the splash screen first.

#### Full-Screen Routes (No Bottom Bar)

```dart
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/onboarding-result',
        builder: (context, state) => const OnboardingResultScreen(),
      ),
```

These routes take up the FULL screen — no bottom navigation bar. They're the "before you enter the app" screens.

#### ShellRoute — Tab Navigation

```dart
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/track',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const TrackScreen(),
            ),
          ),
          // ... /insights, /goals, /profile
        ],
      ),
```

**What is a `ShellRoute`?** It's a route that wraps its children with a shared UI element — in this case, the bottom navigation bar. When you switch between `/home`, `/track`, `/insights`, etc., the **bottom bar stays** and only the content area changes.

**`NoTransitionPage`** — No animation when switching tabs (instant switch, like all standard tab bars).

### MainShell — The Bottom Navigation Bar

```dart
class MainShell extends ConsumerWidget {
  final Widget child;  // The current tab's content

  const MainShell({super.key, required this.child});

  // Tab definitions: (path, selectedIcon, unselectedIcon, label)
  static const _tabs = [
    ('/home', Icons.home_rounded, Icons.home_outlined, 'Home'),
    ('/track', Icons.add_circle_rounded, Icons.add_circle_outline, 'Track'),
    ('/insights', Icons.insights_rounded, Icons.insights_outlined, 'Insights'),
    ('/goals', Icons.flag_rounded, Icons.flag_outlined, 'Goals'),
    ('/profile', Icons.person_rounded, Icons.person_outlined, 'Profile'),
  ];
```

**Dart Records** — Each tab is a tuple `(String, IconData, IconData, String)`. Access elements with `.$1`, `.$2`, etc.

```dart
  // Determine which tab is active based on current URL
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;  // e.g., '/home'
    for (int i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].$1) return i;   // Match path
    }
    return 0;  // Default to Home tab
  }
```

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idx = _currentIndex(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: child,   // The current screen's content
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,  // Subtle top border on the nav bar
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: idx,
          onDestinationSelected: (i) => context.go(_tabs[i].$1),  // Navigate!
          destinations: _tabs.map((tab) {
            return NavigationDestination(
              icon: Icon(tab.$3),          // Unselected icon (outlined)
              selectedIcon: Icon(tab.$2),  // Selected icon (filled)
              label: tab.$4,              // 'Home', 'Track', etc.
            );
          }).toList(),
        ),
      ),
    );
  }
```

**`context.go(_tabs[i].$1)`** — GoRouter's `go()` method navigates to a path. So tapping the "Track" tab calls `context.go('/track')`.

**Navigation Flow:**
```
App Launch
    │
    ▼
/splash ──(2.5s delay)──▶ Check onboarding
                              │
                    ┌─────────┴──────────┐
                    ▼                    ▼
              /onboarding          /home (Dashboard)
                    │                    │
                    ▼              ┌─────┴─────┐
            /onboarding-result    │  ShellRoute │
                    │             │  ┌─────────┤
                    ▼             │  │ /track   │
                  /home           │  │ /insights│
                                  │  │ /goals   │
                                  │  │ /profile │
                                  └──┴─────────┘
```

---

## 10. Reusable Widgets — Premium Cards & Shared Widgets

### 10.1 premium_cards.dart — Premium UI Components

**File:** `client/lib/widgets/premium_cards.dart`

#### GlassCard — Glassmorphism Effect

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final Color? tintColor;
  final double blur;          // How blurry the glass effect is
  final double opacity;       // How transparent the glass is
  final Gradient? gradient;
```

**What is Glassmorphism?** It's a design trend where cards look like frosted glass — you can slightly see through them, and the background is blurred.

```dart
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultTint = isDark ? Colors.white : Colors.black;
    final tint = tintColor ?? defaultTint;

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (tintColor ?? Theme.of(context).colorScheme.primary)
                .withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),   // Shadow goes 8 pixels down
          ),
        ],
      ),
      child: ClipRRect(                        // Clips child to rounded rectangle
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(                  // THE BLUR EFFECT
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: gradient ??
                  LinearGradient(               // Semi-transparent overlay
                    colors: [
                      tint.withValues(alpha: opacity),       // 8% opacity
                      tint.withValues(alpha: opacity * 0.5), // 4% opacity
                    ],
                  ),
              border: Border.all(              // Subtle border for glass edge
                color: tint.withValues(alpha: isDark ? 0.12 : 0.08),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
```

**`BackdropFilter`** — This is the key widget. It applies a blur effect to everything BEHIND the widget (the backdrop). Combined with a semi-transparent container on top, it creates the frosted glass look.

**`ClipRRect`** — "Clip Rounded Rectangle." Without this, the blur would extend beyond the card's rounded corners.

**`.withValues(alpha: 0.08)`** — Creates a copy of the color with 8% opacity. This is the newer way to do `.withOpacity(0.08)`.

#### GradientCard — Colorful Background Card

```dart
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;      // Two colors for the gradient
  // ...

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.35),  // Strong shadow
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colors.last.withValues(alpha: 0.15),   // Softer glow
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(padding: padding ?? const EdgeInsets.all(20), child: child),
    );
  }
```

**Two shadows** create a premium "floating" effect — a focused shadow close to the card and a diffuse glow further out.

#### SectionHeader — Titled Section Labels

```dart
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;    // Optional widget on the right side

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Row(
        children: [
          if (icon != null) ...[    // Conditionally show icon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: (iconColor ?? theme.colorScheme.primary)
                    .withValues(alpha: 0.12),    // Tinted background
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 10),
          ],
          Text(title, style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          )),
          if (trailing != null) ...[
            const Spacer(),       // Push trailing to the right
            trailing!,
          ],
        ],
      ),
    );
  }
```

**`if (icon != null) ...[...]`** — Conditional spread. If icon exists, add these widgets to the list. The `...` spreads the inner list into the outer list.

**`const Spacer()`** — A flexible widget that takes up all available space, pushing `trailing` to the right edge.

#### StatChip — Small Stat Display

```dart
class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;     // e.g., "Today"
  final String value;     // e.g., "2.5 kg"
  final Color color;
```

A compact widget with an icon, label, and value — used for small stat displays in rows.

### 10.2 shared_widgets.dart — Utility Widgets

**File:** `client/lib/widgets/shared_widgets.dart`

#### CarbonValueDisplay — Smart CO₂ Formatting

```dart
class CarbonValueDisplay extends StatelessWidget {
  final double kgCo2e;    // Value in kg CO₂e

  @override
  Widget build(BuildContext context) {
    String value;
    String unit;

    // Auto-select the best unit
    if (kgCo2e >= 1000) {
      value = (kgCo2e / 1000).toStringAsFixed(1);  // Convert to tonnes
      unit = 'tCO₂e';
    } else if (kgCo2e >= 1) {
      value = kgCo2e.toStringAsFixed(1);            // Keep as kg
      unit = 'kgCO₂e';
    } else {
      value = (kgCo2e * 1000).toStringAsFixed(0);   // Convert to grams
      unit = 'gCO₂e';
    }

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: value, style: valueStyle ?? ...),
          if (showUnit) ...[
            const TextSpan(text: ' '),
            TextSpan(text: unit, style: unitStyle ?? ...),
          ],
        ],
      ),
    );
  }
```

**`RichText` with `TextSpan`** — This allows different parts of the text to have different styles. The number is big and bold, while the unit is smaller and lighter.

**Smart unit selection:** 0.5 kgCO₂e → "500 gCO₂e", 2.5 kgCO₂e → "2.5 kgCO₂e", 1500 kgCO₂e → "1.5 tCO₂e"

#### ConfidenceBadge — Confidence Level Indicator

```dart
class ConfidenceBadge extends StatelessWidget {
  final String level;

  @override
  Widget build(BuildContext context) {
    // Dart 3 pattern matching with destructuring
    final (icon, label, color) = switch (level) {
      'confirmed' => (Icons.check_circle, 'Confirmed', theme.colorScheme.primary),
      'connected' => (Icons.link, 'Connected', theme.colorScheme.secondary),
      'detected'  => (Icons.sensors, 'Detected', theme.colorScheme.tertiary),
      'estimated' => (Icons.calculate_outlined, 'Estimated', ...),
      _           => (Icons.info_outline, 'Default', ...),
    };
```

**Record destructuring** — The `switch` returns a record `(IconData, String, Color)` which is immediately destructured into three variables. This is a very clean Dart 3 pattern.

#### CategoryIcon — Consistent Category Icons

```dart
class CategoryIcon extends StatelessWidget {
  final String category;
  final double size;
  final Color? color;
  final bool showBackground;

  // Static mapping from category name to icon
  static IconData iconFor(String category) {
    return switch (category) {
      'transport'  => Icons.directions_car_rounded,
      'food'       => Icons.restaurant_rounded,
      'homeEnergy' => Icons.bolt_rounded,
      'purchases'  => Icons.shopping_bag_rounded,
      'waste'      => Icons.delete_rounded,
      _            => Icons.eco_rounded,
    };
  }

  // Static mapping from category name to label
  static String labelFor(String category) {
    return switch (category) {
      'transport'  => 'Transport',
      'food'       => 'Food',
      'homeEnergy' => 'Home Energy',
      'purchases'  => 'Purchases',
      'waste'      => 'Waste',
      _            => 'Other',
    };
  }
```

**`static` methods** — These belong to the class, not to an instance. You can call `CategoryIcon.iconFor('food')` without creating a `CategoryIcon` widget.

When `showBackground` is true, it renders the icon inside a gradient-filled rounded container.

#### EmptyStateWidget — Friendly Empty State

```dart
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;       // Optional button text
  final VoidCallback? onAction;    // Optional button callback
```

This shows a centered message with an icon when there's no data to display. If `actionLabel` and `onAction` are provided, it also shows a call-to-action button.

---

## 11. Screens — Splash Screen

**File:** `client/lib/screens/splash/splash_screen.dart`

The splash screen is the first thing users see. It initializes the app and routes to the right screen.

```dart
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}
```

**`ConsumerStatefulWidget`** — This combines `StatefulWidget` (has mutable state and lifecycle) with `ConsumerWidget` (can read Riverpod providers). You use this when you need both `setState()` AND `ref.read()`/`ref.watch()`.

```dart
class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();    // Start initialization as soon as widget is created
  }
```

**`initState()`** — Called ONCE when the widget is first inserted into the tree. This is the place for one-time setup. You must call `super.initState()` first.

```dart
  Future<void> _initialize() async {
    // 1. Create or load anonymous user ID
    await ref.read(authProvider.notifier).initialize();
    final userId = ref.read(authProvider);

    // 2. Load existing profile if any
    if (userId != null) {
      await ref.read(profileProvider.notifier).initialize(userId);
    }

    // 3. Wait for the splash animation to play
    await Future.delayed(const Duration(milliseconds: 2500));

    // 4. Check if widget is still alive (user didn't navigate away)
    if (!mounted) return;

    // 5. Navigate based on onboarding status
    final profile = ref.read(profileProvider);
    if (profile != null && profile.onboardingCompleted) {
      context.go('/home');         // Already onboarded → go to dashboard
    } else {
      context.go('/onboarding');   // New user → go to onboarding
    }
  }
```

**`ref.read()` vs `ref.watch()`:**
- `ref.read()` — Read the value ONCE, don't subscribe to changes (used in callbacks/methods)
- `ref.watch()` — Read AND subscribe (used in `build()` methods)

**`if (!mounted) return;`** — After an `await`, the widget might have been disposed. `mounted` checks if the widget is still in the tree. Without this check, you could try to navigate on a dead widget → crash.

#### The UI

```dart
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo — animated with scale and fade
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: CarbonColors.neutralGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [...],
              ),
              child: const Icon(Icons.eco_rounded, size: 52, color: Colors.white),
            )
                .animate()                              // flutter_animate magic!
                .scale(
                  begin: const Offset(0.5, 0.5),       // Start at 50% size
                  end: const Offset(1.0, 1.0),         // End at 100% size
                  duration: 800.ms,
                  curve: Curves.elasticOut,             // Bouncy spring effect
                )
                .fadeIn(duration: 400.ms),              // Fade from transparent to visible
```

**`flutter_animate`** — This package makes animations dead simple. Chain `.animate()` after any widget, then add effects:
- `.scale()` — grow/shrink
- `.fadeIn()` — appear gradually
- `.slideY()` — slide vertically
- `delay:` — wait before starting
- `duration:` — how long the animation takes
- `curve:` — the easing function (elasticOut = bouncy)

```dart
            // App name — fades in and slides up
            Text('CarbonLens', style: ...)
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: 0.3, end: 0, delay: 400.ms, duration: 600.ms),

            // Tagline — same but delayed further
            Text('See the impact behind your day.', style: ...)
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms),

            // Loading spinner — appears last
            CircularProgressIndicator(strokeWidth: 3, color: CarbonColors.tealPrimary)
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms),
```

**Staggered animation:** Each element appears slightly after the previous one (400ms → 700ms → 1000ms), creating a smooth reveal sequence.

---

## 12. Screens — Onboarding Flow

### 12.1 onboarding_screen.dart — The Questionnaire

**File:** `client/lib/screens/onboarding/onboarding_screen.dart`

This screen asks 4 lifestyle questions to estimate the user's carbon footprint.

```dart
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User's answers
  String? _travelPattern;
  String? _dietPattern;
  String? _householdType;
  String? _consumptionPattern;

  final _totalPages = 4;
```

**`PageController`** — Controls a `PageView` widget. You can programmatically scroll to specific pages.

#### Navigation Logic

```dart
  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();   // On last page, finish onboarding
    }
  }

  void _complete() async {
    final userId = ref.read(authProvider) ?? 'guest';
    await ref.read(profileProvider.notifier).completeOnboarding(
          userId: userId,
          travelPattern: _travelPattern ?? 'combination',
          dietPattern: _dietPattern ?? 'mixed',
          householdType: _householdType ?? 'apartment',
          consumptionPattern: _consumptionPattern ?? 'onceOrTwice',
        );
    if (mounted) context.go('/onboarding-result');
  }
```

**Default values with `??`:** If the user somehow skips a question (shouldn't happen but safety first), reasonable defaults are used.

#### The Progress Bar

```dart
  Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
    child: Row(
      children: [
        // Back button (disabled on first page)
        IconButton(
          onPressed: _currentPage > 0
              ? () => _pageController.previousPage(...)
              : null,     // null = disabled button
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        
        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,  // 0.25, 0.5, 0.75, 1.0
              minHeight: 6,
            ),
          ),
        ),
        
        // Page counter "1/4"
        Text('${_currentPage + 1}/$_totalPages'),
      ],
    ),
  ),
```

#### The PageView

```dart
  PageView(
    controller: _pageController,
    physics: const NeverScrollableScrollPhysics(),  // Disable swipe! (must tap to advance)
    onPageChanged: (page) => setState(() => _currentPage = page),
    children: [
      _TravelQuestion(
        selected: _travelPattern,
        onSelected: (v) {
          setState(() => _travelPattern = v);
          _next();   // Auto-advance after selection!
        },
      ),
      _FoodQuestion(selected: _dietPattern, onSelected: ...),
      _HomeQuestion(selected: _householdType, onSelected: ...),
      _ConsumptionQuestion(selected: _consumptionPattern, onSelected: ...),
    ],
  ),
```

**`NeverScrollableScrollPhysics()`** — Prevents the user from swiping between pages. They must select an answer to advance. This ensures all questions are answered.

#### The _QuestionPage Template

All 4 questions share the same layout via `_QuestionPage`:

```dart
class _QuestionPage extends StatelessWidget {
  final String emoji;           // 🚗, 🥗, 🏠, 🛒
  final String question;        // "How do you usually travel?"
  final String subtitle;        // Helper text
  final List<_OptionItem> options;  // The answer choices
  final String? selected;       // Currently selected answer
  final ValueChanged<String> onSelected;  // Callback when answer is tapped
```

**`ValueChanged<String>`** — This is a typedef for `void Function(String value)`. It's a callback that receives a String.

```dart
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji with bounce animation
          Text(emoji, style: const TextStyle(fontSize: 48))
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: Offset(0.5, 0.5), end: Offset(1.0, 1.0),
                     curve: Curves.elasticOut),

          // Question text with slide animation
          Text(question, style: theme.textTheme.headlineSmall)
              .animate()
              .fadeIn(delay: 150.ms)
              .slideX(begin: 0.1, end: 0),

          // Subtitle
          Text(subtitle, ...),

          // Options list with staggered animation
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return _OptionTile(
                  icon: option.icon,
                  label: option.label,
                  isSelected: selected == option.value,
                  onTap: () => onSelected(option.value),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: 300 + index * 60),  // Staggered!
                    )
                    .slideX(begin: 0.05, end: 0);
              },
            ),
          ),
        ],
      ),
    );
  }
```

**Staggered animation:** `300 + index * 60` means:
- Option 0: appears at 300ms
- Option 1: appears at 360ms
- Option 2: appears at 420ms
- ...

This creates a cascading "waterfall" effect.

#### The _OptionTile — Selectable Option

```dart
class _OptionTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer    // Highlighted when selected
          : theme.colorScheme.surface,             // Normal background
      borderRadius: BorderRadius.circular(14),
      child: InkWell(                              // Provides ripple effect on tap
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(                   // Smooth border transition
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary      // Bold border when selected
                  : theme.colorScheme.outline.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,           // Thicker border when selected
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? theme.colorScheme.primary : ...),
              Text(label, ...),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
```

**`AnimatedContainer`** — Automatically animates changes to its properties (size, color, border, padding, etc.) over the specified duration. When `isSelected` changes, the border width smoothly transitions from 1 to 2 pixels.

**`InkWell`** — Adds Material Design's ripple effect on tap. The `borderRadius` must match the container's border radius so the ripple doesn't overflow.

#### Individual Questions

Each question widget just passes specific options to `_QuestionPage`:

```dart
class _TravelQuestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _QuestionPage(
      emoji: '🚗',
      question: 'How do you usually travel?',
      subtitle: 'Select your most common transport during a normal week.',
      selected: selected,
      onSelected: onSelected,
      options: const [
        _OptionItem(icon: Icons.directions_walk, label: 'Walk', value: 'walk'),
        _OptionItem(icon: Icons.pedal_bike, label: 'Bicycle', value: 'bicycle'),
        _OptionItem(icon: Icons.two_wheeler, label: 'Motorcycle', value: 'motorcycle'),
        _OptionItem(icon: Icons.directions_car, label: 'Car', value: 'car'),
        // ... more options
      ],
    );
  }
}
```

### 12.2 onboarding_result_screen.dart — Showing the Estimate

**File:** `client/lib/screens/onboarding/onboarding_result_screen.dart`

After the questionnaire, this screen shows the estimated weekly footprint.

```dart
class OnboardingResultScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final baseline = profile?.weeklyBaselineKgCo2e ?? 50.0;
```

The key elements:
1. **Success icon** — eco leaf icon with gradient background (animated scale + fade)
2. **Big number** — `CarbonValueDisplay` showing the weekly estimate
3. **Confidence badge** — "Medium confidence — based on your lifestyle answers"
4. **Info cards** — Three `_ResultCard` widgets showing top source, first suggestion, and calculation method
5. **CTA button** — "Go to Dashboard" button

Each element uses **staggered animations** (appearing one after another):

```dart
  // Icon at 0ms, title at 300ms, big number at 500ms, badge at 700ms
  // Card 1 at 800ms, Card 2 at 950ms, Card 3 at 1100ms
  // Button at 1300ms, "Improve later" at 1400ms
```

---

## 13. Screens — Dashboard (Home)

**File:** `client/lib/screens/dashboard/dashboard_screen.dart`

This is the **largest screen** (850 lines) and the main screen of the app. It shows a summary of the user's carbon footprint.

### The App Bar — Frosted Glass Effect

```dart
SliverAppBar(
  floating: true,        // Shows when scrolling up, hides when scrolling down
  backgroundColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.85),  // Semi-transparent!
  surfaceTintColor: Colors.transparent,
  flexibleSpace: ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),  // Blur content behind
      child: Container(color: Colors.transparent),
    ),
  ),
```

**`SliverAppBar` with `floating: true`** — This app bar is part of a `CustomScrollView`. `floating: true` means it reappears immediately when you start scrolling up (without scrolling all the way to the top).

**The frosted glass effect:** The `BackdropFilter` blurs the content scrolling behind the app bar, while the semi-transparent background lets you see the blurred content. This is a premium iOS-style effect.

### Custom Scroll View

```dart
Scaffold(
  body: CustomScrollView(
    slivers: [
      SliverAppBar(...),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // All dashboard content goes here
          ]),
        ),
      ),
    ],
  ),
);
```

**What are Slivers?** Slivers are the building blocks of custom scrolling. Regular widgets like `ListView` work great for simple lists, but when you need special scroll effects (like a collapsible app bar), you use `CustomScrollView` + slivers.

Think of slivers as "scroll-aware" widgets:
- `SliverAppBar` — an app bar that can collapse/float
- `SliverList` — a scrollable list
- `SliverPadding` — adds padding in a scroll-aware way

### The Hero Card — _HeroCard

This is the big, colorful card at the top showing the weekly footprint:

```dart
class _HeroCard extends StatelessWidget {
  final double weeklyFootprint;
  final double? weeklyLimit;
  final CarbonStatus status;
  final bool isDark;
```

The gradient changes based on status:

```dart
    final gradient = switch (status) {
      CarbonStatus.neutral => isDark
          ? CarbonColors.neutralGradientDark     // Teal gradient
          : CarbonColors.neutralGradient,
      CarbonStatus.safe || CarbonStatus.nearLimit => isDark
          ? CarbonColors.withinLimitGradientDark  // Green gradient
          : CarbonColors.withinLimitGradient,
      CarbonStatus.overLimit => isDark
          ? CarbonColors.overLimitGradientDark    // Red gradient
          : CarbonColors.overLimitGradient,
    };
```

**`CarbonStatus.safe || CarbonStatus.nearLimit`** — Dart 3 OR pattern: match either `safe` or `nearLimit`.

The card contains:
1. **"This Week" label** in a pill-shaped badge
2. **The big number** using `CarbonValueDisplay`
3. **Status indicator** with icon and label
4. **Circular progress ring** using `percent_indicator` package:

```dart
    CircularPercentIndicator(
      radius: 56,                     // Size of the circle
      lineWidth: 9,                   // Thickness of the progress bar
      percent: percent.clamp(0.0, 1.0),  // 0.0 to 1.0
      center: Column(               // Content inside the circle
        children: [
          Text('${(percent * 100).toInt()}%', ...),
          Text('used', ...),
        ],
      ),
      progressColor: Colors.white,
      backgroundColor: Colors.white.withValues(alpha: 0.18),
      circularStrokeCap: CircularStrokeCap.round,  // Rounded ends
      animation: true,
      animationDuration: 1200,       // 1.2 second animation
    ),
```

5. **Weekly limit indicator** at the bottom:

```dart
    if (weeklyLimit != null) ...[
      Text('Weekly limit: ${weeklyLimit!.toStringAsFixed(1)} kgCO₂e'),
    ],
```

### Stats Row — _MiniStatCard

Two small cards side by side:
- **Today's total** (e.g., "2.5 kg")
- **vs Average** (e.g., "+1.2 kg" or "-0.8 kg") — shows if today is above or below your daily average

```dart
Row(
  children: [
    Expanded(child: _MiniStatCard(label: 'Today', kgCo2e: dashboard.todayFootprint, ...)),
    const SizedBox(width: 10),
    Expanded(child: _MiniStatCard(label: 'vs Avg', kgCo2e: diff, showSign: true, ...)),
  ],
),
```

### Category Breakdown — _CategoryBreakdownPremium

This widget shows a segmented bar (like a horizontal stacked chart) + a list of categories:

```dart
  // Sort categories by value (highest first)
  final sorted = breakdown.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  // Segmented progress bar
  Row(
    children: sorted.map((e) {
      final pct = e.value / total;
      return Flexible(
        flex: (pct * 100).round().clamp(1, 100),  // Proportional width
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [categoryColor, ...]),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      );
    }).toList(),
  ),
```

**`Flexible` with `flex`** — Like CSS flexbox. If transport is 60% and food is 40%, their flex values would be 60 and 40, giving them proportional widths.

### Suggestion Card — _PremiumSuggestionCard

A warm amber-tinted card showing the top recommendation:

```dart
  final accentColor = isDark ? const Color(0xFFFFD54F) : const Color(0xFFFF9800);

  Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF2E2408), const Color(0xFF1A1505)]  // Warm dark
            : [const Color(0xFFFFF8E1), const Color(0xFFFFF3E0)],  // Warm light
      ),
    ),
    child: Column(
      children: [
        // Header with "Smart Suggestion" + estimated savings badge
        // Title + description
        // "Try this" button + "Skip" button
      ],
    ),
  ),
```

### The _colorForCategory Helper

A top-level function used across the dashboard:

```dart
Color _colorForCategory(ActivityCategory cat, bool isDark) {
  return switch (cat) {
    ActivityCategory.transport  => isDark ? CarbonColors.chartTransportDark : CarbonColors.chartTransportLight,
    ActivityCategory.food       => isDark ? CarbonColors.chartFoodDark : CarbonColors.chartFoodLight,
    ActivityCategory.homeEnergy => isDark ? CarbonColors.chartHomeDark : CarbonColors.chartHomeLight,
    ActivityCategory.purchases  => isDark ? CarbonColors.chartPurchasesDark : CarbonColors.chartPurchasesLight,
    ActivityCategory.waste      => isDark ? CarbonColors.chartWasteDark : CarbonColors.chartWasteLight,
  };
}
```

---

## 14. Screens — Track Screen

**File:** `client/lib/screens/track/track_screen.dart`

This screen lets users log new carbon-emitting activities.

### Category Color Map

```dart
  static const _categoryColors = {
    ActivityCategory.transport:  (Color(0xFF4FC3F7), Color(0xFF0288D1)),  // (light, dark)
    ActivityCategory.food:       (Color(0xFF81C784), Color(0xFF388E3C)),
    ActivityCategory.homeEnergy: (Color(0xFFFFB74D), Color(0xFFF57C00)),
    ActivityCategory.purchases:  (Color(0xFFBA68C8), Color(0xFF7B1FA2)),
    ActivityCategory.waste:      (Color(0xFF90A4AE), Color(0xFF546E7A)),
  };
```

Each category has two colors stored as a **Record** `(lightVariant, darkVariant)`.

### Quick Log Categories

A horizontal scrollable row of category cards:

```dart
SizedBox(
  height: 110,
  child: ListView(
    scrollDirection: Axis.horizontal,    // Scroll left-right
    children: ActivityCategory.values.asMap().entries.map((entry) {
      final cat = entry.value;
      final colors = _categoryColors[cat]!;
      return _PremiumCategoryCard(
        category: cat,
        lightColor: colors.$1,    // First element of the record
        darkColor: colors.$2,     // Second element
        isDark: isDark,
        onTap: () => _showQuickLog(context, ref, cat),
      );
    }).toList()
        .animate(interval: 80.ms)   // Staggered animation: 80ms between each
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.08, end: 0),
  ),
),
```

**`.animate(interval: 80.ms)`** — When applied to a list, `interval` adds a delay between each item's animation, creating a cascade effect.

### Today's Activity Log

```dart
  final todayActivities = activities.where((a) {
    final now = DateTime.now();
    return a.activityTime.year == now.year &&
        a.activityTime.month == now.month &&
        a.activityTime.day == now.day;
  }).toList();
```

**Empty state vs. filled state:**

```dart
  if (todayActivities.isEmpty)
    Container(...)  // Shows "No activities today" message
  else
    ...todayActivities.map((a) => _PremiumActivityTile(activity: a, ...)),
```

### _PremiumActivityTile — Swipe to Delete

```dart
class _PremiumActivityTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(activity.id),            // Unique key for the item
      direction: DismissDirection.endToStart,  // Only swipe right-to-left
      onDismissed: (_) {
        ref.read(activityProvider.notifier).removeActivity(activity.id);
      },
      background: Container(                 // Red delete background
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_rounded, color: theme.colorScheme.error),
      ),
      child: Container(                      // The actual tile
        child: Row(
          children: [
            // Category icon
            // Activity type + quantity
            // CO₂ value badge
          ],
        ),
      ),
    );
  }
```

**`Dismissible`** — A built-in Flutter widget that lets users swipe to dismiss. The `background` is revealed as the user swipes. When fully swiped, `onDismissed` fires.

### The Quick Log Bottom Sheet — _PremiumLogSheet

```dart
  void _showQuickLog(BuildContext context, WidgetRef ref, ActivityCategory category) {
    final options = _optionsForCategory(category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,             // Can take more than half the screen
      backgroundColor: Colors.transparent,  // We draw our own background
      builder: (ctx) => _PremiumLogSheet(
        category: category,
        options: options,
        accentColor: ...,
        onLog: (type, quantity, unit) {
          ref.read(activityProvider.notifier).addActivity(Activity(
            id: const Uuid().v4(),          // Generate unique ID
            category: category,
            activityType: type,
            quantity: quantity,
            unit: unit,
            activityTime: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ));
          Navigator.pop(ctx);               // Close the sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Activity logged ✓')),
          );
        },
      ),
    );
  }
```

**`showModalBottomSheet`** — Shows a sheet sliding up from the bottom of the screen. `isScrollControlled: true` allows it to expand beyond 50% of the screen.

The `_PremiumLogSheet` is a `StatefulWidget` because it tracks which option is selected and manages a text field:

```dart
class _PremiumLogSheetState extends State<_PremiumLogSheet> {
  _QuickOption? _selected;                    // Currently selected activity type
  late TextEditingController _qtyController;  // Controls the quantity text field

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController();
  }

  @override
  void dispose() {
    _qtyController.dispose();   // Always dispose controllers to prevent memory leaks!
    super.dispose();
  }
```

**`DraggableScrollableSheet`** — A sheet that users can drag up and down:

```dart
  DraggableScrollableSheet(
    initialChildSize: 0.65,   // Start at 65% of screen height
    minChildSize: 0.4,        // Can shrink to 40%
    maxChildSize: 0.9,        // Can expand to 90%
    expand: false,
    builder: (context, scrollController) => ...
  ),
```

When an option is selected, it reveals a quantity input field and a submit button.

### The FloatingActionButton

```dart
  floatingActionButton: Container(
    decoration: BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: FloatingActionButton.extended(
      onPressed: () => _showQuickLog(context, ref, ActivityCategory.transport),
      icon: const Icon(Icons.add_rounded),
      label: const Text('Log Activity'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  ),
```

**`FloatingActionButton.extended`** — A FAB with both an icon AND a text label (wider than a regular FAB).

---

## 15. Screens — Insights Screen

**File:** `client/lib/screens/insights/insights_screen.dart`

This screen provides analytical views of the user's carbon data.

### The Pie Chart

```dart
  SizedBox(
    height: 200,
    child: PieChart(
      PieChartData(
        sections: dashboard.categoryBreakdown.entries.map((e) {
          final pct = (e.value / total * 100);
          final color = _colorForCat(e.key, isDark);
          return PieChartSectionData(
            value: e.value,          // The data value (used for proportional sizing)
            color: color,            // Section color
            radius: 40,             // Thickness of the donut
            title: '${pct.toInt()}%', // Text shown on the section
            titleStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 4,           // Gap between sections
        centerSpaceRadius: 48,      // Hole in the center (makes it a donut chart)
      ),
    ),
  ),
```

**`fl_chart` package** — This creates a donut/pie chart. The `centerSpaceRadius: 48` creates the hole in the middle. Each `PieChartSectionData` represents one slice.

### Chart Legend

```dart
  Wrap(
    spacing: 16,      // Horizontal gap between items
    runSpacing: 10,    // Vertical gap between rows
    children: dashboard.categoryBreakdown.entries.map((e) {
      final color = _colorForCat(e.key, isDark);
      return Row(
        mainAxisSize: MainAxisSize.min,  // Only as wide as needed
        children: [
          Container(width: 12, height: 12, decoration: ...),  // Color dot
          Text(CategoryIcon.labelFor(e.key.name)),              // Category name
        ],
      );
    }).toList(),
  ),
```

**`Wrap`** — Unlike `Row` (which overflows), `Wrap` moves items to the next line when there's no room. Perfect for dynamic-length legends.

### Category Detail Cards

Each category gets a card with a progress bar:

```dart
  Container(
    child: Row(
      children: [
        CategoryIcon(category: e.key.name, showBackground: true),
        Expanded(
          child: Column(
            children: [
              Text(CategoryIcon.labelFor(e.key.name)),
              LinearProgressIndicator(
                value: e.value / total,         // Percentage as 0.0-1.0
                backgroundColor: catColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(catColor),
              ),
            ],
          ),
        ),
        // Percentage badge + kg value
      ],
    ),
  ),
```

### Recent Activities List

Shows the last 15 activities:

```dart
  ...activities.reversed.take(15).toList().asMap().entries.map((entry) {
    // Similar to track screen's activity tiles but simpler
  }),
```

**`.reversed.take(15)`** — Reverse the list (newest first), then take only the first 15.

---

## 16. Screens — Goals Screen

**File:** `client/lib/screens/goals/goals_screen.dart`

### Empty State

When there are no goals, a full-screen empty state is shown:

```dart
  goals.isEmpty
      ? SliverFillRemaining(      // Takes all remaining vertical space
          child: Center(
            child: Column(
              children: [
                // Big flag icon with gradient circle background
                // "Set your first goal" title
                // Description text
                // "Create a Goal" button
              ],
            ),
          ),
        )
      : SliverPadding(
          // ... show goal cards
        ),
```

**`SliverFillRemaining`** — A sliver that fills all remaining space in the scroll view. Perfect for centered empty states.

### _PremiumGoalCard — Goal Progress Display

Each goal card rotates through 4 gradient color schemes:

```dart
  static const _gradientColors = [
    [Color(0xFF00897B), Color(0xFF004D40)],  // Teal
    [Color(0xFF1976D2), Color(0xFF0D47A1)],  // Blue
    [Color(0xFF7B1FA2), Color(0xFF4A148C)],  // Purple
    [Color(0xFFF57C00), Color(0xFFE65100)],  // Orange
  ];

  final colors = _gradientColors[index % _gradientColors.length];
  // index 0 → teal, index 1 → blue, index 2 → purple, index 3 → orange
  // index 4 → teal again (wraps around with %)
```

The progress bar uses `FractionallySizedBox`:

```dart
  Stack(
    children: [
      // Background track
      Container(height: 10, color: accentColor.withValues(alpha: 0.1)),
      // Filled progress
      FractionallySizedBox(
        widthFactor: pct.clamp(0, 1),  // 0.0 to 1.0 = 0% to 100% width
        child: Container(
          height: 10,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
          ),
        ),
      ),
    ],
  ),
```

**`FractionallySizedBox`** — Sizes its child as a fraction of the parent's size. `widthFactor: 0.6` means 60% of the parent's width.

### _PremiumCreateGoalSheet — Goal Creation

A bottom sheet with:
1. **Title text field** (pre-filled with "Reduce weekly footprint")
2. **Target slider** (1-20 kgCO₂e)
3. **Create button**

```dart
  SliderTheme(
    data: SliderThemeData(
      activeTrackColor: CarbonColors.greenPrimary,
      thumbColor: CarbonColors.greenPrimary,
    ),
    child: Slider(
      value: _targetValue,
      min: 1,
      max: 20,
      divisions: 19,        // 19 steps between 1 and 20
      onChanged: (v) => setState(() => _targetValue = v),
    ),
  ),
```

**`Slider` with `divisions: 19`** — Snaps to discrete values (1.0, 2.0, 3.0, ..., 20.0) instead of continuous sliding.

When "Create Goal" is tapped:

```dart
  widget.onCreate(Goal(
    id: const Uuid().v4(),
    title: _titleController.text,
    goalType: GoalType.weeklyReduction,
    targetValue: _targetValue,
    baselineValue: 0,
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 7)),  // 1-week goal
    createdAt: DateTime.now(),
  ));
```

---

## 17. Screens — Profile Screen

**File:** `client/lib/screens/profile/profile_screen.dart`

### Profile Header Card

A gradient teal card showing the user avatar and region:

```dart
  Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [const Color(0xFF1A2E2E), const Color(0xFF0D1A1A)]  // Subtle dark
            : [const Color(0xFF00897B), const Color(0xFF004D40)],  // Vibrant light
      ),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [...],
    ),
    child: Row(
      children: [
        // Avatar circle
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Colors.white.withValues(alpha: 0.25),
              Colors.white.withValues(alpha: 0.1),
            ]),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
          ),
          child: Icon(Icons.person_rounded, color: Colors.white),
        ),
        // Name + region badge
        Column(
          children: [
            Text('Guest User', ...),
            Container(  // Region pill badge
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, ...),
                  Text('India', ...),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  ),
```

### Theme Switcher — SegmentedButton

```dart
  SegmentedButton<ThemeModeSetting>(
    selected: {themeMode},                        // Set of selected values
    onSelectionChanged: (v) {
      ref.read(themeModeProvider.notifier).state = v.first;  // Update state
    },
    segments: const [
      ButtonSegment(value: ThemeModeSetting.system, label: Text('System'), icon: Icon(Icons.brightness_auto)),
      ButtonSegment(value: ThemeModeSetting.light, label: Text('Light'), icon: Icon(Icons.light_mode)),
      ButtonSegment(value: ThemeModeSetting.dark, label: Text('Dark'), icon: Icon(Icons.dark_mode)),
    ],
  ),
```

**`SegmentedButton`** — A Material 3 widget for selecting one option from a group. Like a toggle button group.

**`ref.read(themeModeProvider.notifier).state = v.first`** — For `StateProvider`, the `.notifier` gives you direct access to the `.state` property, which you can assign to.

### Lifestyle Profile Section

If onboarding is complete, shows the user's answers:

```dart
  if (profile != null) ...[
    _PremiumInfoRow(icon: Icons.directions_car_rounded, label: 'Travel', value: profile.travelPattern ?? 'Not set', color: Color(0xFF4FC3F7)),
    _PremiumInfoRow(icon: Icons.restaurant_rounded, label: 'Diet', value: profile.dietPattern ?? 'Not set', color: Color(0xFF81C784)),
    _PremiumInfoRow(icon: Icons.home_rounded, label: 'Home', value: profile.householdType ?? 'Not set', color: Color(0xFFFFB74D)),
    _PremiumInfoRow(icon: Icons.shopping_bag_rounded, label: 'Shopping', value: profile.consumptionPattern ?? 'Not set', color: Color(0xFFBA68C8)),
    // Weekly baseline display
  ],
```

### _PremiumOption — Settings Menu Items

```dart
class _PremiumOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> iconGradient;     // Two colors for the icon's gradient
  final VoidCallback onTap;
  final bool isDestructive;           // Makes the label red for dangerous actions
```

Each option has a gradient icon in a rounded square + label + chevron arrow.

### Delete Data Confirmation

```dart
  void _showDeleteConfirm(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete all data?'),
        content: const Text('This will permanently remove your profile...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),  // Cancel
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () { ... },                 // Delete
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,  // Red!
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
```

**`showDialog`** — Shows a modal dialog (overlay that blocks interaction with the screen behind it).

---

## 18. Advanced Patterns Used in This Project

### 18.1 Immutable State Pattern

All state is immutable. Instead of modifying objects in-place, we create new copies:

```dart
// ❌ Mutable (DON'T do this with Riverpod)
state.add(newActivity);

// ✅ Immutable (DO this)
state = [...state, newActivity];
```

**Why?** Riverpod (and most reactive frameworks) detect changes by **reference comparison**. A new list `!=` old list, so Riverpod knows to rebuild. Mutating the same list in-place doesn't change the reference.

### 18.2 Derived State (Computed Providers)

```dart
final dashboardProvider = Provider<DashboardState>((ref) {
  final activities = ref.watch(activityProvider);   // Dependency 1
  final profile = ref.watch(profileProvider);       // Dependency 2
  
  // ... compute derived values
  return DashboardState(...);
});
```

The dashboard state doesn't store its own data — it **computes** everything from activities + profile. When either dependency changes, dashboard automatically recalculates.

### 18.3 ShellRoute Pattern (Persistent Navigation)

The bottom navigation bar persists across tab changes because all tab routes are children of a `ShellRoute`. The `MainShell` widget is only built once, and only its `child` changes.

### 18.4 Adaptive Theming

The entire app's color scheme adapts to the carbon status:

```
User logs activities → activityProvider updates
    → dashboardProvider recalculates
    → carbonStatusProvider changes (safe → nearLimit)
    → CarbonLensApp rebuilds with CarbonTheme.light(newStatus)
    → ALL widgets using theme colors automatically change
```

This is a cascade of reactive updates, all handled automatically by Riverpod.

### 18.5 Animation Patterns

Three main animation approaches:

**1. flutter_animate — Declarative Chain**
```dart
widget.animate()
    .fadeIn(delay: 300.ms, duration: 400.ms)
    .slideY(begin: 0.1, end: 0)
```

**2. AnimatedContainer — Implicit Animation**
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  // Properties animate smoothly when they change
  color: isSelected ? Colors.blue : Colors.grey,
  width: isExpanded ? 200 : 100,
)
```

**3. Staggered Lists**
```dart
children.animate(interval: 80.ms)  // Each child starts 80ms after the previous
    .fadeIn()
    .slideX()
```

### 18.6 Responsive Colors (Dark/Light)

Nearly every widget checks `isDark` and picks appropriate colors:

```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final color = isDark ? CarbonColors.chartTransportDark : CarbonColors.chartTransportLight;
```

---

## 19. How Data Flows Through the App

Here's the complete data flow, from user action to UI update:

```
    ┌─────────────────────────────────────────────────────┐
    │                   USER ACTION                        │
    │  (Taps "Car, 15km" in the Track screen)             │
    └─────────────────────┬───────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────┐
    │              ACTIVITY NOTIFIER                       │
    │  ref.read(activityProvider.notifier).addActivity()   │
    │  → Calculates CO₂: 0.170 × 15 = 2.55 kgCO₂e       │
    │  → Creates new list: state = [...state, newActivity] │
    └─────────────────────┬───────────────────────────────┘
                          │
                          ▼  (Riverpod notifies watchers)
    ┌─────────────────────────────────────────────────────┐
    │             DASHBOARD PROVIDER                       │
    │  ref.watch(activityProvider) → recalculates          │
    │  → todayFootprint = 2.55                            │
    │  → weeklyFootprint = 2.55                           │
    │  → categoryBreakdown = {transport: 2.55}            │
    │  → carbonStatus = safe (2.55 < 45.0 limit)          │
    └──────────┬──────────────────────────┬───────────────┘
               │                          │
               ▼                          ▼
    ┌──────────────────┐      ┌──────────────────────────┐
    │ CARBON STATUS    │      │ RECOMMENDATION            │
    │ PROVIDER         │      │ PROVIDER                  │
    │ → CarbonStatus   │      │ → List<Recommendation>    │
    │    .safe         │      │   (unchanged)             │
    └────────┬─────────┘      └──────────┬───────────────┘
             │                           │
             ▼                           ▼
    ┌─────────────────────────────────────────────────────┐
    │                 CARBONLENS APP                        │
    │  ref.watch(carbonStatusProvider) → rebuilds           │
    │  → CarbonTheme.light(CarbonStatus.safe) → GREEN     │
    └─────────────────────┬───────────────────────────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────────────┐
    │               ALL SCREENS REBUILD                    │
    │  Dashboard: Shows 2.55 kg, green hero card           │
    │  Track: Shows "car 15km" in today's log             │
    │  Insights: Updates pie chart                         │
    └─────────────────────────────────────────────────────┘
```

---

## 20. Summary & What to Learn Next

### What You've Learned

| Concept | Where it's used |
|---------|----------------|
| **StatelessWidget** | Most screens (`DashboardScreen`, `InsightsScreen`) |
| **StatefulWidget** | Forms and animations (`OnboardingScreen`, `_PremiumLogSheet`) |
| **ConsumerWidget** | All screens that read state |
| **Riverpod Providers** | All state management in `providers.dart` |
| **GoRouter** | URL-based navigation in `app_router.dart` |
| **Material 3 Theming** | Adaptive color system in `carbon_theme.dart` |
| **CustomScrollView + Slivers** | Every main screen |
| **Animations** | flutter_animate throughout the app |
| **Bottom Sheets** | Track + Goals screen for data entry |
| **Immutable State** | copyWith pattern on all models |
| **Design Tokens** | CarbonColors for consistent styling |
| **Glassmorphism** | GlassCard and blurred app bars |

### Concepts from Basic to Advanced

```
Level 1 (Basic):
  ✅ Widgets (Text, Container, Row, Column)
  ✅ StatelessWidget vs StatefulWidget
  ✅ Scaffold, AppBar, NavigationBar
  ✅ setState()

Level 2 (Intermediate):
  ✅ ListView, PageView, CustomScrollView
  ✅ Theme and ColorScheme
  ✅ Named parameters, const constructors
  ✅ Enums, classes, copyWith pattern

Level 3 (Advanced):
  ✅ Riverpod state management
  ✅ GoRouter with ShellRoute
  ✅ Dart 3 patterns (switch expressions, records)
  ✅ BackdropFilter (glassmorphism)
  ✅ Slivers (SliverAppBar, SliverList)
  ✅ Derived/computed state
  ✅ Staggered animations
  ✅ Adaptive theming based on app state
```

### What to Explore Next

1. **Add a real backend** — Replace `MockEmissionFactors` with API calls
2. **Add data persistence** — Use `sqflite` or `hive` to persist activities locally
3. **Add weekly charts** — Use `fl_chart` to show emission trends over time
4. **Add user authentication** — Implement the Google/Apple sign-in buttons
5. **Add unit tests** — Test providers and emission calculations
6. **Add localization** — Support multiple languages using the `intl` package
7. **Explore code generation** — Use `riverpod_annotation` for cleaner provider code

---

> 🎓 **Final note:** The best way to learn is to **modify this code**. Try changing a color, adding a new activity type, or creating a new screen. Break things, fix things, and build things. That's how Flutter skills grow!
