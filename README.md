<div align="center">

# Credit Scoring App

**AI-Powered Mobile Loan Application Platform — Vietnamese Market**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Ready-FFCA28?logo=firebase&logoColor=black)
![XGBoost](https://img.shields.io/badge/XGBoost-ML-EC4E20)
![GCP](https://img.shields.io/badge/GCP-Cloud%20Run-4285F4?logo=google-cloud&logoColor=white)
![Material Design](https://img.shields.io/badge/Material-Design%203-757575?logo=material-design&logoColor=white)

📚 [Documentation](#-documentation) • 🚀 [Getting Started](#-getting-started) • 🔌 [API Reference](#-api-integration)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Getting Started](#-getting-started)
- [API Integration](#-api-integration)
- [Student Loan Flow](#-student-loan-flow)
- [Security Features](#-security-features)
- [Data Pipeline](#-data-pipeline)
- [Firebase Cloud Functions](#-firebase-cloud-functions)
- [Recent Development](#-recent-development)
- [Documentation](#-documentation)

---

## 🎯 Overview

This credit scoring application provides Vietnamese users with instant credit limit calculations and loan terms based on machine learning models. The app integrates with a Python-based **Credit Scoring API v2.0** (hosted on **Google Cloud Run**) that uses **XGBoost** for risk assessment, with credit score calibration tuned for the Vietnamese market.

### Key Capabilities

- 📊 **ML-Powered Credit Scoring**: XGBoost model with non-linear score calibration (300–850 range)
- 💰 **Instant Loan Limit Calculation**: Real-time credit limit in VND with risk-based approval
- 📱 **6-Step Loan Application**: End-to-end application with eKYC, employment info, banking details
- 🔐 **Secure Authentication**: Email/password, Google OAuth, Phone OTP, and biometric login
- 🔔 **Push Notifications**: Firebase Cloud Functions dispatch FCM notifications server-side
- 💬 **In-App Support**: Live support chat and structured feedback system
- 📈 **Application Tracking**: Complete history with status monitoring

---

## ✨ Features

### 🔐 Authentication & Security

| Feature | Description |
|---------|-------------|
| 📧 **Email/Password** | Secure login with mandatory email verification |
| 🔑 **Google OAuth** | One-tap sign-in via Google account |
| 📱 **Phone / OTP** | Phone number login with OTP verification |
| 👆 **Biometric Login** | Fingerprint & Face ID via `local_auth` |
| 🔄 **Password Reset** | Email-based password recovery |
| 🔒 **Password Change** | Secure in-app password update |
| 💾 **Preferences Sync** | Biometric & notification settings stored in Firestore |

---

### 💳 Loan Application Flow

> **Two pathways to get your credit score and loan limit**

<table>
<tr>
<td width="50%" valign="top">

**🎫 eKYC Verification**
- ✅ Full verification process
- 🆔 ID card capture + selfie
- 📊 Auto-filled personal data (name, DOB, address)
- 💯 Higher loan limits

</td>
<td width="50%" valign="top">

**🧪 Simulation Mode**
- ⚡ Quick estimation
- ✏️ Manual data entry
- 🎯 Simulated credit score
- 💡 No commitment required

</td>
</tr>
</table>

---

#### 📋 **Complete 6-Step Loan Process**

**Step 1 — ID Capture (eKYC)**
- 📸 Capture or upload ID card photo
- 🤳 Selfie liveness check
- 🔄 Auto-populate personal data from eKYC result
- 📝 eKYC logs & images stored in Firestore

**Step 2 — Personal Information**
- 💵 Monthly income (with VND currency formatting)
- 👔 Employment status (Employed, Self-employed, Unemployed, etc.)
- 📅 Years employed
- 🏠 Home ownership type (Rent, Own, Mortgage, etc.)
- 📊 Credit history (years, previous defaults, current defaulting status)

**Step 3 — Employment & References**
- 🏢 Employer name, job title, work phone, years at employer
- 🆘 Emergency contact (name, phone, relationship)
- 👥 References (optional)

**Step 4 — Loan Offer Calculator** *(API v2.0 two-step flow)*
- 🤖 **Step 4a**: `POST /api/calculate-limit` — XGBoost scores the profile, returns credit score + loan limit
- 🏦 **Step 4b**: `POST /api/calculate-terms` — Calculates interest rate, term, monthly payment for chosen amount
- 🎯 Choose loan purpose (Vehicle, Education, Home Improvement, Business, Personal)
- 💰 Enter desired loan amount (capped at approved limit)
- 📜 View full breakdown: interest rate, term, monthly payment, total payable

**Step 5 — Contract Review**
- 📄 Full loan contract displayed for review
- ✅ Accept & digitally confirm terms

**Step 6 — Disbursement**
- 🏦 Enter bank account details (bank name, account number, holder name)
- ✔️ Bank account validation via `POST /api/validate-bank-account`
- 💸 Confirm disbursement instructions

---

### 📊 Dashboard & Account Features

| Feature | Description |
|---------|-------------|
| 📜 **Application History** | All past loan applications with status tracking |
| 🔔 **Notification Center** | Real-time push notifications from Cloud Functions |
| 👤 **Profile Management** | View and update personal information |
| 🛡️ **Security Settings** | Manage password, biometric auth, and linked accounts |
| 💬 **Support Chat** | Live in-app chat with support staff |
| 📝 **Feedback System** | Categorized feedback submission and tracking |
| 📄 **Privacy Policy** | In-app legal documentation |

---

## 🏗️ Architecture

### Application Structure

```
lib/
├── auth/            # Login, Signup, OTP, Password Reset, Email Verification
├── config/          # App-wide configuration and constants
├── home/            # Home dashboard and navigation
├── loan/            # 6-step loan application flow
│   ├── step1_id_capture.dart
│   ├── step1_selfie.dart
│   ├── step2_personal_info.dart
│   ├── step3_employment_info.dart
│   ├── step3_references_info.dart
│   ├── step4_offer_calculator.dart
│   ├── step5_contractreview.dart
│   ├── step6_disbursement.dart
│   ├── student_hub_page.dart
│   ├── student_verification_gate_page.dart
│   ├── student_step_1_profile.dart
│   ├── student_step_2_financial.dart
│   └── student_step_3_result.dart
├── models/          # Data models (User, Loan, Notification, BankAccount)
├── onboarding/      # First-run onboarding screens
├── services/        # Firebase, API, and notification services
├── settings/        # Profile, Security, Notifications, Support, Feedback
├── utils/           # Utility functions (formatting, validators)
├── viewmodels/      # State management (MVVM pattern with Provider)
└── widgets/         # Reusable UI components
```

### System Architecture

```
┌─────────────────────────────────────────────┐
│            Flutter Mobile App               │
│  (Android / iOS — MVVM + Provider)          │
└──────────────┬──────────────────┬───────────┘
               │                  │
    ┌──────────▼──────┐  ┌────────▼──────────────┐
    │   Firebase Suite │  │  Python API (GCP Cloud │
    │  - Auth          │  │  Run — API v2.0)       │
    │  - Firestore     │  │  - /calculate-limit    │
    │  - Storage       │  │  - /calculate-terms    │
    │  - Messaging     │  │  - /validate-bank-acct │
    │  - Functions     │  │  - /apply (legacy)     │
    └──────────────────┘  └────────────────────────┘
               │
    ┌──────────▼──────────────────┐
    │  Firebase Cloud Functions   │
    │  (asia-southeast1)          │
    │  - dispatchNotificationPush │
    └─────────────────────────────┘
```

---

## 🛠️ Technology Stack

### 📱 Frontend (Flutter)

| Category | Technology |
|----------|------------|
| 🎯 **Framework** | Flutter 3.x / Dart SDK ^3.10 |
| 🔄 **State Management** | Provider + MVVM ViewModels |
| 🎨 **UI** | Material Design 3 |
| 🔐 **Auth** | Firebase Auth (Email, Google, Phone) |
| 💾 **Database** | Cloud Firestore |
| 📦 **Storage** | Firebase Storage (eKYC images) |
| 🔔 **Notifications** | FCM + `flutter_local_notifications` |
| 👆 **Biometrics** | `local_auth` |
| 🌐 **HTTP** | `http` package with retry logic |
| 🔑 **Secrets** | `flutter_dotenv` + `flutter_secure_storage` |
| 📷 **Camera** | `camera` + `image_picker` |
| 📞 **Phone Input** | `intl_phone_field` |

### 🐍 Backend (Python API)

| Category | Technology |
|----------|------------|
| ⚡ **Framework** | Flask |
| 🤖 **ML Model** | XGBoost Classifier |
| 📊 **Data Processing** | Pandas, NumPy |
| 🏦 **Score Calibration** | Non-linear probability-to-score mapping (300–850) |
| 🚧 **Hard Caps** | Business rules for defaults, age, income (Vietnamese market) |
| 🔒 **Auth** | Firebase ID Token (Bearer) verification |
| ☁️ **Hosting** | Google Cloud Run |

### ☁️ Firebase & Cloud

| Service | Purpose |
|---------|---------|
| **Firebase Auth** | User authentication and identity |
| **Cloud Firestore** | All app data (users, applications, notifications, chats) |
| **Firebase Storage** | eKYC images |
| **Firebase Messaging** | Push notification delivery |
| **Cloud Functions v2** | Server-side FCM dispatch (`asia-southeast1`) |

### 🗄️ Firestore Collections

<table>
<tr>
<td width="33%" valign="top">

**👥 users**
```
uid
email
displayName
photoURL
fcmToken
biometricEnabled
notificationsEnabled
role (user | support)
createdAt / lastLogin
```

</td>
<td width="33%" valign="top">

**💳 credit_applications**
```
userId
monthlyIncome
employmentStatus
yearsEmployed
homeOwnership
yearsCreditHistory
hasPreviousDefaults
currentlyDefaulting
creditScore
loanLimitVnd
riskLevel
approved
status
createdAt / updatedAt
```

</td>
<td width="33%" valign="top">

**🔔 notifications**
```
userId
title / body
type
isRead
shouldSendPush
pushStatus (pending|sent|failed)
pushMessageId
applicationId
createdAt / updatedAt
```

</td>
</tr>
<tr>
<td valign="top">

**🏦 loan_offers**
```
userId
applicationId
loanAmountVnd
interestRate
loanTermMonths
monthlyPaymentVnd
totalPaymentVnd
loanPurpose
status
createdAt
```

</td>
<td valign="top">

**💬 support_chats / messages**
```
userId
status
createdAt
[messages subcollection]
  - senderId
  - message
  - isStaff
  - timestamp
```

</td>
<td valign="top">

**📝 feedback**
```
userId / userName / userEmail
category
subject / message
status
createdAt / updatedAt
```

</td>
</tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

- ✔️ **Flutter SDK** 3.x (`dart sdk ^3.10`)
- ✔️ **Firebase project** with Auth, Firestore, Storage, Messaging, Functions enabled
- ✔️ **Python 3.8+** for the Credit Scoring API
- ✔️ **Google Cloud Run** project for API hosting

---

### 📦 Installation

#### **Step 1 — Clone the Repository**

```bash
git clone <repository-url>
cd creditscoringapp
```

#### **Step 2 — Install Flutter Dependencies**

```bash
flutter pub get
```

#### **Step 3 — Firebase Configuration**

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps → download config files:
   - `google-services.json` → `android/app/`
   - `GoogleService-Info.plist` → `ios/Runner/`
3. Enable: **Email/Password**, **Google Sign-In**, **Phone** authentication
4. Create **Firestore** database and **Firebase Storage** bucket
5. Enable **Firebase Cloud Messaging**
6. Deploy Firestore security rules: `firebase deploy --only firestore:rules`
7. Deploy Cloud Functions: `cd functions && npm install && firebase deploy --only functions`

#### **Step 4 — Configure Environment Variables**

Copy `.env_sample` to `.env` and fill in your values:

```env
API_BASE_URL=https://swincredit.duckdns.org/api
# Optional fallback for older builds
GCP_API_URL=https://swincredit.duckdns.org/api
API_KEY=<your-backend-api-key-if-required>
VNPT_ACCESS_TOKEN=<legacy-token-if-needed>
```

> ⚠️ **Never commit `.env` to version control!** It is already in `.gitignore`.

#### **Step 5 — Run the Application**

```bash
flutter run
```

---

## 🔌 API Integration

### Credit Scoring API v2.0 (Two-Step Flow)

Primary scoring requests send a fresh **Firebase ID token** in `Authorization: Bearer <token>`.
If configured, the app also sends `X-API-Key` from secure storage or `.env`.

#### Step 1 — Calculate Credit Limit

**`POST /api/calculate-limit`**

```json
// Request
{
  "full_name": "Nguyen Van A",
  "age": 30,
  "monthly_income": 15000000,
  "employment_status": "Employed",
  "years_employed": 3.0,
  "home_ownership": "Rent",
  "years_credit_history": 2.0,
  "has_previous_defaults": false,
  "currently_defaulting": false
}

// Response
{
  "credit_score": 680,
  "loan_limit_vnd": 120000000,
  "risk_level": "Medium",
  "approved": true,
  "message": "Application approved"
}
```

> 🏦 Credit scores are calibrated to a 300–850 range using a non-linear probability mapping. Business hard caps apply for defaults, age, and income thresholds.

#### Step 2 — Calculate Loan Terms

**`POST /api/calculate-terms`**

```json
// Request
{
  "loan_amount": 80000000,
  "loan_purpose": "vehicle",
  "credit_score": 680
}

// Response
{
  "loan_amount_vnd": 80000000,
  "loan_purpose": "vehicle",
  "interest_rate": 13.5,
  "loan_term_months": 36,
  "monthly_payment_vnd": 2720000,
  "total_payment_vnd": 97920000,
  "total_interest_vnd": 17920000,
  "rate_explanation": "...",
  "term_explanation": "..."
}
```

#### Bank Account Validation

**`POST /api/validate-bank-account`**

```json
// Request
{
  "bank_name": "Vietcombank",
  "account_number": "1234567890",
  "account_holder": "NGUYEN VAN A"
}
```

#### Health Check

**`GET /api/health`** — Returns `{ "status": "healthy", "model_loaded": true }`

#### Legacy Endpoint (Deprecated)

**`POST /api/apply`** — One-step loan application, kept for backward compatibility.

---

## 🎓 Student Loan Flow

The app includes a dedicated student loan pathway under the Student tab.

### Student Path (3 Steps)

1. **Verification Gate**
  - Student email/domain verification and document upload checks.
2. **Step 1 — Profile**
  - Captures student profile attributes (school, major, academic info).
3. **Step 2 — Financial**
  - Captures financial indicators and computes student scoring outcomes.
4. **Step 3 — Result**
  - Displays student credit score and official student loan limit.

### Student API Endpoints

- **`POST /api/student/credit-score`**
  - Step 1 scoring-only endpoint for student profiles.
- **`POST /api/student/calculate-limit`**
  - Step 2 endpoint returning score + official student limit.

All student scoring calls use the same auth model as the main flow:
- `Authorization: Bearer <firebase-id-token>`
- Optional `X-API-Key` when configured

---

## 🔒 Security Features

### Authentication

| Layer | Implementation |
|-------|---------------|
| **Email Verification** | Required before app access |
| **Firebase Auth** | Handles password hashing, token management, OAuth |
| **ID Token Auth** | All API calls send fresh Firebase ID tokens (`forceRefresh: true`) |
| **Biometrics** | Platform-native fingerprint/Face ID via `local_auth` |
| **Secure Storage** | Sensitive values in `flutter_secure_storage` |
| **Environment Secrets** | API URL and tokens in `.env`, excluded from VCS |

### Firestore Security Rules

The deployed `firestore.rules` enforces:
- **Users** → read/write own document only
- **Credit Applications** → read/write own applications only
- **Notifications** → CRUD own notifications only
- **Loan Offers** → read/write with subcollection access control
- **Feedback** → create/read own; support staff can update
- **Support Chats** → user + support staff access; message subcollection guarded
- **eKYC Logs/Images** → authenticated users only

---

## 📊 Data Pipeline

### ML Model Overview

| Component | Details |
|-----------|---------|
| **Algorithm** | XGBoost Classifier |
| **Features** | 64 engineered features |
| **Score Range** | 300–850 (non-linear calibration) |
| **Market Tuning** | Hard caps for Vietnamese risk factors (defaults, low income, age) |
| **Optimization** | Threshold tuning (0.860 precision) |
| **Validation** | Cross-validation + holdout testing |
| **Format** | Pickle serialization |

### Score Calibration Logic

Raw XGBoost probability is mapped to the 300–850 credit score range using a **non-linear transformation** so that the score distribution is realistic for the Vietnamese lending market:
- High-risk profiles (defaults, very low income) → hard-capped at lower bands
- Medium-risk → scores in 580–680 range
- Low-risk → scores in 720–850 range

### Integration References

Available integration docs in this repository:

- 📄 `docs/APP_INTEGRATION_GUIDE_VI.md`
- 📄 `docs/VNPT_SETUP.md`
- 📄 `docs/api_vnpt_docs.pdf`
- 📁 `docs/diagrams/`

---

## 🔔 Firebase Cloud Functions

Deployed to **`asia-southeast1`** using Firebase Functions v2.

### `dispatchNotificationPush`

**Trigger**: `onDocumentCreated` on `notifications/{notificationId}`

**Behavior**:
1. Checks `shouldSendPush === true` and `pushStatus === "pending"`
2. Uses a Firestore transaction to atomically claim the job (prevents duplicate sends)
3. Fetches the user's `fcmToken` from Firestore
4. Sends FCM message via Firebase Admin SDK with high-priority Android/APNS config
5. Updates `pushStatus` to `sent` or `failed` with error details
6. Auto-clears invalid FCM tokens from user documents

---

## 🔄 Recent Development

### 📅 Latest Updates (March 2026)

<table>
<tr>
<td width="50%" valign="top">

#### 🏦 Credit Score Calibration
- Non-linear probability-to-score mapping
- Hard caps for Vietnamese market risk factors
- Score range aligned to 300–850 standard
- Business rules for defaults, age, income

#### 🔌 API v2.0 Two-Step Flow
- Separated `/calculate-limit` and `/calculate-terms`
- Firebase ID token auth (replaces API key)
- Migration to Google Cloud Run
- Bank account validation endpoint

</td>
<td width="50%" valign="top">

#### 💬 Support & Feedback
- Live support chat with staff role
- Structured feedback submission system
- Privacy policy page
- Support staff admin view

#### 🔐 Security & Auth
- Phone/OTP login
- Biometric auth (fingerprint + Face ID)
- Secure `.env` configuration
- Firestore role-based access (user/support)

</td>
</tr>
</table>

#### 🔔 Cloud Functions
- Server-side FCM push notification dispatch
- Idempotent transaction-based processing
- Automatic invalid token cleanup

#### 📱 Full 6-Step Loan Flow
- eKYC ID capture + selfie verification
- Employment & references collection
- Loan offer calculator with real-time API scoring
- Contract review + digital acceptance
- Bank account validation before disbursement

---

## 📚 Documentation

| Document | Location |
|----------|----------|
| **README** | This file |
| **App Integration Guide** | `docs/APP_INTEGRATION_GUIDE_VI.md` |
| **VNPT Setup Guide** | `docs/VNPT_SETUP.md` |
| **VNPT API Reference (PDF)** | `docs/api_vnpt_docs.pdf` |
| **Architecture Diagrams** | `docs/diagrams/` |
| **Firestore Rules** | `firestore.rules` |
| **Storage Rules** | `storage.rules` |
| **Cloud Functions** | `functions/index.js` |
| **Environment Sample** | `.env_sample` |

---

## 🤝 Contributing

This is a private project. For questions or issues, please contact the development team or use the in-app support chat.

---

## 📄 License

Proprietary — All rights reserved

---

**Last Updated**: April 2026
**Version**: 2.0
**Status**: Active Development
**API**: v2.0 on Google Cloud Run
