Thông tin tổng quan do AI tạo
Tài liệu tập trung vào chi tiết kỹ thuật API eKYC VNPT, bao gồm các endpoint upload ảnh và bóc tách thông tin giấy tờ.

---
name: credit-scoring
description: Expert skill for Credit Scoring project covering Flutter mobile app, FastAPI backend, LightGBM/XGBoost ML models, Firebase integration, and GCP deployment. USE FOR: app development, API endpoints, ML model training/retraining, feature engineering, data pipeline work, deployment, eKYC integration, authentication, Firestore queries, loan application flow, debugging integration issues. Includes common commands, project structure, and best practices.
---

# Credit Scoring Project Expert

## Overview

This skill provides comprehensive knowledge for working with the Credit Scoring project - an AI-powered loan application platform with Flutter mobile app, Python FastAPI backend, and LightGBM/XGBoost ML models.

### System Components

- **Flutter App**: Cross-platform mobile app (iOS/Android/Web) with Provider state management, Firebase Auth, eKYC integration
- **FastAPI Backend**: Python REST API with FastAPI, authentication, rate limiting, CORS
- **ML Models**: LightGBM classifier (64 features) for credit scoring
- **Firebase**: Auth (Email/Google/Biometric), Firestore database, Storage, FCM notifications
- **GCP Deployment**: Cloud Run (API), Cloud Functions (data export), Cloud Scheduler (retraining)
- **eKYC**: VNPT eKYC API integration for identity verification (OCR, face matching)

### When to Use This Skill

✅ Building or debugging the Flutter mobile app  
✅ Working with API endpoints (calculate-limit, calculate-terms)  
✅ Training or retraining ML models  
✅ Feature engineering (transforming 9 inputs → 64 features)  
✅ Firebase integration (Auth, Firestore, Storage)  
✅ Deploying to GCP (Cloud Run, Cloud Functions)  
✅ Understanding application flow (eKYC vs Simulation)  
✅ Troubleshooting integration issues  

---

## Project Structure

```
credit-scoring/
├── credit-scoring-api/          # FastAPI backend
│   ├── app/
│   │   ├── api/                 # API endpoints (routes.py)
│   │   ├── auth/                # Authentication & security
│   │   ├── core/                # Config, logging, security
│   │   ├── models/              # Pydantic request/response models
│   │   ├── services/            # Business logic (prediction, scoring)
│   │   └── utils/               # Helper functions
│   ├── pipeline/                # ML retraining pipeline
│   │   ├── retrain_job.py       # Main training orchestration
│   │   ├── feature_engineering.py  # Feature creation (64 features)
│   │   └── config.py            # Pipeline configuration
│   ├── models/                  # Trained model files
│   ├── tests/                   # API tests
│   └── requirements.txt         # Python dependencies
├── cloud-functions/
│   └── firestore-exporter/      # Export Firestore data to GCS
├── notebooks/                   # Jupyter notebooks for experiments
│   ├── base_model/              # Original XGBoost experiments
│   └── alternative_model/       # LightGBM experiments
├── data/                        # Training data
│   ├── Home_credit_default_risk/  # Primary dataset
│   ├── altdata/                 # Alternative data sources
│   └── processed/               # Feature-engineered datasets
├── scripts/                     # Data validation scripts
└── docs/                        # API documentation
```

---

## API Architecture

### Tech Stack
- **Framework**: FastAPI 0.104+ (async Python web framework)
- **ML**: LightGBM 4.1.0, XGBoost 2.0.2, scikit-learn 1.3.2
- **Data**: Pandas 2.1.3, NumPy 1.26.2
- **Security**: API key authentication, rate limiting (slowapi), CORS
- **Deployment**: Docker, GCP Cloud Run

### Key Endpoints

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|---------------|
| `/api/calculate-limit` | POST | Calculate credit score & loan limit | API Key |
| `/api/calculate-terms` | POST | Calculate loan terms (interest, monthly payment) | API Key |
| `/api/predict` | POST | Direct ML model prediction | API Key |
| `/api/health` | GET | Health check | Public |
| `/docs` | GET | Swagger API docs | Public |

### Request Flow
```
Client → CORS Middleware → Rate Limiter → API Key Auth → Route Handler → ML Service → Response
```

---

## ML Model Details

### Model Type
- **Primary**: LightGBM Classifier (gradient boosting)
- **Alternative**: XGBoost Classifier
- **Performance**: 72% ROC-AUC, 68% accuracy

### Features (64 total)
- Demographics: age, income, employment status, years employed
- Credit history: years of history, previous defaults, current defaults
- Home ownership: own, rent, mortgage
- Loan details: purpose (HOME, CAR, BUSINESS, EDUCATION, PERSONAL)

### Training Pipeline
1. **Data Export**: Firestore → GCS (Cloud Function, weekly)
2. **Feature Engineering**: `feature_engineering.py` (64 features)
3. **Model Training**: `retrain_job.py` (LightGBM with optuna tuning)
4. **Evaluation**: Compare vs production (AUC threshold ≥2% improvement)
5. **Deployment**: Auto-promote to production if better

### Model Files
- Training: `notebooks/base_model/03_modeling/`
- Production: `credit-scoring-api/models/`
- Artifacts: `output/models/`

---

## Common Commands

### API Development

```bash
# Start API locally
cd credit-scoring-api
uvicorn app.main:app --reload --port 8000

# Start with Docker
docker-compose up -d

# Run tests
pytest tests/ -v

# Test prediction endpoint
python test_api.py

# Test security
python test_security.py
```

### Model Training

```bash
# Run retraining pipeline locally
cd credit-scoring-api/pipeline
python retrain_job.py

# Deploy retraining job to GCP
./deploy.sh  # Linux/Mac
.\deploy.ps1  # Windows
```

### GCP Deployment

```bash
# Deploy API to Cloud Run
cd credit-scoring-api
./deploy-gcp.sh

# Deploy Firestore exporter function
cd cloud-functions/firestore-exporter
./deploy.sh

# Set up Cloud Scheduler (retraining)
gcloud scheduler jobs create http retrain-weekly \
  --schedule="0 2 * * 0" \
  --uri="https://retrain-job-url" \
  --http-method=POST
```

### Data Processing

```bash
# Validate telco churn data
python scripts/validate_telco_data.py

# Run feature engineering
cd credit-scoring-api/pipeline
python feature_engineering.py
```

---

## Configuration

### Environment Variables (.env)

**API (credit-scoring-api/.env)**:
```bash
# API Configuration
PROJECT_NAME="Credit Scoring API"
VERSION="2.0.0"
ENVIRONMENT="production"
API_PREFIX="/api"

# Security
API_KEY="your-api-key-here"
ALLOWED_ORIGINS="https://your-domain.com,http://localhost:3000"

# Model
MODEL_PATH="models/lightgbm_model.pkl"
```

**Pipeline (credit-scoring-api/pipeline/config.py)**:
```python
GCP_PROJECT_ID = "your-project-id"
GCS_BUCKET = "retrain"
MODEL_PATH_STAGING = "models/staging/"
MODEL_PATH_PRODUCTION = "models/production/"
```

---

## Flutter App Architecture

> **Note**: The Flutter app source code is in a separate repository. This section documents the app architecture, integration patterns, and expected behavior based on specifications in the `app/` documentation folder.

### Tech Stack

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| **Framework** | Flutter | 3.x | Cross-platform (iOS/Android/Web) |
| **Language** | Dart | 3.10+ | Programming language |
| **State Management** | Provider | 6.1.1 | MVVM pattern |
| **Authentication** | Firebase Auth | 5.3.3 | Email/Password, Google OAuth, Biometric |
| **Database** | Cloud Firestore | 5.5.2 | NoSQL cloud database |
| **Storage** | Firebase Storage | 12.3.6 | Document/image storage |
| **Push Notifications** | FCM | - | Real-time notifications |
| **HTTP Client** | http | 1.2.0 | API communication |
| **Biometrics** | local_auth | - | Fingerprint/Face ID |
| **Secure Storage** | flutter_secure_storage | 9.0.0 | Encrypted local storage |
| **Environment Config** | flutter_dotenv | 5.1.0 | Environment variables |

### MVVM Architecture Pattern

```
lib/
├── views/              # UI screens (Widgets)
│   ├── auth/          # Login, register, forgot password
│   ├── home/          # Dashboard, profile
│   ├── application/   # Loan application flow
│   └── settings/      # User preferences
├── viewmodels/         # Business logic (ChangeNotifier)
│   ├── auth_viewmodel.dart
│   ├── application_viewmodel.dart
│   └── loan_viewmodel.dart
├── models/             # Data models
│   ├── user.dart
│   ├── loan_application.dart
│   └── credit_result.dart
├── services/           # External services
│   ├── api_service.dart        # API client
│   ├── firebase_service.dart   # Firebase integration
│   └── ekyc_service.dart       # VNPT eKYC
└── utils/              # Helpers, constants
    ├── validators.dart
    ├── formatters.dart
    └── constants.dart
```

### Application Flow

#### 1. Authentication Flow
```
Splash Screen → Login/Register → Email Verification → Home Dashboard
                    ↓
              Google OAuth → Home Dashboard
                    ↓
              Biometric Login → Home Dashboard
```

**Authentication Methods**:
- **Email/Password**: Requires email verification
- **Google OAuth**: One-tap sign-in
- **Biometric**: Fingerprint/Face ID (after initial login)

#### 2. Loan Application Flow (Two Pathways)

**Pathway A: eKYC Verification (Verified Users)**
```
Home Dashboard → Select eKYC
    ↓
Capture ID Card (Front) → OCR Extraction
    ↓
Capture ID Card (Back) → OCR Extraction
    ↓
Capture Selfie → Face Matching
    ↓
Personal Info (Auto-filled) → Review & Edit
    ↓
Submit to API → Credit Scoring
    ↓
Results Screen → Notification
    ↓
Select Loan Purpose → Enter Amount
    ↓
Calculate Terms → Review Offer
    ↓
Accept → Application Complete
```

**Pathway B: Simulation Mode (Demo)**
```
Home Dashboard → Select Simulation
    ↓
Personal Info (Manual Entry)
    ↓
Submit to API → Credit Scoring
    ↓
Results Screen → Notification
    ↓
Select Loan Purpose → Enter Amount
    ↓
Calculate Terms → Review Offer
    ↓
Accept → Application Complete
```

#### 3. Application Status Lifecycle
```dart
enum ApplicationStatus {
  none,        // No application submitted
  processing,  // Waiting for API response
  scored,      // Credit scoring completed
  rejected     // Application rejected
}
```

### API Integration

#### API Client Implementation
```dart
// services/api_service.dart
class ApiService {
  final String baseUrl = 'https://credit-scoring-api.onrender.com/api';
  
  // Calculate Credit Limit
  Future<CreditResult> calculateLimit({
    required String fullName,
    required int age,
    required double monthlyIncome,
    required String employmentStatus,
    required double yearsEmployed,
    required String homeOwnership,
    double yearsCreditHistory = 0,
    bool hasPreviousDefaults = false,
    bool currentlyDefaulting = false,
  }) async {
    // Get Firebase ID token
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);
    
    final response = await http.post(
      Uri.parse('$baseUrl/calculate-limit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'full_name': fullName,
        'age': age,
        'monthly_income': monthlyIncome,
        'employment_status': employmentStatus,
        'years_employed': yearsEmployed,
        'home_ownership': homeOwnership,
        'years_credit_history': yearsCreditHistory,
        'has_previous_defaults': hasPreviousDefaults,
        'currently_defaulting': currentlyDefaulting,
      }),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return CreditResult.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
  
  // Calculate Loan Terms
  Future<LoanTerms> calculateTerms({
    required double loanAmount,
    required String loanPurpose,
    required int creditScore,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken(true);
    
    final response = await http.post(
      Uri.parse('$baseUrl/calculate-terms'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'loan_amount': loanAmount,
        'loan_purpose': loanPurpose,
        'credit_score': creditScore,
      }),
    ).timeout(Duration(seconds: 30));
    
    if (response.statusCode == 200) {
      return LoanTerms.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(response.statusCode, response.body);
    }
  }
}
```

#### Retry Logic
```dart
// Automatic retry for transient failures
Future<T> withRetry<T>(Future<T> Function() operation) async {
  const maxAttempts = 3;
  const delay = Duration(seconds: 2);
  
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await operation();
    } catch (e) {
      if (attempt == maxAttempts || !isRetryable(e)) {
        rethrow;
      }
      await Future.delayed(delay);
    }
  }
  throw Exception('Max retries exceeded');
}

bool isRetryable(dynamic error) {
  // Retry on network errors and 5xx server errors
  if (error is SocketException) return true;
  if (error is ApiException && error.statusCode >= 500) return true;
  return false;
}
```

### Firebase Integration

#### Firestore Collections Schema

**users/{userId}**
```dart
{
  'userId': String,              // Firebase UID
  'email': String,
  'fullName': String,
  'phoneNumber': String?,
  'biometricEnabled': bool,
  'notificationEnabled': bool,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
}
```

**loan_applications/{applicationId}**
```dart
{
  // User Information
  'userId': String,              // Firebase UID
  'fullName': String,
  'age': int,                    // 18-100
  'phoneNumber': String,
  'idNumber': String?,           // From eKYC
  'address': String,
  
  // Financial Information
  'monthlyIncome': double,       // VND
  'employmentStatus': String,    // EMPLOYED, SELF_EMPLOYED, UNEMPLOYED
  'yearsEmployed': double,
  'homeOwnership': String,       // RENT, OWN, MORTGAGE, LIVING_WITH_PARENTS
  
  // Credit History
  'yearsCreditHistory': double,
  'hasPreviousDefaults': bool,
  'currentlyDefaulting': bool,
  
  // Loan Details
  'loanPurpose': String,         // HOME, CAR, BUSINESS, EDUCATION, PERSONAL
  'requestedAmount': double,     // VND
  
  // Credit Scoring Results
  'creditScore': int,            // 0-1000
  'loanLimit': double,           // VND
  'riskLevel': String,           // LOW, MEDIUM, HIGH
  'approved': bool,
  
  // Loan Terms
  'interestRate': double?,       // %
  'loanTermMonths': int?,
  'monthlyPayment': double?,
  'totalPayment': double?,
  'totalInterest': double?,
  
  // Metadata
  'verificationType': String,    // EKYC or SIMULATION
  'status': String,              // none, processing, scored, rejected
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
}
```

**notifications/{notificationId}**
```dart
{
  'userId': String,
  'title': String,
  'body': String,
  'type': String,                // application_update, system
  'read': bool,
  'applicationId': String?,
  'createdAt': Timestamp,
}
```

#### Firestore Queries

```dart
// Get user's applications
Stream<List<LoanApplication>> getUserApplications(String userId) {
  return FirebaseFirestore.instance
    .collection('loan_applications')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => LoanApplication.fromFirestore(doc))
      .toList());
}

// Get latest application
Future<LoanApplication?> getLatestApplication(String userId) async {
  final snapshot = await FirebaseFirestore.instance
    .collection('loan_applications')
    .where('userId', isEqualTo: userId)
    .orderBy('createdAt', descending: true)
    .limit(1)
    .get();
    
  return snapshot.docs.isEmpty 
    ? null 
    : LoanApplication.fromFirestore(snapshot.docs.first);
}

// Update application status
Future<void> updateApplicationStatus(
  String applicationId, 
  String status
) async {
  await FirebaseFirestore.instance
    .collection('loan_applications')
    .doc(applicationId)
    .update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
}
```

### State Management with Provider

```dart
// viewmodels/application_viewmodel.dart
class ApplicationViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final FirebaseService _firebaseService;
  
  ApplicationStatus _status = ApplicationStatus.none;
  CreditResult? _creditResult;
  LoanTerms? _loanTerms;
  String? _error;
  
  ApplicationStatus get status => _status;
  CreditResult? get creditResult => _creditResult;
  LoanTerms? get loanTerms => _loanTerms;
  String? get error => _error;
  
  // Calculate credit limit
  Future<void> calculateCreditLimit({
    required String fullName,
    required int age,
    required double monthlyIncome,
    required String employmentStatus,
    required double yearsEmployed,
    required String homeOwnership,
    double yearsCreditHistory = 0,
    bool hasPreviousDefaults = false,
    bool currentlyDefaulting = false,
  }) async {
    _status = ApplicationStatus.processing;
    _error = null;
    notifyListeners();
    
    try {
      _creditResult = await _apiService.calculateLimit(
        fullName: fullName,
        age: age,
        monthlyIncome: monthlyIncome,
        employmentStatus: employmentStatus,
        yearsEmployed: yearsEmployed,
        homeOwnership: homeOwnership,
        yearsCreditHistory: yearsCreditHistory,
        hasPreviousDefaults: hasPreviousDefaults,
        currentlyDefaulting: currentlyDefaulting,
      );
      
      // Save to Firestore
      await _firebaseService.saveLoanApplication(_creditResult!);
      
      _status = _creditResult!.approved 
        ? ApplicationStatus.scored 
        : ApplicationStatus.rejected;
      
      notifyListeners();
    } catch (e) {
      _status = ApplicationStatus.none;
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Calculate loan terms
  Future<void> calculateLoanTerms({
    required double loanAmount,
    required String loanPurpose,
  }) async {
    if (_creditResult == null) {
      _error = 'No credit score available';
      notifyListeners();
      return;
    }
    
    try {
      _loanTerms = await _apiService.calculateTerms(
        loanAmount: loanAmount,
        loanPurpose: loanPurpose,
        creditScore: _creditResult!.creditScore,
      );
      
      // Update Firestore with loan terms
      await _firebaseService.updateLoanTerms(_loanTerms!);
      
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
```

### VNPT eKYC Integration

```dart
// services/ekyc_service.dart
class EkycService {
  final String apiKey = 'VNPT_EKYC_API_KEY';
  final String baseUrl = 'https://api.ekyc.vnpt.vn';
  
  // OCR ID Card
  Future<Map<String, dynamic>> extractIdCard(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ocr/id-card'),
    );
    
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      return {
        'fullName': data['fullName'],
        'idNumber': data['idNumber'],
        'dateOfBirth': data['dateOfBirth'],
        'address': data['address'],
        'issueDate': data['issueDate'],
        'issuePlace': data['issuePlace'],
      };
    } else {
      throw EkycException('OCR failed');
    }
  }
  
  // Face Matching
  Future<bool> compareFaces(File idPhoto, File selfie) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/face/compare'),
    );
    
    request.headers['Authorization'] = 'Bearer $apiKey';
    request.files.add(await http.MultipartFile.fromPath('photo1', idPhoto.path));
    request.files.add(await http.MultipartFile.fromPath('photo2', selfie.path));
    
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      return data['similarity'] >= 0.8; // 80% threshold
    } else {
      throw EkycException('Face matching failed');
    }
  }
}
```

### Common Flutter Commands

```bash
# Install dependencies
flutter pub get

# Run app (debug mode)
flutter run

# Run on specific device
flutter run -d chrome           # Web
flutter run -d <device-id>      # iOS/Android

# Build release APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Clean build
flutter clean && flutter pub get

# Configure Firebase
flutterfire configure
```

---

## Common Development Scenarios

### Scenario 1: Add New API Endpoint

**Steps**:
1. **Define Pydantic models** in `credit-scoring-api/app/models/`
2. **Create route handler** in `credit-scoring-api/app/api/routes.py`
3. **Add business logic** in `credit-scoring-api/app/services/`
4. **Add authentication** using `api_key_auth` dependency
5. **Test endpoint** with `test_api.py`
6. **Update Flutter** API service to call new endpoint

**Example**:
```python
# app/api/routes.py
@router.post("/new-endpoint", dependencies=[Depends(api_key_auth)])
async def new_endpoint(request: NewRequest) -> NewResponse:
    result = await service.process(request)
    return NewResponse(**result)
```

### Scenario 2: Update ML Model Features

**Steps**:
1. **Update feature engineering** in `pipeline/feature_engineering.py`
2. **Update feature count** (if changed from 64)
3. **Retrain model** with new features
4. **Update API** feature preparation in `services/prediction_service.py`
5. **Test predictions** with sample data
6. **Deploy** new model to production

**Critical**: Ensure training and inference use SAME feature engineering logic

### Scenario 3: Add New Flutter Screen

**Steps**:
1. **Create View** in `lib/views/<feature>/new_screen.dart`
2. **Create ViewModel** in `lib/viewmodels/new_screen_viewmodel.dart`
3. **Add route** in `lib/routes.dart`
4. **Register Provider** in `main.dart`
5. **Add navigation** from existing screens
6. **Test UI** on multiple devices

**Example**:
```dart
// viewmodels/new_screen_viewmodel.dart
class NewScreenViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    // Fetch data
    
    _isLoading = false;
    notifyListeners();
  }
}

// views/new_screen.dart
class NewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NewScreenViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(title: Text('New Screen')),
          body: viewModel.isLoading 
            ? CircularProgressIndicator()
            : YourContent(),
        );
      },
    );
  }
}
```

### Scenario 4: Debug API Integration Issue

**Checklist**:
1. **Check Firebase Auth**: Token valid and not expired?
2. **Check API URL**: Correct base URL in `.env`?
3. **Check Request Format**: Match API spec exactly?
4. **Check Response Parsing**: JSON structure correct?
5. **Check Network**: Internet connected?
6. **Check Logs**: API logs (`gcloud run logs`) and Flutter console

**Common Causes**:
- Expired Firebase token → Use `getIdToken(forceRefresh: true)`
- Wrong API endpoint URL → Verify `.env` configuration
- Missing required fields → Check Pydantic validation errors
- CORS issues → Verify allowed origins in API config
- Timeout → Increase timeout duration or check API performance

### Scenario 5: Deploy New Model to Production

**Steps**:
1. **Train and evaluate** model locally
2. **Save model** with timestamp: `model_20260312_143000.pkl`
3. **Upload to GCS**: `gs://bucket/models/staging/`
4. **Test in staging** environment
5. **Compare metrics** with current production model
6. **If better**: Promote to `gs://bucket/models/production/`
7. **Update API** to load new model (or auto-reload)
8. **Monitor** predictions and error rates
9. **Rollback** if issues detected

**Safety Check**:
```python
# Compare models before deployment
new_auc = evaluate_model(new_model, test_data)
prod_auc = evaluate_model(prod_model, test_data)

if new_auc >= prod_auc + 0.02:  # 2% improvement threshold
    promote_to_production(new_model)
else:
    print(f"New model AUC ({new_auc}) not significantly better than prod ({prod_auc})")
```

### Scenario 6: Add New Loan Purpose Category

**Steps**:
1. **Update API** enum in `app/models/request_models.py`
   ```python
   class LoanPurpose(str, Enum):
       HOME = "HOME"
       CAR = "CAR"
       BUSINESS = "BUSINESS"
       EDUCATION = "EDUCATION"
       PERSONAL = "PERSONAL"
       MEDICAL = "MEDICAL"  # New
   ```

2. **Update Flutter** enum in `lib/models/loan_purpose.dart`
   ```dart
   enum LoanPurpose {
     HOME, CAR, BUSINESS, EDUCATION, PERSONAL, MEDICAL  // New
   }
   ```

3. **Update interest rate logic** in `services/loan_service.py`
   ```python
   purpose_adjustments = {
       "MEDICAL": -0.5,  # Medical loans get 0.5% discount
   }
   ```

4. **Update UI** dropdown/selection in Flutter app
5. **Test** end-to-end flow with new category

---

## Best Practices

### API Development
1. **Always use async/await** for FastAPI route handlers
2. **Validate inputs** with Pydantic models (app/models/)
3. **Log requests** using the configured logger (`app.core.logging`)
4. **Rate limit** sensitive endpoints using `@limiter.limit()`
5. **Return proper HTTP status codes**: 200 (success), 400 (validation), 401 (auth), 500 (server error)

### ML Model Development
1. **Feature engineering consistency**: Use `feature_engineering.py` for both training and inference
2. **Model versioning**: Save models with timestamps (`model_YYYYMMDD_HHMMSS.pkl`)
3. **Performance baseline**: Only promote models with ≥2% AUC improvement
4. **Data validation**: Check for missing values, outliers, and feature drift
5. **Save feature importance** for model interpretability

### Flutter App Development
1. **MVVM Pattern**: Keep business logic in ViewModels, not in Views
2. **Provider for State**: Use `ChangeNotifier` and `notifyListeners()` appropriately
3. **Error Handling**: Implement try-catch with user-friendly error messages
4. **Loading States**: Show loading indicators during API calls
5. **Offline Support**: Handle network errors gracefully with cached data
6. **Firebase Rules**: Implement proper Firestore security rules (user-scoped access)
7. **Token Refresh**: Always use `getIdToken(forceRefresh: true)` for API calls
8. **Input Validation**: Validate on client-side before API submission
9. **Responsive UI**: Test on multiple screen sizes and orientations
10. **Localization**: Use Vietnamese language for user-facing text

### Data Handling
1. **Use Parquet** for large datasets (better performance than CSV)
2. **Store raw data** in `data/raw/`, processed in `data/processed/`
3. **Version control**: Git ignore large data files, use `.gitattributes` for LFS
4. **Firestore export**: Run weekly exports for retraining pipeline
5. **Privacy**: Never log sensitive user data (PII, financial info)

### Testing
1. **Unit tests**: Test individual functions in isolation
2. **Integration tests**: Test full API request/response cycles
3. **Model tests**: Validate predictions on sample data
4. **Security tests**: Test authentication, rate limiting, input validation
5. **Flutter Widget tests**: Test UI components and user interactions

---

## Troubleshooting

### Common Issues

**API won't start**:
```bash
# Check if port 8000 is in use
netstat -ano | findstr :8000  # Windows
lsof -i :8000  # Linux/Mac

# Kill process and restart
taskkill /F /PID <PID>  # Windows
kill -9 <PID>  # Linux/Mac
```

**Model loading errors**:
```python
# Verify model file exists
import os
model_path = "models/lightgbm_model.pkl"
print(f"Model exists: {os.path.exists(model_path)}")

# Check model format
import joblib
model = joblib.load(model_path)
print(f"Model type: {type(model)}")
```

**Feature mismatch**:
- Ensure `feature_engineering.py` generates exactly 64 features
- Check feature names match between training and inference
- Validate feature order is consistent

**GCP deployment fails**:
```bash
# Check Cloud Build logs
gcloud builds list --limit=5

# View Cloud Run logs
gcloud run services logs read credit-scoring-api --limit=50

# Verify IAM permissions
gcloud projects get-iam-policy YOUR_PROJECT_ID
```

**Firebase Authentication Issues** (Flutter):
```dart
// Force token refresh
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken(true); // true = force refresh

// Check token expiration
final tokenResult = await user?.getIdTokenResult();
print('Token expires: ${tokenResult?.expirationTime}');

// Sign out and re-authenticate
await FirebaseAuth.instance.signOut();
```

**Firestore Permission Denied** (Flutter):
```javascript
// Check Firestore security rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User can only read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /loan_applications/{applicationId} {
      allow read, write: if request.auth != null && 
        resource.data.userId == request.auth.uid;
    }
  }
}
```

**API Connection Timeout** (Flutter):
```dart
// Increase timeout duration
final response = await http.post(
  Uri.parse(url),
  headers: headers,
  body: body,
).timeout(
  Duration(seconds: 60), // Increase from default 30s
  onTimeout: () {
    throw TimeoutException('Request timed out');
  },
);

// Check internet connectivity first
import 'package:connectivity_plus/connectivity_plus.dart';

final connectivityResult = await Connectivity().checkConnectivity();
if (connectivityResult == ConnectivityResult.none) {
  throw Exception('No internet connection');
}
```

**VNPT eKYC API Errors**:
```dart
// Common error codes
switch (errorCode) {
  case 'INVALID_IMAGE':
    // Image quality too low or not an ID card
    message = 'Vui lòng chụp lại ảnh rõ nét hơn';
    break;
  case 'FACE_NOT_MATCH':
    // Face matching failed
    message = 'Khuôn mặt không khớp với CMND/CCCD';
    break;
  case 'LIVENESS_FAILED':
    // Liveness detection failed
    message = 'Vui lòng chụp ảnh selfie thật';
    break;
  default:
    message = 'Lỗi xác thực. Vui lòng thử lại';
}
```

**Provider State Not Updating** (Flutter):
```dart
// Ensure you're calling notifyListeners()
class MyViewModel extends ChangeNotifier {
  bool _isLoading = false;
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners(); // <-- Don't forget this!
    
    await fetchData();
    
    _isLoading = false;
    notifyListeners(); // <-- And this!
  }
}

// Make sure you're using Consumer or context.watch
Consumer<MyViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.data);
  },
)

// Or
final viewModel = context.watch<MyViewModel>();
```

**Flutter Build Errors**:
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade

# Check for dependency conflicts
flutter pub outdated

# Delete build cache
rm -rf build/  # Linux/Mac
rmdir /s /q build  # Windows

# Common Firebase setup issue
flutterfire configure
```

---

## Key Files Reference

### API Core Files
- `app/main.py`: FastAPI app initialization, CORS, rate limiting
- `app/api/routes.py`: API endpoint definitions
- `app/services/prediction_service.py`: ML model loading and prediction logic
- `app/core/config.py`: Configuration management (Settings class)
- `app/core/security.py`: API key authentication
- `app/auth/api_key.py`: API key validation dependency

### ML Pipeline Files
- `pipeline/retrain_job.py`: Main retraining orchestration
- `pipeline/feature_engineering.py`: Feature creation logic (64 features)
- `pipeline/config.py`: GCP configuration (project, bucket, paths)

### Documentation Files
- `app/API_INTEGRATION_SPEC.md`: Detailed API integration guide
- `app/APP_SUMMARY.md`: Complete app architecture documentation
- `app/QUICK_REFERENCE.md`: Quick reference for features and data flow
- `app/MODEL_RETRAINING_PIPELINE.md`: Retraining pipeline details
- `GCP_DEPLOYMENT_GUIDE.md`: GCP deployment instructions
- `docs/API_GUIDE.md`: API usage guide

---

## Data Collection & Model Training

### Data Sources for Retraining

**Primary Source**: Firestore `loan_applications` collection
- User demographics (age, income, employment)
- Credit history (years, defaults)
- Loan details (purpose, amount, terms)
- Model predictions (credit score, risk level)

**Growth Expectations**:
- 50-100 applications/week
- Minimum retraining threshold: 500-1000 applications
- Need 6-12 months for ground truth labels (actual defaults)

### Feature Engineering for Production

The model requires 64 features but app only collects 9 direct inputs:

**Direct Features** (from app):
1. Age
2. Monthly income
3. Employment status
4. Years employed
5. Home ownership
6. Years credit history
7. Has previous defaults
8. Currently defaulting
9. Loan purpose

**Derived Features** (calculated by API):
- Annual income = monthly_income * 12
- Debt-to-income ratio = loan_amount / annual_income
- Income per person (with assumed household size)
- Categorical encodings (one-hot encoding)
- Bureau features (with default values)
- Previous application features (with default values)

### Retraining Pipeline Stages

```
Stage 1: Data Export (Cloud Function)
├─ Firestore → GCS
├─ Export loan_applications collection
├─ Output: Parquet files in gs://bucket/data/exports/
└─ Schedule: Weekly via Cloud Scheduler

Stage 2: Feature Engineering (Python)
├─ Load raw data from GCS
├─ Apply transformations (feature_engineering.py)
├─ Create 64 model features
├─ Handle missing values with defaults
└─ Output: Training-ready dataset

Stage 3: Model Training (Cloud Run Job)
├─ Load feature-engineered data
├─ Split: Train (70%), Val (15%), Test (15%)
├─ Train LightGBM with optuna hyperparameter tuning
├─ Evaluate on test set (AUC-ROC, precision, recall)
└─ Save model to gs://bucket/models/staging/

Stage 4: Model Evaluation & Deployment
├─ Compare with production model
├─ If AUC improvement ≥ 2%:
│   ├─ Auto-promote to production
│   ├─ Copy to gs://bucket/models/production/
│   └─ Update API to use new model
└─ Else: Keep current production model
```

### Ground Truth Collection

**Challenge**: No immediate default labels
- Need 6-12 months to observe loan performance
- Track: payment history, defaults, late payments

**Workaround Options**:
1. **Proxy Labels**: Use application completion rate
2. **Model Calibration**: Adjust using current predictions
3. **Wait for Ground Truth**: Optimal but requires patience

## Quick Decision Matrix

| Task | Location | Command |
|------|----------|---------|
| **API Development** |
| Start API locally | `credit-scoring-api/` | `uvicorn app.main:app --reload` |
| Test API endpoint | `credit-scoring-api/` | `python test_api.py` |
| Test security | `credit-scoring-api/` | `python test_security.py` |
| Deploy API to GCP | `credit-scoring-api/` | `./deploy-gcp.sh` |
| Run API tests | `credit-scoring-api/tests/` | `pytest tests/ -v` |
| **ML Model** |
| Train new model | `notebooks/base_model/03_modeling/` | Run Jupyter notebook |
| Retrain with prod data | `credit-scoring-api/pipeline/` | `python retrain_job.py` |
| Feature engineering | `credit-scoring-api/pipeline/` | `python feature_engineering.py` |
| **GCP Deployment** |
| Export Firestore data | `cloud-functions/firestore-exporter/` | `./deploy.sh` |
| Deploy retrain job | `credit-scoring-api/pipeline/` | `./deploy.sh` (Linux) or `.\deploy.ps1` (Windows) |
| **Data & Scripts** |
| Validate data | `scripts/` | `python validate_telco_data.py` |
| **Flutter App** (separate repo) |
| Run app | Flutter project root | `flutter run` |
| Build APK | Flutter project root | `flutter build apk --release` |
| Run tests | Flutter project root | `flutter test` |
| Configure Firebase | Flutter project root | `flutterfire configure` |

---

## Related Documentation

### In This Repository

**App Documentation** (`app/`):
- [API Integration Spec](../../../app/API_INTEGRATION_SPEC.md) - Detailed API contract for Flutter app
- [App Summary](../../../app/APP_SUMMARY.md) - Complete app architecture and features
- [Quick Reference](../../../app/QUICK_REFERENCE.md) - Quick lookup for commands and data structures
- [Model Retraining Pipeline](../../../app/MODEL_RETRAINING_PIPELINE.md) - Automated retraining guide

**API & Deployment**:
- [GCP Deployment Guide](../../../GCP_DEPLOYMENT_GUIDE.md) - Complete GCP setup and deployment
- [API Guide](../../../docs/API_GUIDE.md) - API usage documentation
- [README](../../../README.md) - Project overview and quick start

**Pipeline Documentation**:
- [Pipeline README](../../../credit-scoring-api/pipeline/README.md) - Retraining pipeline details
- [Firestore Exporter](../../../cloud-functions/firestore-exporter/README.md) - Data export setup

### Live Resources
- [Live API Documentation](https://credit-scoring-y8mw.onrender.com/docs) - Interactive Swagger UI
- [API Endpoint](https://credit-scoring-y8mw.onrender.com/api) - Production API base URL

### External Resources
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [LightGBM Documentation](https://lightgbm.readthedocs.io/)
- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [VNPT eKYC API](https://ekyc.vnpt.vn/)

---

**Last Updated**: March 2026  
**Maintainer**: Project Team  
**Version**: 1.0.0