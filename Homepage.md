# Home Page Documentation

## Overview

The Home Page (`lib/home/home_page.dart`) is the main dashboard of the credit scoring application. It displays user credit information, loan offers, and application history. The page features a tabbed interface with three main sections: **Current year** (credit score), **Loans** (loan offers and history), and **Hards** (hard inquiries).

---

## Table of Contents

1. [Architecture](#architecture)
2. [UI Layout](#ui-layout)
3. [Loan Display Feature](#loan-display-feature)
4. [Data Sources](#data-sources)
5. [Code Breakdown](#code-breakdown)
6. [Component Details](#component-details)
7. [State Management](#state-management)
8. [User Interactions](#user-interactions)

---

## Architecture

### File Structure
```
lib/
├── home/
│   └── home_page.dart          # Main home page widget
├── viewmodels/
│   ├── home_viewmodel.dart     # Home page state (period selection, index)
│   └── loan_viewmodel.dart     # Loan application state
├── services/
│   ├── local_storage_service.dart  # SharedPreferences persistence
│   └── api_service.dart        # API integration for loan requests
└── loan/
    └── loan_application_page.dart  # Loan application flow
```

### Technology Stack
- **State Management**: Provider package (`context.watch<LoanViewModel>()`)
- **Storage**: SharedPreferences via `LocalStorageService`
- **Formatting**: `intl` package for currency and datetime formatting
- **UI Framework**: Flutter Material Design

---

## UI Layout

### Page Structure

```
┌─────────────────────────────────────┐
│ Top Bar (Avatar + Name + Notifications)
├─────────────────────────────────────┤
│ Greeting Message                    │
│ "Hello, Nguyen Van A"               │
│ "Here is your credit rate"          │
├─────────────────────────────────────┤
│ Period Selector (Chips)             │
│ [Current year] [Loans] [Hards]     │
├─────────────────────────────────────┤
│ Content Area (Conditional)          │
│ - Credit Score (Current year)       │
│ - Loan Offer + History (Loans)     │
│ - No Hard Inquiries (Hards)        │
├─────────────────────────────────────┤
│ Bottom Navigation Bar               │
│ [Home] [Upload] [Messages] [Settings]
└─────────────────────────────────────┘
```

---

## Loan Display Feature

### Overview

The Loan Display is a comprehensive UI section that activates when users select the **"Loans"** period chip in the home page. It presents three distinct views based on the application state:

1. **Active Loan Offer** - Shows current loan terms with approval/rejection status
2. **Processing State** - Loading indicator while loan is being processed
3. **No Active Loan** - Empty state with option to start new application

### Data Flow Diagram

```
LoanViewModel (State)
    ├── currentOffer: LoanOfferResponse?
    ├── isProcessing: bool
    ├── fullName: String
    ├── dob: DateTime?
    └── monthlyIncome: double
         │
         ├─→ _buildLoanDisplay() method
         │       │
         │       ├─→ _buildCurrentOfferCard()
         │       │       ├─→ Status Banner (Green/Red)
         │       │       ├─→ Loan Details (Amount, Rate, etc.)
         │       │       └─→ Action Buttons
         │       │
         │       ├─→ _buildApplicationHistory()
         │       │       └─→ ListView of Past Applications
         │       │
         │       └─→ _buildEmptyState()
         │               └─→ Call-to-Action Button
         │
         └─→ LocalStorageService
                 └─→ getApplicationHistory() → List<Map>
```

---

## Data Sources

### 1. LoanViewModel Properties

```dart
// Current Offer Response
LoanOfferResponse? _currentOffer;

// Loan Offer Properties
LoanOfferResponse {
  bool approved,                    // Approval status
  double loanAmountVnd,            // Loan amount in VND
  double maxAmountVnd,             // Maximum available amount
  double? interestRate,            // Annual interest rate (nullable)
  double? monthlyPaymentVnd,       // Monthly payment (nullable)
  int? loanTermMonths,             // Loan duration (nullable)
  int creditScore,                 // User's credit score
  String riskLevel,                // Risk classification
  String approvalMessage,          // Message/reason
  String? loanTier,                // Loan tier (nullable)
  String? tierReason,              // Tier reason (nullable)
}

// Processing State
bool _isProcessing;                // True while API is processing
```

### 2. LocalStorageService Methods

```dart
// Retrieves last 20 loan applications
static List<Map> getApplicationHistory()

// Returns Map structure:
{
  'timestamp': '2025-12-21T10:30:00.000Z',  // ISO8601 format
  'approved': true,                         // Boolean status
  'creditScore': 650,                       // Numeric score
  'loanAmount': 15000000,                   // Amount in VND
}
```

---

## Code Breakdown

### 1. Imports and Dependencies

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';                    // For currency/datetime formatting
import '../viewmodels/home_viewmodel.dart';        // Home state management
import '../viewmodels/loan_viewmodel.dart';        // Loan state management
import '../services/local_storage_service.dart';   // Data persistence
import '../loan/loan_application_page.dart';       // Navigation
import '../settings/settings_page.dart';           // Navigation
import '../settings/profile_page.dart';            // Navigation
import '../settings/support_page.dart';            // Navigation
```

### 2. Main Widget Build Method - Content Selection

**File**: `lib/home/home_page.dart` (Lines 359-530)

```dart
// Period selector chips
Row(
  children: [
    _buildPeriodChip(context, viewModel, 'Current year'),
    const SizedBox(width: 8),
    _buildPeriodChip(context, viewModel, 'Loans'),      // Triggers loan display
    const SizedBox(width: 8),
    _buildPeriodChip(context, viewModel, 'Hards'),
  ],
),
const SizedBox(height: 32),

// Conditional content based on selected period
if (viewModel.selectedPeriod == 'Current year') ...[
  // Credit score gauge and metrics
] else if (viewModel.selectedPeriod == 'Loans') ...[
  // Loan display section ← NEW FEATURE
  _buildLoanDisplay(context),
] else if (viewModel.selectedPeriod == 'Hards') ...[
  // Hard inquiries placeholder
],
```

**Key Concept**: The `if...else if` conditional rendering determines which content displays based on `viewModel.selectedPeriod`. When user clicks "Loans" chip, `_buildLoanDisplay()` method executes.

### 3. Loan Display Method

**File**: `lib/home/home_page.dart` (Lines 533-885)

```dart
Widget _buildLoanDisplay(BuildContext context) {
  final loanViewModel = context.watch<LoanViewModel>();
  final applicationHistory = LocalStorageService.getApplicationHistory();
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // ===== SECTION 1: Current Offer =====
      if (loanViewModel.currentOffer != null) ...[
        // Show loan offer card
      ] else if (loanViewModel.isProcessing) ...[
        // Show loading spinner
      ] else ...[
        // Show empty state
      ],
      
      // ===== SECTION 2: Application History =====
      if (applicationHistory.isNotEmpty) ...[
        // Show history list
      ],
    ],
  );
}
```

---

## Component Details

### Component 1: Current Loan Offer Card

**Triggers When**: `loanViewModel.currentOffer != null`

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    // Green background for approved, red for rejected
    color: loanViewModel.currentOffer!.approved 
      ? const Color(0xFFE8F5E9)  // Light green
      : const Color(0xFFFFEBEE), // Light red
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: loanViewModel.currentOffer!.approved
        ? const Color(0xFF4CAF50)  // Green border
        : const Color(0xFFEF5350), // Red border
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Status header with icon
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            loanViewModel.currentOffer!.approved ? 'APPROVED' : 'REJECTED',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: loanViewModel.currentOffer!.approved
                ? const Color(0xFF4CAF50)
                : const Color(0xFFEF5350),
            ),
          ),
          Icon(
            loanViewModel.currentOffer!.approved
              ? Icons.check_circle
              : Icons.cancel,
            color: loanViewModel.currentOffer!.approved
              ? const Color(0xFF4CAF50)
              : const Color(0xFFEF5350),
            size: 24,
          ),
        ],
      ),
      const SizedBox(height: 16),
      
      // ===== APPROVED OFFER DETAILS =====
      if (loanViewModel.currentOffer!.approved) ...[
        _buildLoanDetailRow('Loan Amount', 
          currencyFormat.format(loanViewModel.currentOffer!.loanAmountVnd)),
        const SizedBox(height: 12),
        
        // Interest Rate (nullable check)
        if (loanViewModel.currentOffer!.interestRate != null)
          Column(
            children: [
              _buildLoanDetailRow('Interest Rate',
                '${loanViewModel.currentOffer!.interestRate!.toStringAsFixed(2)}% / year'),
              const SizedBox(height: 12),
            ],
          ),
        
        // Monthly Payment (nullable check)
        if (loanViewModel.currentOffer!.monthlyPaymentVnd != null)
          Column(
            children: [
              _buildLoanDetailRow('Monthly Payment',
                currencyFormat.format(loanViewModel.currentOffer!.monthlyPaymentVnd)),
              const SizedBox(height: 12),
            ],
          ),
        
        // Loan Term (nullable check)
        if (loanViewModel.currentOffer!.loanTermMonths != null)
          Column(
            children: [
              _buildLoanDetailRow('Loan Term',
                '${loanViewModel.currentOffer!.loanTermMonths} months'),
              const SizedBox(height: 12),
            ],
          ),
        
        _buildLoanDetailRow('Credit Score',
          '${loanViewModel.currentOffer!.creditScore}'),
        
        const SizedBox(height: 16),
        
        // Action buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Viewing loan terms...'),
                      backgroundColor: Color(0xFF4C40F7),
                    ),
                  );
                },
                child: const Text('View Terms'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Processing loan acceptance...'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                child: const Text('Accept Loan'),
              ),
            ),
          ],
        ),
      ] else ...[
        // ===== REJECTION MESSAGE =====
        Center(
          child: Column(
            children: [
              Text(
                loanViewModel.currentOffer!.approvalMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFFEF5350),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              _buildLoanDetailRow('Credit Score',
                '${loanViewModel.currentOffer!.creditScore}'),
            ],
          ),
        ),
      ],
    ],
  ),
)
```

**Key Features**:
- **Conditional Colors**: Green for approved, red for rejected
- **Null-Safety**: Uses `if (property != null)` checks for optional fields
- **Dual States**: Different UI for approved vs. rejected loans
- **Currency Formatting**: Vietnamese currency (₫) with thousand separators

### Component 2: Processing State

**Triggers When**: `loanViewModel.isProcessing == true`

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(
        width: 50,
        height: 50,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C40F7)),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Processing your loan application...',
        style: TextStyle(
          fontSize: 14,
          color: Color(0xFF1A1F3F),
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  ),
)
```

**Purpose**: Shows animated loading spinner while API processes the loan application.

### Component 3: Empty State (No Active Loan)

**Triggers When**: `currentOffer == null && !isProcessing`

```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.money_off,
        size: 64,
        color: Colors.grey.shade400,
      ),
      const SizedBox(height: 16),
      Text(
        'No Active Loan',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        'Start a new loan application',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LoanApplicationPage(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C40F7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text('Apply Now'),
      ),
    ],
  ),
)
```

**Purpose**: Guides users to create new loan applications when no active offers exist.

### Component 4: Application History

**Triggers When**: `applicationHistory.isNotEmpty`

```dart
const SizedBox(height: 32),
const Text(
  'Application History',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1A1F3F),
  ),
),
const SizedBox(height: 12),
ListView.builder(
  shrinkWrap: true,                          // Doesn't take full height
  physics: const NeverScrollableScrollPhysics(), // Controlled by parent scroll
  itemCount: applicationHistory.length,
  itemBuilder: (context, index) {
    final app = applicationHistory[index];
    final timestamp = app['timestamp'] != null
      ? DateTime.parse(app['timestamp'])      // Parse ISO8601 string
      : DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    final isApproved = app['approved'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isApproved
            ? const Color(0xFF4CAF50)    // Green border
            : const Color(0xFFEF5350),   // Red border
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isApproved ? Icons.check_circle : Icons.cancel,
            color: isApproved
              ? const Color(0xFF4CAF50)
              : const Color(0xFFEF5350),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved ? 'Approved' : 'Rejected',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isApproved
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFEF5350),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,  // "21/12/2025 10:30"
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Score: ${app['creditScore'] ?? 'N/A'}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1F3F),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Amount: ${app['loanAmount'] != null ? currencyFormat.format(app['loanAmount']) : 'N/A'}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
),
```

**Key Features**:
- **ListView.builder**: Efficiently renders up to 20 past applications
- **NeverScrollableScrollPhysics**: Prevents nested scrolling; controlled by parent
- **DateTime Parsing**: Converts ISO8601 strings to Vietnamese date format
- **Status Indicators**: Color-coded borders and icons (green=approved, red=rejected)
- **Compact Layout**: Shows credit score and amount in minimal space

### Helper Method: Loan Detail Row

**File**: `lib/home/home_page.dart` (Lines 887-915)

```dart
Widget _buildLoanDetailRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1F3F),
        ),
      ),
    ],
  );
}
```

**Purpose**: Reusable widget for displaying loan information in key-value pairs with consistent styling.

---

## State Management

### LoanViewModel Integration

The loan display depends entirely on **LoanViewModel** state:

```dart
final loanViewModel = context.watch<LoanViewModel>();
```

**Watched Properties**:

| Property | Type | Purpose |
|----------|------|---------|
| `currentOffer` | `LoanOfferResponse?` | Current loan offer data |
| `isProcessing` | `bool` | Loading state during API call |
| `step1Completed` | `bool` | eKYC verification status |
| `step2Completed` | `bool` | Personal info form status |

**State Flow**:

```
1. User submits loan application (Step 2)
   ↓
2. ViewModel calls API: submitApplication()
   ↓
3. isProcessing = true (UI shows spinner)
   ↓
4. API returns LoanOfferResponse
   ↓
5. currentOffer = response; isProcessing = false
   ↓
6. UI rebuilds and displays offer card
   ↓
7. User clicks "Accept Loan" or "View Terms"
```

### LocalStorage Integration

Application history persists across app restarts:

```dart
// Save after successful submission
void saveApplicationHistory(Map<String, dynamic> appData) {
  final history = getApplicationHistory(); // Get existing
  history.insert(0, appData);               // Add new at top
  if (history.length > 20) {
    history.removeLast();                   // Keep only 20
  }
  _prefs.setString('_application_history', jsonEncode(history));
}

// Retrieve for display
static List<Map> getApplicationHistory() {
  final jsonStr = _prefs.getString('_application_history');
  if (jsonStr == null) return [];
  return List<Map>.from(jsonDecode(jsonStr));
}
```

---

## User Interactions

### Interaction 1: Select "Loans" Chip

```
User Action:
├─ Click "Loans" chip
│   ↓
HomeViewModel.setPeriod('Loans')
│   ↓
viewModel.selectedPeriod = 'Loans'
│   ↓
HomePage rebuilds
│   ↓
_buildLoanDisplay(context) executes
│   ↓
Display appropriate view (offer/processing/empty)
```

### Interaction 2: View Loan Terms (Approved Only)

```
User Action:
├─ Click "View Terms" button
│   ↓
Show SnackBar: "Viewing loan terms..."
│   ↓
[FUTURE] Navigate to terms/conditions page
```

### Interaction 3: Accept Loan (Approved Only)

```
User Action:
├─ Click "Accept Loan" button
│   ↓
Show SnackBar: "Processing loan acceptance..."
│   ↓
[FUTURE] Save acceptance to backend
│   ↓
[FUTURE] Update status to "ACCEPTED"
│   ↓
[FUTURE] Show confirmation and next steps
```

### Interaction 4: Apply Now (Empty State)

```
User Action:
├─ Click "Apply Now" button
│   ↓
Navigator.push(LoanApplicationPage)
│   ↓
Start new loan application workflow
│   ↓
Complete Steps 1, 2, and submit
```

### Interaction 5: View Application History

```
Automatic:
├─ Application History loads automatically when available
│   ↓
Each item is read-only (no interaction)
│   ↓
Shows timestamp, status, score, and amount
│   ↓
Can scroll through past 20 applications
```

---

## Data Structures

### LoanOfferResponse Structure

```dart
class LoanOfferResponse {
  final bool approved;                  // true/false
  final double loanAmountVnd;          // 10,000,000 - 50,000,000
  final double requestedAmountVnd;     // User requested amount
  final double maxAmountVnd;           // Maximum available
  final double? interestRate;          // 6.5 - 18.5 (nullable)
  final double? monthlyPaymentVnd;     // Calculated payment (nullable)
  final int? loanTermMonths;           // 6 - 60 (nullable)
  final int creditScore;               // 300 - 850
  final String riskLevel;              // "LOW", "MEDIUM", "HIGH"
  final String approvalMessage;        // "Approved" or reason
  final String? loanTier;              // "STANDARD", "PREMIUM" (nullable)
  final String? tierReason;            // Why tier assigned (nullable)
}
```

### ApplicationHistory Item Structure

```dart
Map<String, dynamic> {
  'timestamp': '2025-12-21T10:30:00.000Z',  // ISO8601 string
  'approved': true,                         // Boolean
  'creditScore': 650,                       // Integer
  'loanAmount': 20000000,                   // Double (VND)
}
```

---

## Styling Reference

### Color Palette

| Color | Use Case |
|-------|----------|
| `#4C40F7` (Purple) | Primary buttons, borders |
| `#4CAF50` (Green) | Approved status, success states |
| `#EF5350` (Red) | Rejected status, error states |
| `#1A1F3F` (Dark Blue) | Text, titles |
| `#E8F5E9` (Light Green) | Approved card background |
| `#FFEBEE` (Light Red) | Rejected card background |

### Typography

| Element | Size | Weight | Color |
|---------|------|--------|-------|
| Status Header | 14px | Bold (700) | Green/Red |
| Detail Label | 13px | Medium (500) | Grey-700 |
| Detail Value | 14px | Bold (700) | Dark Blue |
| Section Title | 16px | Bold (600) | Dark Blue |
| Timestamp | 12px | Regular | Grey-600 |

---

## Performance Considerations

1. **ListView.builder**: Uses builder pattern to efficiently render history items
2. **NeverScrollableScrollPhysics**: Prevents nested scroll conflicts
3. **shrinkWrap: true**: History section doesn't exceed needed height
4. **watch<LoanViewModel>()**: Only rebuilds when LoanViewModel changes
5. **context.watch<LoanViewModel>()**: Provider automatically manages listeners

---

## Future Enhancements

1. **View Terms Page**: Full loan agreement display with printable PDF
2. **Accept Loan Flow**: Signature capture, funding timeline, account setup
3. **Loan Management**: Post-acceptance dashboard showing:
   - Payment schedule
   - Outstanding balance
   - Next payment date
   - Payment history
4. **Advanced Filters**: Search/filter application history by date or status
5. **Notifications**: Alert user when new offer is received
6. **Rejection Appeals**: Allow users to reapply after improvements

---

## Troubleshooting

### Issue: Loan card not displaying

**Cause**: `loanViewModel.currentOffer` is null

**Solution**: 
1. Ensure user completed loan application (Steps 1 & 2)
2. Verify API response in Dart VM debugger
3. Check `LocalStorageService` initialization in `main.dart`

### Issue: Application history empty

**Cause**: No previous applications or `LocalStorageService` not initialized

**Solution**:
1. Verify `LocalStorageService.init()` called in `main()` before `runApp()`
2. Submit at least one complete loan application
3. Check SharedPreferences data with debugging tools

### Issue: Null pointer exceptions with optional fields

**Cause**: Trying to format null `interestRate` or `monthlyPaymentVnd`

**Solution**: Already handled with `if (property != null)` checks. Verify null-safety conditions in custom modifications.

---

## Testing Checklist

- [ ] Loan card displays when offer is available
- [ ] Status shows "APPROVED" in green for approved offers
- [ ] Status shows "REJECTED" in red for rejected offers
- [ ] All loan details format correctly (amount, rate, term, payment)
- [ ] Application history shows up to 20 previous applications
- [ ] Timestamps display in Vietnamese format (DD/MM/YYYY HH:MM)
- [ ] Currency displays with thousand separators (15,000,000 ₫)
- [ ] Empty state shows when no active loan
- [ ] Processing spinner shows while API is processing
- [ ] "Apply Now" button navigates to LoanApplicationPage
- [ ] Period chips switch content correctly
- [ ] Application history scrolls independently

---

## Summary

The Loan Display feature transforms the home page "Loans" tab into a comprehensive loan management dashboard. It leverages Flutter's reactive state management via Provider to display real-time loan data from the backend API while maintaining persistent application history through local storage. The three-state design (active offer, processing, empty) ensures a polished user experience across all loan application scenarios.
