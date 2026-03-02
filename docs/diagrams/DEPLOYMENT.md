# Deployment Diagram — Credit Scoring App

---

## Where Each Component Is Hosted

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#1e3a5f", "primaryTextColor": "#ffffff", "primaryBorderColor": "#3b82f6", "lineColor": "#64748b", "nodeBorder": "#475569", "clusterBkg": "#1e293b", "edgeLabelBackground": "#1e293b"}}}%%
flowchart TB
    classDef device   fill:#1e3a5f,stroke:#3b82f6,color:#fff
    classDef firebase fill:#7c3d0e,stroke:#f97316,color:#fff
    classDef render   fill:#14532d,stroke:#22c55e,color:#fff
    classDef external fill:#1f2937,stroke:#6b7280,color:#fff
    classDef store    fill:#3b1f6e,stroke:#a855f7,color:#fff

    subgraph USER_DEVICE["User Device"]
        APK["Flutter App\nAndroid / iOS\n(.apk / .ipa)"]:::device
    end

    subgraph FIREBASE_PLATFORM["Firebase Platform (Google Cloud)"]
        direction TB
        AUTH["Firebase Auth\nAuthentication Service"]:::firebase
        FS["Cloud Firestore\nNoSQL Database\n10 Collections"]:::firebase
        FCM["Firebase FCM\nPush Notification Service"]:::firebase
        STG["Firebase Storage\nObject Storage\neKYC images, avatars"]:::firebase
    end

    subgraph RENDER["Render.com (Cloud)"]
        direction TB
        API["Flask REST API\nWeb Service\ncredit-scoring-h7mv.onrender.com"]:::render
        ML["LightGBM Model\nPickle file loaded in memory"]:::render
        API --> ML
    end

    subgraph THIRD_PARTY["Third-Party Services"]
        VNPT["VNPT eKYC API\nVietnam (on-premise / cloud)"]:::external
        GOOGLE["Google OAuth 2.0\naccounts.google.com"]:::external
    end

    APK -->|"HTTPS"| AUTH
    APK -->|"Firestore SDK"| FS
    APK -->|"FCM SDK"| FCM
    APK -->|"Storage SDK"| STG
    APK -->|"HTTPS REST"| API
    APK -->|"HTTPS REST"| VNPT
    AUTH -->|"OAuth"| GOOGLE
    FCM -->|"Push"| APK
```

---

## Hosting Summary

| Component | Platform | URL / Location |
|---|---|---|
| Flutter Mobile App | User Device | Android / iOS |
| Firebase Auth | Google Firebase | firebase.google.com |
| Cloud Firestore | Google Firebase | firebase.google.com |
| Firebase Storage | Google Firebase | firebase.google.com |
| Firebase FCM | Google Firebase | firebase.google.com |
| Flask REST API | Render.com | credit-scoring-h7mv.onrender.com |
| LightGBM Model | Render.com (in-memory) | Loaded at API startup |
| VNPT eKYC | VNPT Vietnam | Third-party API |
| Google OAuth 2.0 | Google | accounts.google.com |
