# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Interactive & Customizable Analytics Charts (Phase 28)**:
  - Added tap-to-drill-down functionality to category breakdown donut and pie charts across Insights and Analytics screens.
  - Introduced `CategoryTransactionsSheet` showing period-scoped transactions, transaction counts, and category totals with nested transaction detail viewing.
  - Added category visibility customization (`CategoryFilterDialog` & interactive legend toggle chips) allowing users to hide/show specific categories.
  - Integrated dynamic percentage recalculation so visible categories' percentages always sum to 100%.
  - Added cross-session persistence for hidden categories using `SharedPreferences` via Riverpod `analyticsHiddenCategoriesProvider`.
- **Budget Health Score & Survival Mode (Phase 27)**:
  - Re-engineered `IntelligenceEngine.calculateBudgetHealthScore` with 4 explicit scoring bands: Healthy (80–100), Caution (50–79), Over-Budget (0–49), and Severely Over-Budget (< 0 to -100).
  - Added multi-factor adjustments for recurring fixed-cost burden, daily allowance pressure, and savings discipline.
  - Added automated "Survival Mode" spending-reduction alerts on the Dashboard, Budget Settings, and Insights screens when spending exceeds budget limits.
- **Self-Transfer Detection & Counterpart Management (Phase 23 & 24)**:
  - Added automated self-transfer detection engine linking transfer debit and credit pairs.
  - Added exclusion of linked transfers from expense and income totals to prevent artificial budget inflation.
  - Added transfer badge, counterpart navigation, and unlink transfer actions to `TransactionDetailSheet`.
  - Added backup/restore support for linked transfers with full roundtrip integrity.
- **Credit Transaction Tracking (Phase 22)**:
  - Enhanced merchant engine to detect and process credit transactions, refunds, and salary credits with merchant transparency.
- **V2 "Friendly Finance" Redesign & Design System**:
  - Playful, modern design system featuring floating rounded navigation bar, large hero typography, and 8px grid alignment.
  - Complete dark and light theme tokens with WCAG AAA contrast ratio compliance.
  - Accessibility-first animations honoring `prefers-reduced-motion`.

### Fixed
- **Settings Screen Reachability Audit (Phase 26)**:
  - Fixed an issue where the "About App" item at the bottom of the Settings screen was obscured by the floating navigation bar by applying appropriate bottom safe insets and scroll physics.
- **Transaction Detail Sheet Pixel Overflow (Phase 25)**:
  - Fixed vertical layout overflow in `TransactionDetailSheet` by converting rigid column structures to scrollable views with responsive constraints.
- **Quick-Add FAB Clearance (Phase 19)**:
  - Fixed FAB positioning and padding to prevent obstruction by the floating bottom navigation shell.
- **Hero Balance Card & Budget Settings Layouts (Phases 17 & 18)**:
  - Fixed keyboard insets and layout overflows on small viewports in `BudgetSettingsScreen`.
- **App Lock Lifecycle & PIN Security (Phase 21)**:
  - Hardened app lock state machine, biometric authentication callbacks, and background return challenge triggers.
- **Database Schema Validation & Foreign Key Seeding**:
  - Seeded missing default categories (`cat_misc`, `cat_health`, etc.) during startup health check to prevent foreign key constraint violations.
- **Recurring Transactions Execution**:
  - Connected UI forms to the underlying recurring transaction engine and month-rollover scheduler.
