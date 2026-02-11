# 💳 Credit Scoring App

A comprehensive Flutter-based credit scoring and loan application platform with ML-powered risk assessment, real-time notifications, and secure authentication.

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

This credit scoring application provides users with instant credit limit calculations and personalized loan terms based on machine learning models. The app integrates with a Python-based Credit Scoring API (v2.0) that uses **XGBoost** for risk assessment and credit scoring.

### Key Capabilities

- 📊 **ML-Powered Credit Scoring**: XGBoost model trained on comprehensive financial data
- 💰 **Instant Loan Limit Calculation**: Real-time credit limit assessment
- 📱 **Multi-Step Loan Application**: Streamlined user experience with progress tracking
- 🔐 **Secure Authentication**: Email/password and Google OAuth with biometric support
- 🔔 **Real-Time Notifications**: Firebase Cloud Messaging integration
- 📈 **Application Tracking**: Complete loan application history and status monitoring

---

## ✨ Features

### 🔐 Authentication & Security

- **Email/Password Authentication** with email verification
- **Google OAuth Integration** for seamless sign-in
- **Biometric Authentication** (fingerprint/face ID) using `local_auth` package
- **Password Reset** via email-based flow
- **Email Verification** required before login
- **Secure Password Change** functionality
- **Biometric Preferences** stored in Firestore

### 💳 Loan Application Flow

**Step 1: Purpose Selection**
- Choose loan purpose (vehicle, education, home improvement, etc.)
- Input desired loan amount

**Step 2: Personal Information**
- Monthly income input with currency formatting
- Years employed
- Years of credit history
- Real-time validation

**Step 3: Credit Limit Calculation**
- API integration with `/api/calculate-limit` endpoint
- Display approved credit limit
- Show personalized loan terms (amount, interest rate, monthly payment)

### 📊 Dashboard Features

- **Application History**: View all past loan applications
- **Notification Center**: Real-time updates on application status
- **Profile Management**: Update personal information
- **Security Settings**: Manage password and biometric authentication

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

### Data Flow

```
User Input → ViewModel → API Service → Credit Scoring API (Python)
                ↓
         Firestore Database
                ↓
         Real-time Updates → UI
```

### System Architecture

The application follows a **client-server architecture**:

1. **Flutter Frontend**: Cross-platform mobile application
2. **Firebase Backend**: Authentication, Firestore database, Cloud Messaging
3. **Python API**: Credit scoring engine with XGBoost ML model
4. **Data Pipeline**: Feature engineering and model training infrastructure

---

## 🛠️ Technology Stack

### Frontend (Flutter)

- **Framework**: Flutter 3.x
- **State Management**: Provider pattern with ViewModels
- **UI Components**: Material Design 3
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Notifications**: Firebase Cloud Messaging
- **Biometrics**: `local_auth` package
- **HTTP Client**: `http` package

### Backend (Python API)

- **Framework**: Flask
- **ML Model**: XGBoost
- **Data Processing**: Pandas, NumPy
- **Model Format**: Pickle serialization
- **Security**: API key authentication, rate limiting
- **Deployment**: Cloud-ready with health check endpoint

### Database Schema

**Users Collection**
- `uid`, `email`, `displayName`, `photoURL`
- `createdAt`, `lastLogin`
- `biometricEnabled`, `notificationsEnabled`

**Loan Applications Collection**
- `userId`, `purpose`, `requestedAmount`
- `monthlyIncome`, `yearsEmployed`, `yearsOfCreditHistory`
- `approvedLimit`, `interestRate`, `monthlyPayment`
- `status`, `createdAt`, `updatedAt`

**Notifications Collection**
- `userId`, `title`, `message`, `type`
- `isRead`, `createdAt`, `applicationId`

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or higher)
- Dart SDK
- Firebase project with:
  - Authentication enabled (Email/Password, Google)
  - Firestore database
  - Cloud Messaging
- Python 3.8+ (for API)
- Credit Scoring API running and accessible

### Installation

**Step 1: Clone the Repository**

```bash
git clone <repository-url>
cd creditscoringapp
```

**Step 2: Install Dependencies**

```bash
flutter pub get
```

**Step 3: Firebase Configuration**

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android/iOS apps to your Firebase project
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place configuration files in appropriate directories
5. Enable Authentication methods (Email/Password, Google)
6. Create Firestore database with security rules

**Step 4: Configure API Endpoint**

Update the API URL in your configuration:

```dart
// lib/services/api_service.dart
static const String baseUrl = 'YOUR_API_URL';
static const String apiKey = 'YOUR_API_KEY';
```

**Step 5: Run the Application**

```bash
flutter run
```

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

### Authentication Security

✅ **Email Verification Required**: Users must verify email before accessing the app  
✅ **Secure Password Storage**: Firebase Auth handles password hashing  
✅ **Password Reset Flow**: Email-based password reset (no OTP)  
✅ **Google OAuth**: Secure third-party authentication  
✅ **Session Management**: Automatic token refresh and expiration  

### Biometric Authentication

✅ **Local Authentication**: Fingerprint and Face ID support  
✅ **Preference Storage**: Biometric settings stored in Firestore  
✅ **Fallback Options**: Password authentication always available  
✅ **Device Security**: Leverages platform-native biometric APIs  

### Data Security

✅ **Firestore Security Rules**: Role-based access control  
✅ **API Key Protection**: Secure API communication  
✅ **HTTPS Only**: All network requests encrypted  
✅ **Input Sanitization**: Protection against injection attacks  

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /loan_applications/{applicationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

---

## 📊 Data Pipeline

### Feature Engineering

The ML model uses 64 engineered features derived from:

- **Application Data**: Income, employment history, credit history
- **Bureau Data**: Credit bureau reports and scores
- **Credit Card Balance**: Payment patterns and utilization
- **Installment Payments**: Historical payment behavior

### Model Training

- **Algorithm**: XGBoost Classifier
- **Optimization**: Threshold tuning for precision (0.860)
- **Validation**: Cross-validation and holdout testing
- **Format**: Serialized pickle model

### Data Dictionaries

Comprehensive data dictionaries available in `docs/data-dictionaries/`:

- `application_train_features.md`
- `bureau_features.md`
- `credit_card_balance_features.md`
- `installments_payments_features.md`

---

## 🔄 Recent Development

### Latest Updates (February 2026)

#### ✅ Security Enhancements
- Implemented real password change functionality
- Added biometric authentication with `local_auth` package
- Integrated biometric preferences with Firestore
- Updated login page to support biometric login

#### ✅ API Integration Improvements
- Migrated to Credit Scoring API v2.0
- Implemented two-step API flow (calculate-limit → calculate-terms)
- Removed deprecated `loan_tier` and `tier_reason` fields
- Updated UI to reflect new API response structure

#### ✅ Bug Fixes
- Fixed monthly income input not updating ViewModel
- Resolved API memory issues causing crashes
- Fixed infinite loop on HomePage causing excessive Firebase queries
- Corrected password reset logic for users with multiple auth providers

#### ✅ Documentation
- Created comprehensive data dictionaries for all datasets
- Generated architecture diagrams (data pipeline, ERD, workflow)
- Updated README with complete feature documentation

#### ✅ UI/UX Improvements
- Enhanced README with icons and visual elements
- Improved form validation and error handling
- Added currency formatting for monetary inputs
- Implemented loading states and progress indicators

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
