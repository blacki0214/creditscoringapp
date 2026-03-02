# Database Schema Diagram — Credit Scoring App

> **Database**: Cloud Firestore (NoSQL Document Store)
> **Total Collections**: 10 (+ 1 subcollection)

---

## Schema Diagram

```mermaid
erDiagram
    USERS {
        string uid PK
        string email
        string fullName
        string phoneNumber
        string authMethod
        string avatarUrl
        boolean profileComplete
        boolean hasPassword
        string nationalId
        string address
        string city
        number monthlyIncome
        string employmentStatus
        number yearsEmployed
        string homeOwnership
        number latestCreditScore
        timestamp createdAt
        timestamp updatedAt
    }

    CREDIT_APPLICATIONS {
        string id PK
        string userId FK
        string status
        number age
        number monthlyIncome
        string employmentStatus
        number yearsEmployed
        string homeOwnership
        string loanPurpose
        number yearsCreditHistory
        boolean hasPreviousDefaults
        boolean currentlyDefaulting
        number creditScore
        string riskLevel
        boolean approved
        number loanLimitVnd
        timestamp createdAt
        timestamp updatedAt
    }

    LOAN_OFFERS {
        string id PK
        string userId FK
        string applicationId FK
        boolean approved
        number loanAmountVnd
        number maxAmountVnd
        number interestRate
        number monthlyPaymentVnd
        number loanTermMonths
        number totalPaymentVnd
        number totalInterestVnd
        number creditScore
        string riskLevel
        string approvalMessage
        boolean accepted
        timestamp acceptedAt
        timestamp createdAt
        timestamp expiresAt
    }

    EKYC_LOGS {
        string id PK
        string userId FK
        string sessionId
        string status
        string verificationType
        number confidence
        string errorMessage
        timestamp createdAt
        timestamp updatedAt
        timestamp completedAt
    }

    EKYC_IMAGES {
        string id PK
        string userId FK
        string sessionId FK
        string imageType
        string storageUrl
        number fileSize
        string mimeType
        timestamp uploadedAt
    }

    FEEDBACK {
        string id PK
        string userId FK
        string userName
        string userEmail
        string category
        string subject
        string message
        string status
        timestamp createdAt
        timestamp updatedAt
    }

    NOTIFICATIONS {
        string id PK
        string userId FK
        string applicationId FK
        string type
        string title
        string body
        map data
        boolean isRead
        timestamp createdAt
    }

    SUPPORT_CHATS {
        string id PK
        string userId FK
        string userName
        string userEmail
        string status
        timestamp lastMessageAt
        timestamp createdAt
        timestamp closedAt
    }

    MESSAGES {
        string id PK
        string senderId
        string senderType
        string senderName
        string message
        boolean read
        timestamp timestamp
    }

    APPLICATION_HISTORY {
        string id PK
        string userId FK
        string applicationId FK
        string action
        string performedBy
        map details
        timestamp timestamp
    }

    USERS ||--o{ CREDIT_APPLICATIONS : "submits"
    USERS ||--o{ LOAN_OFFERS : "receives"
    USERS ||--o{ EKYC_LOGS : "has"
    USERS ||--o{ EKYC_IMAGES : "uploads"
    USERS ||--o{ FEEDBACK : "writes"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ SUPPORT_CHATS : "opens"
    USERS ||--o{ APPLICATION_HISTORY : "owns"
    CREDIT_APPLICATIONS ||--o{ LOAN_OFFERS : "generates"
    CREDIT_APPLICATIONS ||--o{ NOTIFICATIONS : "triggers"
    CREDIT_APPLICATIONS ||--o{ APPLICATION_HISTORY : "tracked by"
    EKYC_LOGS ||--o{ EKYC_IMAGES : "has"
    SUPPORT_CHATS ||--o{ MESSAGES : "contains"
```

---

## Field Type Reference

| Type | Description |
|---|---|
| `string` | Text value |
| `number` | Integer or float |
| `boolean` | true / false |
| `timestamp` | Firestore Timestamp (date + time) |
| `map` | Nested JSON object |
| `array` | List of values |
| `PK` | Primary Key — Firestore Document ID |
| `FK` | Foreign Key — Reference to another document |

---

## Collection Index Reference

| Collection | Indexed Fields |
|---|---|
| `credit_applications` | `userId` ASC + `createdAt` DESC |
| `loan_offers` | `userId` ASC + `createdAt` DESC |
| `notifications` | `userId` ASC + `isRead` ASC |
| `notifications` | `userId` ASC + `createdAt` DESC |

---

## Subcollection Structure

```
support_chats/{chatId}
    └── messages/{messageId}

users/{userId}
    └── settings/{document}
```
