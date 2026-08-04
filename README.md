# Your Budget Manager

Your Budget Manager is a comprehensive Flutter application designed to help users track expenses, manage budgets, save for goals, and automatically categorize transactions.

## Features
- **"Friendly Finance" UI**: A playful, pastel aesthetic with soft geometry, high-contrast hierarchy, and smooth micro-animations. It uses a floating pill navigation and native, open-source fonts for zero network dependency.
- **Dashboard & Analytics**: View a quick summary of your spending, recent transactions, and a dynamic donut chart for budget consumption.
- **Smart Notifications**: Automatically capture transaction details from payment apps using notification reading.
- **Recurring Transactions**: Set up, track, and manage recurring payments and subscriptions with automatic logging and a streamlined numeric keypad UI.
- **Budget Management**: Set overall limits and category-specific constraints.
- **Savings Goals**: Track savings goals with automated deductions.
- **Biometric Security**: Robust App lock with PIN and biometric support that triggers on app launch and returning from the background to keep your financial data secure.
- **Custom Categories**: Map your expenses into predefined or custom categories.

## Technologies Used
- **Flutter & Dart**: For a cross-platform, responsive UI.
- **Drift**: Local SQLite database for seamless offline data persistence.
- **Riverpod**: State management.
- **Local Auth**: Biometric authentication.

## Getting Started

1. Clone the repository.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to launch the app on your connected device or emulator.
