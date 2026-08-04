# Manual Verification Checklist — Phase 4: Recurring Transactions & Notification Engine

Use this checklist to manually test and verify all Phase 4 features of **Your Budget Manager** on an Android device or emulator.

---

## 📱 Test Section 1: Onboarding Step 5 (Notification Permission)

- [ ] **1.1 Trigger Onboarding**
  - Open **Settings** $\rightarrow$ Tap **Replay Onboarding** (or **Reset Onboarding**).
  - Verify Onboarding Page 1 launches.

- [ ] **1.2 Verify Page 5 Layout**
  - Swipe to Page 5 (Step 5 of 5).
  - Confirm Title: **"Never miss a transaction"**.
  - Confirm Privacy Subtitle: *"All processing happens on your device — nothing leaves your phone."*
  - Confirm Payment App Chips (Google Pay, PhonePe, Paytm, CRED, WhatsApp, BHIM, etc.) render with gold icons.

- [ ] **1.3 Grant Notification Access**
  - Tap **"Grant Access"**.
  - System Notification Access settings screen should open.
  - Enable access for **Your Budget Manager** and press back.
  - Confirm green success banner appears: *"Notification access granted. You're all set!"*
  - Confirm main button text changes to **"Continue"**.

- [ ] **1.4 Complete Onboarding**
  - Tap **"Continue"** (or **"Skip for now"**).
  - Confirm app navigates to Dashboard (`/`).
  - Kill and restart app; confirm app opens straight to Dashboard/PIN without repeating onboarding.

---

## 🔁 Test Section 2: Recurring Transactions Engine & UI

- [ ] **2.1 Access Recurring Transactions**
  - From Dashboard AppBar, tap the **Repeat icon** (`Icons.repeat`).
  - Confirm empty state appears if no recurring items exist (*"No recurring transactions yet"*).

- [ ] **2.2 Create Past-Dated Recurring Item**
  - Tap the Gold **+ FAB**.
  - Title: `Netflix Subscription`
  - Amount: `649`
  - Type: `Expense`
  - Category: `Entertainment`
  - Frequency: `Monthly`
  - Start Date: Set to **Yesterday** (or past date).
  - Auto-confirm: `ON`
  - Tap **Save**. Item should appear in list with red `MONTHLY` badge.

- [ ] **2.3 Cold-Start Auto-Generation**
  - Force close/kill the app.
  - Re-open app.
  - Check **Recent Transactions** on Dashboard.
  - Confirm a generated transaction for `Netflix Subscription` (₹649) has been added automatically.

- [ ] **2.4 Dashboard "Recurring Due Today" Summary Card**
  - Create a recurring transaction starting **Today**.
  - Return to Dashboard.
  - Confirm a gold-bordered card titled **"1 Recurring Due Today"** appears above total spend.
  - Tap **View** $\rightarrow$ Confirm navigation to Recurring List screen.

---

## 🔔 Test Section 3: Notification Listener & Floating Confirmation Sheet

- [ ] **3.1 Notification Settings Screen**
  - Open **Settings** $\rightarrow$ Tap **Payment Notifications**.
  - Confirm Status: **"Notification Listener Active"** with green checkmark.
  - Confirm toggles exist for **UPI Payment Apps**, **Digital Wallets**, and **Banking SMS**.
  - Confirm privacy box at bottom: *"Budget Manager only reads notifications from selected payment apps..."*

- [ ] **3.2 Payment Detection & Floating Bottom Sheet**
  - Trigger a UPI payment notification (via Google Pay, PhonePe, Paytm, CRED, etc.) or send a test payment notification to your phone.
  - Confirm a dark modal bottom sheet titled **"Payment Detected"** / **"Money Received"** slides up on the Dashboard within 1-2 seconds.
  - Confirm sheet shows:
    - Arrow icon (Red upward for expense, Green downward for income).
    - Payment App name (e.g. PhonePe).
    - Formatted Amount in large white bold text (e.g. `₹150`).
    - Merchant/Party name (e.g. `Swiggy`).
    - Reference / UTR ID (if present).

- [ ] **3.3 Test "Ignore" Action**
  - On the bottom sheet, tap **Ignore**.
  - Sheet should dismiss, pending notification is cleared, and NO transaction is created.

- [ ] **3.4 Test "Add to Budget" Action**
  - Trigger another payment notification.
  - Tap **Add to Budget**.
  - Sheet dismisses and gold SnackBar appears: **"Transaction saved"**.
  - Check **Recent Transactions**: Confirm transaction is created with auto-categorization (e.g. Swiggy $\rightarrow$ Food, Uber $\rightarrow$ Transport), `isAutoCaptured=true`, and source app recorded.

---

## 📦 APK Location
- Debug APK Path: `build/app/outputs/flutter-apk/app-debug.apk`
