# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **V2 "Friendly Finance" Redesign**: Major UI overhaul adopting a playful, pastel aesthetic. Features floating rounded navigation, large hero typography, and a cohesive design system using local, open-source fonts (Manrope/Plus Jakarta Sans) without external dependencies.
- **Main Navigation Shell**: Added a floating pill-style bottom navigation bar for quick access to Home, Insights, Transactions, and Budgets.
- **Redesigned Screens**:
  - **Dashboard**: Features a hero balance card, a dynamic donut chart for budget consumption, and newly designed transaction rows.
  - **Insights**: Reimagined with AI Insights toggle, dynamic segment charts, and detailed categorized spend breakdowns.
  - **Add Transaction**: Modernized with a bottom-anchored numeric keypad, pill toggles for expense/income, and clean date selectors.
  - **Create Recurring Payment**: Redesigned to support the bottom-anchored numeric keypad with an inline scrollable properties form.

### Fixed
- **Database Schema Validation**: Fixed a bug where creating transactions with certain newly added categories (like `cat_misc` or `cat_health`) would throw a foreign key constraint error. These categories are now safely seeded during the app's startup health check.
- **App Lock Background Behaviour**: Fixed an issue where the app lock did not correctly lock on cold start and challenge the user upon returning from the background by implementing a `refreshListenable` with `ChangeNotifier`.
- **Recurring Transactions Logic**: Connected the UI to the actual recurring payment functionality, allowing users to correctly add a recurring payment.
- **Recent Transactions UI**: Improved the recent transactions display to include transaction dates.
