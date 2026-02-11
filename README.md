<div align="center">

# Credit Scoring App

**AI-Powered Mobile Loan Application Platform**

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Ready-FFCA28?logo=firebase&logoColor=black)
![LightGBM](https://img.shields.io/badge/LightGBM-ML-02D9F7?logo=lightgbm&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material-Design%203-757575?logo=material-design&logoColor=white)

📱 [Download APK](#) • 📚 [Documentation](#-documentation) • 🚀 [Getting Started](#-getting-started)

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Architecture](#-architecture)
- [Technology Stack](#-technology-stack)
- [Getting Started](#-getting-started)
- [API Integration](#-api-integration)
- [Security Features](#-security-features)
- [Data Pipeline](#-data-pipeline)
- [Recent Development](#-recent-development)
- [Documentation](#-documentation)

---

## 🎯 Overview

This credit scoring application provides users with instant credit limit calculations and personalized loan terms based on machine learning models. The app integrates with a Python-based Credit Scoring API (v1.0) that uses **LightGBM** for risk assessment and credit scoring.

### Key Capabilities

- 📊 **ML-Powered Credit Scoring**: LightGBM model trained on comprehensive financial data
- 💰 **Instant Loan Limit Calculation**: Real-time credit limit assessment
- 📱 **Multi-Step Loan Application**: Streamlined user experience with progress tracking
- 🔐 **Secure Authentication**: Email/password and Google OAuth with biometric support
- 🔔 **Real-Time Notifications**: Firebase Cloud Messaging integration
- 📈 **Application Tracking**: Complete loan application history and status monitoring

### 📱 App Screenshots

<!-- TODO: Add app screenshots here -->
<!-- Recommended screenshots:
- Login/Signup screens
- Home dashboard
- Loan application flow (Step 1, 2, 3)
- Application history
- Profile and settings
- Notification center
-->

---

## ✨ Features

### 🔐 Authentication & Security

| Feature | Description |
|---------|-------------|
| 📧 **Email/Password** | Secure authentication with mandatory email verification |
| 🔑 **Google OAuth** | One-tap sign-in with Google account |
| 👆 **Biometric Login** | Fingerprint & Face ID support via `local_auth` |
| 🔄 **Password Reset** | Email-based password recovery (no OTP) |
| ✉️ **Email Verification** | Required before accessing the app |
| 🔒 **Password Change** | Secure in-app password update |
| 💾 **Preferences Sync** | Biometric settings stored in Firestore |

### 💳 Loan Application Flow

> **Two pathways to get your credit score and loan limit**

#### **Choose Your Path**

<table>
<tr>
<td width="50%" valign="top">

**🎫 eKYC Verification**
- ✅ Full verification process
- 🆔 Auto-filled personal data
  - Name, DOB, Address
  - ID card number
- 📊 Complete credit scoring
- 💯 Higher loan limits

</td>
<td width="50%" valign="top">

**🧪 Simulation Mode**
- � Quick estimation
- ✏️ Manual data entry
- � Simulated credit score
- 💡 No commitment required

</td>
</tr>
</table>

---

#### � **Step-by-Step Process**

**Step 1️: Initial Setup**
- Choose verification method (eKYC or Simulation)
- If eKYC: Auto-populate verified data
- If Simulation: Proceed with manual entry

**Step 2️: Personal Information**
- 💵 **Monthly Income** - with currency formatting
- 👔 **Employment Status** - dropdown selection (Employed, Self-employed, etc.)
- � **Years Employed** - work experience
- 🏠 **Home Ownership** - Rent, Own, Mortgage, etc.
- 📍 **Current Address** - residential information
- 📊 **Credit History** - optional for new borrowers
  - Years of credit history
  - Previous defaults (if any)
  - Current default status

**Step 3️: Processing & Scoring** ⏳
- 🔄 Application submitted to API
- 🤖 LightGBM model analyzes your data
- 📊 Credit score calculated
- 💰 Loan limit determined
- � Navigate to Home page
- ⏱️ Wait for scoring completion
- 🔔 Receive notification when ready

**Step 4️: Additional Information** (Optional - for loan application)
- 🏢 **Employment Details**
  - Employer name
  - Job title
  - Work phone number
  - Years at current employer
- 🆘 **Emergency Contact**
  - Contact name
  - Phone number
  - Relationship
- 👥 **References** (optional)

**Step 5️: Loan Offer**
- 🎯 **Choose Loan Purpose**
  - 🚗 Vehicle
  - 🎓 Education
  - � Home improvement
  - 💼 Business
  - 🛍️ Personal
- 💰 **Enter Loan Amount** (within your limit)
- � **View Loan Terms**
  - Interest rate
  - Loan term (ký hạn)
  - Monthly payment
  - Total amount
- ✅ **Accept Offer** and complete application

### 📊 Dashboard Features

| Feature | What You Can Do |
|---------|-----------------|
| 📜 **Application History** | View all past loan applications with status tracking |
| 🔔 **Notification Center** | Get real-time updates on your applications |
| 👤 **Profile Management** | Update personal information anytime |
| 🛡️ **Security Settings** | Manage passwords and biometric authentication |

---

## 🏗️ Architecture

### Application Structure

```
lib/
├── models/          # Data models (User, Loan, Notification)
├── services/        # Firebase, API, and authentication services
├── viewmodels/      # State management (MVVM pattern)
├── views/           # UI screens and components
│   ├── auth/        # Login, signup, password reset
│   ├── home/        # Dashboard and navigation
│   ├── loan/        # Multi-step loan application
│   ├── profile/     # User profile and settings
│   └── security/    # Security and biometric settings
└── widgets/         # Reusable UI components
```

### 📊 Architecture Diagrams

<!-- TODO: Add architecture diagrams here -->
<!-- Recommended diagrams:
- System Architecture Diagram (Flutter App ↔ Firebase ↔ Python API)
- Data Flow Diagram (User Input → Processing → Response)
- Database ERD (Users, Loan Applications, Notifications)
- Loan Application Workflow (Step-by-step user journey)
- Data Pipeline (Raw Data → Feature Engineering → ML Model)
-->

---

## 🛠️ Technology Stack

### 📱 Frontend (Flutter)

| Category | Technology |
|----------|------------|
| 🎯 **Framework** | Flutter 3.x |
| 🔄 **State Management** | Provider pattern with ViewModels (MVVM) |
| 🎨 **UI Components** | Material Design 3 |
| 🔐 **Authentication** | Firebase Auth |
| 💾 **Database** | Cloud Firestore |
| 🔔 **Notifications** | Firebase Cloud Messaging (FCM) |
| 👆 **Biometrics** | `local_auth` package |
| 🌐 **HTTP Client** | `http` package |

### 🐍 Backend (Python API)

| Category | Technology |
|----------|------------|
| ⚡ **Framework** | Flask |
| 🤖 **ML Model** | LightGBM Classifier |
| 📊 **Data Processing** | Pandas, NumPy |
| 💾 **Model Format** | Pickle serialization |
| 🔒 **Security** | API key authentication, rate limiting |
| ☁️ **Deployment** | Cloud-ready with health check endpoint |

### 🗄️ Database Schema

<table>
<tr>
<td width="33%" valign="top">

**👥 Users Collection**
```
uid
email
displayName
photoURL
createdAt
lastLogin
biometricEnabled
notificationsEnabled
```

</td>
<td width="33%" valign="top">

**💳 Loan Applications**
```
userId
purpose
requestedAmount
monthlyIncome
yearsEmployed
yearsOfCreditHistory
approvedLimit
interestRate
monthlyPayment
status
createdAt
updatedAt
```

</td>
<td width="33%" valign="top">

**🔔 Notifications**
```
userId
title
message
type
isRead
createdAt
applicationId
```

</td>
</tr>
</table>

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have:

- ✔️ **Flutter SDK** (3.x or higher)
- ✔️ **Dart SDK**
- ✔️ **Firebase project** with:
  - 🔐 Authentication enabled (Email/Password, Google)
  - 💾 Firestore database
  - 🔔 Cloud Messaging
- ✔️ **Python 3.8+** (for API)
- ✔️ **Credit Scoring API** running and accessible

---

### 📦 Installation

#### **Step 1️: Clone the Repository**

```bash
git clone <repository-url>
cd creditscoringapp
```

#### **Step 2️: Install Dependencies**

```bash
flutter pub get
```

> 💡 This will download all required Flutter packages

#### **Step 3️: Firebase Configuration**

1. 🌐 Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. 📱 Add Android/iOS apps to your Firebase project
3. 📥 Download configuration files:
   - `google-services.json` (Android) → `android/app/`
   - `GoogleService-Info.plist` (iOS) → `ios/Runner/`
4. 🔐 Enable Authentication methods:
   - Email/Password
   - Google Sign-In
5. 💾 Create Firestore database
6. 🛡️ Set up Firestore security rules (see [Security Features](#-security-features))

#### **Step 4️: Configure API Endpoint**

Update the API URL in your configuration:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'YOUR_API_URL';
static const String apiKey = 'YOUR_API_KEY';
```

> ⚠️ **Important**: Never commit your API key to version control!

#### **Step 5️: Run the Application**

```bash
flutter run
```

> 🎉 **Success!** Your app should now be running on your device/emulator

---

## 🔌 API Integration

### Credit Scoring API v2.0

The application integrates with a Python-based Credit Scoring API that provides two main endpoints:

#### 1. Calculate Credit Limit

**Endpoint**: `POST /api/calculate-limit`

**Request Body**:
```json
{
  "monthly_income": 50000000,
  "years_employed": 5,
  "years_of_credit_history": 3
}
```

**Response**:
```json
{
  "credit_limit": 150000000,
  "credit_score": 750
}
```

#### 2. Calculate Loan Terms

**Endpoint**: `POST /api/calculate-terms`

**Request Body**:
```json
{
  "credit_limit": 150000000,
  "requested_amount": 100000000,
  "purpose": "vehicle"
}
```

**Response**:
```json
{
  "approved_amount": 100000000,
  "interest_rate": 12.5,
  "monthly_payment": 8500000,
  "term_months": 12
}
```

#### 3. Health Check

**Endpoint**: `GET /api/health`

**Response**:
```json
{
  "status": "healthy",
  "model_loaded": true
}
```

### API Security

- **API Key Authentication**: All protected endpoints require `X-API-Key` header
- **Rate Limiting**: Prevents abuse and ensures fair usage
- **Input Validation**: Server-side validation of all request parameters
- **Error Handling**: Comprehensive error responses with appropriate HTTP status codes

---

## 🔒 Security Features

### 🔐 Authentication Security

| Security Feature | Implementation |
|------------------|----------------|
| ✉️ **Email Verification** | Users must verify email before accessing the app |
| 🔒 **Password Storage** | Firebase Auth handles secure password hashing |
| 🔄 **Password Reset** | Email-based password reset (no OTP) |
| 🔑 **Google OAuth** | Secure third-party authentication |
| ⏱️ **Session Management** | Automatic token refresh and expiration |

### 👆 Biometric Authentication

| Feature | Details |
|---------|---------|
| 📱 **Local Authentication** | Fingerprint and Face ID support |
| 💾 **Preference Storage** | Biometric settings stored in Firestore |
| 🔄 **Fallback Options** | Password authentication always available |
| 🛡️ **Device Security** | Leverages platform-native biometric APIs |

### 🛡️ Data Security

| Protection Layer | Description |
|------------------|-------------|
| 🔐 **Firestore Security Rules** | Role-based access control |
| 🔑 **API Key Protection** | Secure API communication |
| 🌐 **HTTPS Only** | All network requests encrypted |
| 🧹 **Input Sanitization** | Protection against injection attacks |

### 📜 Firestore Security Rules

> **Example security rules to protect user data**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Users can only access their own loan applications
    match /loan_applications/{applicationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    
    // Users can only access their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

> ⚠️ **Important**: Deploy these rules to your Firebase project to ensure data security!

---

## 📊 Data Pipeline

### 🤖 ML Model Overview

| Component | Details |
|-----------|----------|
| **Algorithm** | LightGBM Classifier |
| **Features** | 64 engineered features |
| **Optimization** | Threshold tuning (0.860 precision) |
| **Validation** | Cross-validation + holdout testing |
| **Format** | Pickle serialization |

### 📚 Data Dictionaries

Comprehensive feature documentation available in `docs/data-dictionaries/`:

- 📄 `application_train_features.md`
- 📄 `bureau_features.md`
- 📄 `credit_card_balance_features.md`
- 📄 `installments_payments_features.md`

---

## 🔄 Recent Development

### 📅 Latest Updates (February 2026)

<table>
<tr>
<td width="50%" valign="top">

#### 🔐 Security Enhancements
- Real password change functionality
- Biometric authentication (`local_auth`)
- Biometric preferences in Firestore
- Biometric login support

#### 🔌 API Integration
- Migrated to API v2.0
- Two-step API flow
- Removed deprecated fields
- Updated UI for new API

</td>
<td width="50%" valign="top">

#### 🐛 Bug Fixes
- Monthly income input fix
- API memory issues resolved
- HomePage infinite loop fixed
- Password reset logic corrected

#### 📚 Documentation
- Data dictionaries created
- Architecture diagrams
- Complete README update

</td>
</tr>
</table>

#### 🎨 UI/UX Improvements
- Enhanced README with icons and visual elements
- Improved form validation and error handling
- Added currency formatting for monetary inputs
- Implemented loading states and progress indicators

<!-- TODO: Add before/after UI screenshots here -->
<!-- Recommended screenshots:
- Updated security page with biometric toggle
- Loan application form with currency formatting
- Loading states and progress indicators
- Error handling examples
-->

---

## 📚 Documentation

### Available Documentation

- **README.md**: This file - comprehensive project overview
- **Data Dictionaries**: Feature documentation in `docs/data-dictionaries/`
- **Architecture Diagrams**: System design and data flow visualizations
- **API Documentation**: Endpoint specifications and examples

### Diagrams

The project includes the following architectural diagrams:

1. **Data Pipeline Diagram**: Shows data flow from raw data to ML model
2. **ERD (Entity Relationship Diagram)**: Database schema and relationships
3. **Workflow Diagram**: User journey and application flow

---

## 🤝 Contributing

This is a private project. For questions or issues, please contact the development team.

---

## 📄 License

Proprietary - All rights reserved

---

## 🎓 Learning Resources

If you're new to Flutter development:

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.google.com/docs/flutter/setup)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Last Updated**: February 2026  
**Version**: 2.0  
**Status**: Active Development
