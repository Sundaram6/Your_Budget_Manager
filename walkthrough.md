# Walkthrough — Phase 4: Recurring Transactions & Notification Listener Engine

Phase 4 (Recurring Transactions & Android Notification Listener Service & Floating Confirmation Sheet & Final Integration Setup) has been fully implemented, verified with automated unit and widget tests, validated with zero compilation errors, and integrated into **Your Budget Manager**.

## Key Changes Accomplished

### Phase 4A: Database Schema Upgrade (DB Version 4)
- **`lib/database/tables/recurring_transactions_table.dart`**: Created `RecurringTransactionsTable` with 16 columns (`id`, `title`, `amount_paise`, `category_id`, `type`, `frequency`, `interval_days`, `start_date`, `end_date`, `next_due_date`, `last_generated_date`, `is_active`, `auto_confirm`, `notes`, `created_at`, `updated_at`).
- **`lib/database/tables/transactions_table.dart`**: Added `is_recurring`, `recurring_id`, `is_auto_captured`, and `source_app`.
- **`lib/database/app_database.dart`**: Upgraded DB `schemaVersion` to 4 and added auto-migrations with defensive `try/catch` column additions.
- **`lib/models/recurring_transaction.dart`**: Created `RecurringTransactionModel` Freezed model.

### Phase 4B: Recurring Engine
- **`lib/engine/recurring_engine.dart`**: Implemented `processDueRecurring()`, `_processSingle()`, `_calculateNextDue()` (with leap year and end-of-month handling), and `forceGenerate()`.
- **`lib/database/database_helper.dart`**: Created singleton wrapper for raw query streams, transaction creation, and date updates.

### Phase 4C: Background Worker via WorkManager
- Added `workmanager: ^0.10.6` to `pubspec.yaml`.
- **`lib/main.dart`**: Added top-level `@pragma('vm:entry-point')` `callbackDispatcher()` and scheduled 6-hour periodic task `'recurring-check'`.
- **`android/app/src/main/AndroidManifest.xml`**: Added `SystemJobService` receiver and `InitializationProvider`.

### Phase 4D & 4E: Recurring UI & Creation Screen
- **`lib/repositories/recurring_repository.dart`**: CRUD repository with live `watchAll()` stream.
- **`lib/screens/recurring/recurring_list_screen.dart`**: Stream-driven list screen with dark theme, frequency badges, empty state, and FAB.
- **`lib/screens/recurring/create_recurring_screen.dart`**: Form screen with title, amount in rupees (paise conversion), type toggle, category dropdown, frequency picker with custom interval days, start/end date pickers, auto-confirm toggle, and save logic.

### Phase 4F: Android Native Notification Listener Service
- **`android/app/src/main/kotlin/com/ybm/your_budget_manager/PaymentNotificationListener.kt`**:
  - Whitelisted 30+ major Indian payment & banking apps (Google Pay, PhonePe, Paytm, Amazon Pay, CRED, WhatsApp, BHIM UPI, SuperMoney, etc.).
  - On-device regex parsing for amount, merchant name, UTR / reference IDs, and income/expense categorization.
  - MethodChannel dispatch (`"com.ybm.your_budget_manager/notification_listener"`).
- **`MainActivity.kt`**: Mapped MethodChannel handlers for `"isNotificationAccessGranted"` and `"openNotificationSettings"`.
- **`AndroidManifest.xml`**: Registered `PaymentNotificationListener` service and permissions.

### Phase 4G: Flutter Notification Service & Router
- **`lib/services/notification_reader_service.dart`**: MethodChannel listener parsing native map payloads into `PaymentNotificationData`.
- **`lib/services/notification_router.dart`**: In-memory `pendingNotification` queue with smart auto-categorization (`Zomato`/`Swiggy` $\rightarrow$ `cat_food`, `Amazon`/`Flipkart` $\rightarrow$ `cat_shopping`, `Uber`/`Ola` $\rightarrow$ `cat_transport`, etc.).

### Phase 4H: Onboarding Step 5 — Notification Permission Screen
- **`lib/screens/onboarding/notification_permission_screen.dart`**: Onboarding Step 5 screen featuring dark UI (`#0D0D0D`, `#D4AF37` gold accent), payment app chips, privacy disclaimer, dynamic permission polling, and onboarding completion persistence.
- Integrated into `lib/features/onboarding/presentation/screens/onboarding_screen.dart`.

### Phase 4I: Floating Transaction Confirmation Sheet
- **`lib/widgets/notification_transaction_sheet.dart`**: Modal bottom sheet for caught payment notifications featuring:
  - Drag handle & header (tinted expense/income arrow icon, payment status label, formatted amount in bold white text).
  - Details card (Payment App name, Merchant/Party, UTR/Reference ID).
  - Action buttons: `"Ignore"` (outlined, clears pending) and `"Add to Budget"` (gold background `#D4AF37`, inserts auto-categorized transaction into SQLite DB, clears pending, closes sheet, and shows gold SnackBar).

### Phase 4J: Final Integration and Testing Setup
- **`lib/main.dart`**: Wired `RecurringEngine.processDueRecurring()` immediately after `DatabaseHealthCheck`, initialized `NotificationReaderService.instance.initialize()` early in lifecycle, and added the comprehensive **Phase 4 Testing Checklist** in source comments.
- **`lib/screens/settings/notification_settings_screen.dart`**: Created notification settings screen with permission status card, category toggles (UPI Apps, Digital Wallets, Banking SMS), SharedPreferences persistence (`pref_notify_upi`, `pref_notify_wallets`, `pref_notify_banking`), and local privacy disclaimer.
- **`lib/features/dashboard/presentation/screens/dashboard_screen.dart`**:
  - Added AppBar action buttons for direct navigation to `RecurringListScreen` and `NotificationSettingsScreen`.
  - Integrated dynamic `"X Recurring Due Today"` gold summary card when active due transactions exist.
- **`lib/routing/app_router.dart` & `SettingsScreen`**: Registered `/notification-settings` route and added `"Payment Notifications"` tile to `SettingsScreen`.

---

## Verification Protocol Results

### Automated Tests Passed
- `test/models/recurring_transaction_model_test.dart`: **PASSED**
- `test/engine/recurring_engine_test.dart`: **PASSED**
- `test/screens/recurring/recurring_list_screen_test.dart`: **PASSED**
- `test/screens/recurring/create_recurring_screen_test.dart`: **PASSED**
- `test/services/notification_router_test.dart`: **PASSED**
- `test/screens/onboarding/notification_permission_screen_test.dart`: **PASSED**
- `test/widgets/notification_transaction_sheet_test.dart`: **PASSED**
