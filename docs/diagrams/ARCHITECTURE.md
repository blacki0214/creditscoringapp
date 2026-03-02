# System Architecture — Credit Scoring App

## Overview

The application follows a **4-tier architecture**: a Flutter mobile client, an application logic layer, a cloud-hosted backend API, and a Firebase data layer. Identity verification is handled via the VNPT eKYC third-party service.

---

## System Architecture Diagram

```mermaid
graph TB
    subgraph MOBILE["Presentation Tier — Flutter Mobile App"]
        direction LR
        AUTH_UI["Auth\nLogin / Signup / Biometric"]
        LOAN_UI["Loan Application\nStep 1 to 4 Flow"]
        DASH_UI["Dashboard\nHistory / Notifications"]
        SETTINGS_UI["Settings\nProfile / Security"]
    end

    subgraph APP_LAYER["Application Tier"]
        direction TB
        subgraph STATE["State Management - MVVM"]
            VM1["AuthViewModel"]
            VM2["LoanViewModel"]
            VM3["NotificationViewModel"]
            VM4["ProfileViewModel"]
        end
        subgraph SERVICES["Service Layer"]
            S1["FirebaseAuthService\nEmail / Phone / Google"]
            S2["FirebaseLoanService\nApplications / Offers"]
            S3["NotificationService\nFCM / In-App"]
            S4["VNPTEkycService\nIdentity Verification"]
            S5["ApiService\nHTTP Client"]
        end
    end

    subgraph BACKEND["Backend Tier — Python API"]
        direction TB
        FLASK["Flask REST API\nRender.com"]
        subgraph ENDPOINTS["Endpoints"]
            EP1["POST /api/calculate-limit"]
            EP2["POST /api/calculate-terms"]
            EP3["GET  /api/health"]
        end
        ML["LightGBM Model\nCredit Scoring Engine"]
        FLASK --> EP1 & EP2 & EP3
        EP1 & EP2 --> ML
    end

    subgraph DATA["Data Tier — Firebase"]
        direction LR
        subgraph FIRESTORE["Cloud Firestore"]
            COL1["users"]
            COL2["credit_applications"]
            COL3["loan_offers"]
            COL4["notifications"]
            COL5["ekyc_logs\nekyc_images"]
            COL6["feedback\nsupport_chats\napplication_history"]
        end
        STORAGE["Firebase Storage\nImages and Files"]
        FCM_DB["Firebase FCM\nPush Delivery"]
    end

    subgraph EXTERNAL["External Services"]
        VNPT_EXT["VNPT eKYC\nVietnam Identity API"]
        GOOGLE_EXT["Google OAuth 2.0"]
    end

    MOBILE --> STATE
    STATE --> SERVICES
    S1 -->|"Auth tokens"| FIRESTORE
    S2 -->|"CRUD"| FIRESTORE
    S3 -->|"Read / Write"| FIRESTORE
    S3 -->|"Subscribe"| FCM_DB
    S4 -->|"Upload images"| STORAGE
    S4 -->|"eKYC Session"| VNPT_EXT
    S5 -->|"REST / HTTPS"| FLASK
    S1 -->|"OAuth"| GOOGLE_EXT
```

---

## Architecture Pattern

| Tier | Technology | Pattern |
|---|---|---|
| Presentation | Flutter (Dart) | MVVM with Provider |
| Application | Dart Service Classes | Dependency Injection |
| API Backend | Python + Flask | REST + Retry logic |
| ML Engine | LightGBM | Pickle-serialized model |
| Database | Cloud Firestore | NoSQL Document store |
| File Storage | Firebase Storage | Object storage |
| Auth | Firebase Auth | JWT + OAuth 2.0 |
| Messaging | Firebase FCM | Push notification broker |
| Identity | VNPT eKYC | Third-party REST API |

---

## Communication Protocols

```mermaid
graph LR
    APP["Flutter App"]
    API["Flask API"]
    FS["Firestore"]
    FCM["FCM"]
    VNPT["VNPT eKYC"]

    APP -->|"HTTPS REST / JSON + API Key"| API
    APP -->|"Firestore SDK / WebSocket real-time"| FS
    APP -->|"FCM SDK / long-polling"| FCM
    APP -->|"HTTPS REST / VNPT Token"| VNPT
```
