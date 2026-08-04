# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Recurring Transactions**: Added UI for managing recurring payments (subscriptions, EMIs, etc.). Added FAB options to quickly add standard or recurring transactions.
- **Biometric Authentication**: Implemented PIN and Biometric app lock on app launch and resume for enhanced security.
- **Category Engine Fixes**: Added 'Miscellaneous' and 'Health & Medical' default categories to properly handle uncategorized expenses and EMI payments.
- **Recent Transactions UI**: Improved the recent transactions display to include transaction dates.

### Fixed
- **Database Schema Validation**: Fixed a bug where creating transactions with certain newly added categories (like `cat_misc` or `cat_health`) would throw a foreign key constraint error. These categories are now safely seeded during the app's startup health check.
- **App Lock Background Behaviour**: Fixed an issue where the app lock did not correctly challenge the user upon returning from the background.
