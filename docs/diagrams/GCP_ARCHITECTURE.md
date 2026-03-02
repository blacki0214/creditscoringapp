# Cloud Infrastructure Diagram — Credit Scoring App

> **Cloud Provider**: Google Cloud Platform (Firebase + GCP)

---

## GCP Services, Networking & Security

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#1e3a5f", "primaryTextColor": "#ffffff", "primaryBorderColor": "#3b82f6", "lineColor": "#64748b", "nodeBorder": "#475569", "clusterBkg": "#1e293b", "edgeLabelBackground": "#1e293b"}}}%%
flowchart TB
    classDef user     fill:#1e3a5f,stroke:#3b82f6,color:#fff
    classDef security fill:#7c1d1d,stroke:#ef4444,color:#fff
    classDef network  fill:#1c3a5f,stroke:#3b82f6,color:#fff
    classDef compute  fill:#14532d,stroke:#22c55e,color:#fff
    classDef database fill:#3b1f6e,stroke:#a855f7,color:#fff
    classDef ml       fill:#4a1d6e,stroke:#c084fc,color:#fff
    classDef obs      fill:#164e63,stroke:#22d3ee,color:#fff
    classDef external fill:#1f2937,stroke:#6b7280,color:#fff

    MOB["Mobile App\nFlutter"]:::user

    subgraph SECURITY["Security Layer"]
        direction LR
        ARMOR["Cloud Armor\nDDoS / WAF / Rate Limit"]:::security
        IAP["Identity-Aware Proxy\nJWT Verification"]:::security
        IAM["IAM Roles\nLeast Privilege"]:::security
        KMS["Cloud KMS\nKey Encryption"]:::security
    end

    subgraph NETWORK["Networking Layer"]
        direction LR
        LB["Cloud Load Balancer\nHTTPS + SSL"]:::network
        VPC["VPC Network\nPrivate Subnet"]:::network
    end

    subgraph COMPUTE["Compute Layer"]
        direction LR
        CR["Cloud Run\nFlask API Container"]:::compute
        GCF["Cloud Functions\nNotification Triggers"]:::compute
    end

    subgraph DATABASE["Data Layer"]
        direction LR
        FS["Cloud Firestore\n10 Collections"]:::database
        GCS["Cloud Storage\neKYC Images / Avatars"]:::database
        REDIS["Memorystore Redis\nCaching"]:::database
    end

    subgraph ML["ML Layer"]
        direction LR
        VAI["Vertex AI\nLightGBM Hosting"]:::ml
        REG["Artifact Registry\nDocker Images"]:::ml
    end

    subgraph OBS["Observability"]
        direction LR
        LOG["Cloud Logging\nAudit Logs"]:::obs
        MON["Cloud Monitoring\nAlerts"]:::obs
    end

    EXTERNAL_FCM["Firebase FCM\nPush Notifications"]:::external
    EXTERNAL_VNPT["VNPT eKYC\nIdentity API"]:::external
    EXTERNAL_GOOGLE["Google OAuth 2.0"]:::external

    MOB -->|HTTPS| ARMOR
    ARMOR --> LB
    LB --> IAP
    IAP --> CR
    IAP --> GCF

    CR --> VPC
    VPC --> FS
    VPC --> GCS
    VPC --> REDIS
    VPC --> VAI

    CR -->|Model inference| VAI
    VAI --> REG
    CR -->|Encrypt secrets| KMS
    IAM -->|Controls| FS
    IAM -->|Controls| GCS

    CR --> LOG & MON
    GCF --> EXTERNAL_FCM
    EXTERNAL_FCM -->|Push| MOB

    MOB -->|eKYC| EXTERNAL_VNPT
    MOB -->|Sign in| EXTERNAL_GOOGLE
    EXTERNAL_GOOGLE --> IAP
```

---

## Security Layers Breakdown

```mermaid
%%{init: {"theme": "base", "themeVariables": {"primaryColor": "#1e3a5f", "primaryTextColor": "#ffffff", "primaryBorderColor": "#3b82f6", "lineColor": "#64748b", "nodeBorder": "#475569", "clusterBkg": "#1e293b", "edgeLabelBackground": "#1e293b"}}}%%
flowchart LR
    classDef l1 fill:#7c1d1d,stroke:#ef4444,color:#fff
    classDef l2 fill:#7c3d0e,stroke:#f97316,color:#fff
    classDef l3 fill:#1e3a5f,stroke:#3b82f6,color:#fff
    classDef l4 fill:#14532d,stroke:#22c55e,color:#fff

    REQ["Incoming Request"]

    L1["Layer 1 — Edge\nCloud Armor\nDDoS / WAF / Geo Block"]:::l1
    L2["Layer 2 — Auth\nIdentity-Aware Proxy\nJWT + Google OAuth"]:::l2
    L3["Layer 3 — Network\nVPC + Firewall Rules\nNo public DB access"]:::l3
    L4["Layer 4 — Data\nFirestore Security Rules\nCloud KMS Encryption"]:::l4

    REQ --> L1 --> L2 --> L3 --> L4
```

---

## GCP Services Summary

| Layer | Service | Purpose |
|---|---|---|
| Security | Cloud Armor | DDoS, WAF, rate limiting at the edge |
| Security | Identity-Aware Proxy | Verify JWT before API access |
| Security | IAM | Least-privilege roles per service |
| Security | Cloud KMS | Encrypt sensitive data fields |
| Network | Cloud Load Balancer | HTTPS termination, SSL |
| Network | VPC | Private subnet — DB not public |
| Compute | Cloud Run | Flask API, auto-scaling containers |
| Compute | Cloud Functions | Notification triggers |
| Data | Cloud Firestore | Main database, 10 collections |
| Data | Cloud Storage | eKYC images, user avatars |
| Data | Memorystore (Redis) | Cache frequent scoring results |
| ML | Vertex AI | LightGBM model hosting |
| ML | Artifact Registry | Docker image registry |
| Observability | Cloud Logging | API and Firestore audit logs |
| Observability | Cloud Monitoring | Uptime, latency, error alerts |
