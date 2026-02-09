# Change Log - 02/09/2026

## Overview
- Added a dedicated Terms of Service page and updated the login flow to show a modal with a link to that page.
- Refined Home page tabs and chip styling, and split Loan History into its own tab.
- Reworked Step 3 Additional Info relationship input into a dropdown list.

## Code Changes
- Added Terms of Service screen and routing.
- Updated login modal content to a single-line agreement with a tappable link.
- Updated Home page period selector labels and styling, and moved history into its own view.
- Added Loan History view for past applications.

### Key Snippets
```dart
// Login modal now links to the Terms page
content: RichText(
  text: TextSpan(
    children: [
      const TextSpan(text: 'I agree to '),
      TextSpan(
        text: 'Terms of Service',
        recognizer: _tosLinkRecognizer..onTap = () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TermOfServicePage()),
          );
        },
      ),
    ],
  ),
),
```

```dart
// Home page period tabs now include Loan History
_buildPeriodChip(context, viewModel, 'Overall');
_buildPeriodChip(context, viewModel, 'Scoring Status');
_buildPeriodChip(context, viewModel, 'Loan History');
```

```dart
// Step 3 relationship now uses a dropdown
DropdownButtonFormField<String>(
  value: _selectedRelationship,
  items: _relationshipOptions.map((option) => DropdownMenuItem(
    value: option,
    child: Text(option),
  )).toList(),
  onChanged: (value) => setState(() => _selectedRelationship = value),
  validator: (value) => value == null || value.isEmpty
      ? 'Please select relationship'
      : null,
),
```

## Function Changes
- `LoginPage._showTosDialog()` now renders a `RichText` agreement line and navigates to `TermOfServicePage` on link tap.
- `HomePage._buildPeriodChip()` styling updated for stronger contrast, border, and shadow states.
- `HomePage._buildLoanDisplay()` now uses `showScoreStatus` to hide status when only history is present.
- `HomePage._buildLoanHistoryDisplay()` added to render saved application history under the new tab.
- `Step3AdditionalInfoPage` replaced relationship text field validation with dropdown selection validation.

## Files Touched
- lib/auth/login_page.dart
- lib/auth/termOfService.dart (new)
- lib/home/home_page.dart
- lib/viewmodels/home_viewmodel.dart
- lib/loan/step3_additional_info.dart
