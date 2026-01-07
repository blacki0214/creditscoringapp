# Step 2: Personal Information Form

This document explains the Step 2 form (Personal Information) for the credit scoring application. This is where users enter their personal details, employment, residence, and credit history.

## Changelog (What Changed)
- Replaced `Age` field with `Date of Birth (DOB)` using a date picker
- Added comprehensive form validation for all fields (Vietnamese standards)
- Added input formatters for currency, phone, and ID number formatting
- Integrated auto-save to SharedPreferences via LocalStorageService
- Added Vietnamese placeholders (079 for CCCD, +84 for phone, VND currency)
- All form data persists across app restarts

## File Structure & Links
- Step 2 form page: [lib/loan/step2_personal_info.dart](lib/loan/step2_personal_info.dart)
- ViewModel (state management): [lib/viewmodels/loan_viewmodel.dart](lib/viewmodels/loan_viewmodel.dart)
- Local storage service: [lib/services/local_storage_service.dart](lib/services/local_storage_service.dart)

## Navigation Flow
```
Step 1: Selfie Page
        ↓
Step 2: Personal Information Form (this page)
        ↓
Processing Page (API call)
        ↓
Loan Results Page
```

---

## Data Structure Change: Age (int) → Date of Birth (DateTime)

### **Why This Change?**
- **Before:** Stored age as integer (e.g., `age = 30`)
- **Problem:** Age changes every year without user interaction; needs manual updating
- **Solution:** Store Date of Birth (DOB); age calculated automatically when needed
- **Benefit:** More accurate, permanent, no yearly updates required

### **ViewModel Changes**

#### **Before:**
```dart
class LoanViewModel extends ChangeNotifier {
  int age = 30;  // Static value, doesn't update with time
  
  void updatePersonalInfo({
    int? ageVal,  // Parameter name
    ...
  }) {
    if (ageVal != null) age = ageVal;  // Simple assignment
  }
}
```

#### **After:**
```dart
class LoanViewModel extends ChangeNotifier {
  DateTime? dob;  // Nullable DateTime (no DOB selected yet)
  
  void updatePersonalInfo({
    DateTime? dob,  // Parameter accepts DateTime
    ...
  }) {
    if (dob != null) this.dob = dob;  // Stores the actual date
  }
  
  // Age calculated on-the-fly when submitting
  Future<bool> submitApplication() async {
    int age = 0;
    if (dob != null) {
      final today = DateTime.now();
      age = today.year - dob!.year;
      // Adjust if birthday hasn't occurred yet this year
      if (today.month < dob!.month || 
          (today.month == dob!.month && today.day < dob!.day)) {
        age--;
      }
    }
    // Use calculated age in API request
    final request = SimpleLoanRequest(
      age: age,
      ...
    );
  }
}
```

### **Data Persistence (LocalStorage) Changes**

#### **Before (Age as Int):**
```dart
void _saveDraft() {
  LocalStorageService.saveDraft({
    'age': age,  // Saved: 30 (integer)
  });
}

void _loadDraft() {
  final draft = LocalStorageService.loadDraft();
  age = draft['age'] ?? age;  // Loaded: 30 (same integer)
}
```

#### **After (DOB as ISO8601 String):**
```dart
void _saveDraft() {
  LocalStorageService.saveDraft({
    'dob': dob?.toIso8601String(),  // Saved: "1994-06-15T00:00:00.000Z"
  });
}

void _loadDraft() {
  final draft = LocalStorageService.loadDraft();
  if (draft['dob'] != null) {
    dob = DateTime.parse(draft['dob']);  // Loaded: DateTime object
  }
}
```

**Why ISO8601?**
- Standard format for date/time serialization
- Works across all platforms
- Easy to parse back to DateTime
- Human-readable in SharedPreferences

### **Step 2 Form Changes**

#### **Before (Text Input for Age):**
```dart
final _ageController = TextEditingController();

_buildTextField(
  _ageController, 
  'Age', 
  '30', 
  keyboardType: TextInputType.number,
  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
  validator: _validateAge,
  onChanged: (val) => viewModel.updatePersonalInfo(ageVal: int.tryParse(val)),
),

String? _validateAge(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your age';
  final age = int.tryParse(value);
  if (age == null) return 'Age must be a number';
  if (age < 18) return 'Must be 18 or older';
  if (age > 100) return 'Please enter a valid age';
  return null;
}
```

**Issues:**
- User enters age manually (error-prone)
- Age becomes outdated (needs yearly updates)
- Hard to validate (what if user enters 150?)
- Lost precision (only year, no actual birthdate)

#### **After (Date Picker for DOB):**
```dart
DateTime? _selectedDOB;

_buildDateOfBirthField(viewModel)  // Custom date picker widget

Widget _buildDateOfBirthField(LoanViewModel viewModel) {
  final dobText = _selectedDOB != null 
      ? '${_selectedDOB!.day.toString().padLeft(2, '0')}/'
        '${_selectedDOB!.month.toString().padLeft(2, '0')}/'
        '${_selectedDOB!.year}'
      : '';
  
  return TextFormField(
    readOnly: true,  // Can't type, must use date picker
    controller: TextEditingController(text: dobText),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDOB ?? DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now().subtract(
          const Duration(days: 365 * 18)  // Must be 18+ years old
        ),
      );
      if (picked != null) {
        setState(() {
          _selectedDOB = picked;
        });
        viewModel.updatePersonalInfo(dob: picked);  // Pass DateTime
      }
    },
    validator: (value) => _validateDOB(_selectedDOB),
    decoration: InputDecoration(...),
  );
}

String? _validateDOB(DateTime? value) {
  if (value == null) return 'Please select your date of birth';
  final today = DateTime.now();
  final age = today.year - value.year;
  if (age < 18) return 'Must be 18 or older';
  if (age > 100) return 'Please enter a valid date of birth';
  return null;
}
```

**Advantages:**
- User picks date from calendar (intuitive, no typing errors)
- Age automatically updated (always correct)
- Better validation (can't select future dates or unrealistic ages)
- Full precision (day, month, year stored)

---

## **Data Flow Comparison**

### **Before (Age as Integer):**
```
User manually types age (e.g., "30")
        ↓
onChanged: ageVal = int.tryParse("30")  → 30 (int)
        ↓
viewModel.updatePersonalInfo(ageVal: 30)
        ↓
age = 30  (stored directly)
        ↓
_saveDraft() saves: "age": 30 (integer)
        ↓
SharedPreferences stores: age → 30
        ↓
On reload: age = draft['age'] → 30 (unchanged)
        ↓
Submit: API receives age: 30
        ↓
⚠️ Problem: Age is now 31 next year! (outdated)
```

### **After (DOB as DateTime):**
```
User taps DOB field, calendar opens
        ↓
User selects: June 15, 1994
        ↓
picked = DateTime(1994, 6, 15)
        ↓
viewModel.updatePersonalInfo(dob: picked)
        ↓
this.dob = DateTime(1994, 6, 15)  (stored as DateTime)
        ↓
_saveDraft() saves: "dob": "1994-06-15T00:00:00.000Z" (ISO8601)
        ↓
SharedPreferences stores: dob → "1994-06-15T00:00:00.000Z"
        ↓
On reload: dob = DateTime.parse("1994-06-15...") → DateTime object
        ↓
Form shows: 15/06/1994 (precomputed from DateTime)
        ↓
User closes app, reopens next year
        ↓
Submit: Calculate age = 2025 - 1994 = 31  ✅ (automatically updated!)
        ↓
API receives age: 31 (always correct)
```

---

## **Type Conversion Details**

### **DateTime → String (for Storage)**
```dart
DateTime dob = DateTime(1994, 6, 15);
String isoString = dob.toIso8601String();
// Result: "1994-06-15T00:00:00.000Z"
```

### **String → DateTime (when loading)**
```dart
String isoString = "1994-06-15T00:00:00.000Z";
DateTime dob = DateTime.parse(isoString);
// Result: DateTime(1994, 6, 15, 0, 0, 0, 0)
```

### **DateTime → Age (for API)**
```dart
DateTime dob = DateTime(1994, 6, 15);
DateTime today = DateTime.now();  // e.g., DateTime(2025, 12, 21)

int age = today.year - dob.year;  // 2025 - 1994 = 31

// Adjust if birthday hasn't occurred yet this year
if (today.month < dob.month || 
    (today.month == dob.month && today.day < dob.day)) {
  age--;  // Decrement if birthday is later in the year
}
// Result: age = 31 (correct!)
```

---

## **Initialization Changes**

### **Before (Age in initState):**
```dart
@override
void initState() {
  super.initState();
  final viewModel = context.read<LoanViewModel>();
  _ageController.text = viewModel.age.toString();  // "30"
}
```

### **After (DOB in initState):**
```dart
@override
void initState() {
  super.initState();
  final viewModel = context.read<LoanViewModel>();
  _selectedDOB = viewModel.dob;  // DateTime object or null
}
```

---

## **API Request Changes**

### **Before:**
```dart
final request = SimpleLoanRequest(
  age: age,  // Directly from ViewModel (e.g., 30)
);
```

### **After:**
```dart
// Calculate age from DOB
int age = 0;
if (dob != null) {
  final today = DateTime.now();
  age = today.year - dob!.year;
  if (today.month < dob!.month || 
      (today.month == dob!.month && today.day < dob!.day)) {
    age--;
  }
}

final request = SimpleLoanRequest(
  age: age,  // Calculated from DOB (always current!)
);
```

---

## **Summary Table**

| Aspect | Before (int age) | After (DateTime dob) |
|--------|------------------|----------------------|
| **Storage Type** | Integer | DateTime object |
| **User Input** | Manual typing | Date picker calendar |
| **Serialization** | `age: 30` | `dob: "1994-06-15T00:00:00.000Z"` |
| **Deserialization** | `int.parse()` | `DateTime.parse()` |
| **Validation** | Range check (18-100) | Date range + age check |
| **Age on API** | Direct value | Calculated at submission |
| **Auto-update** | ❌ No (outdates yearly) | ✅ Yes (always current) |
| **Precision** | Year only | Year, month, day |
| **UI Component** | Text input field | Date picker dialog |
| **Error-prone** | ✅ Yes (manual entry) | ❌ No (calendar selection) |



### **What is StatefulWidget?**
A StatefulWidget is a page that can **change and remember data**.

```dart
class Step2PersonalInfoPage extends StatefulWidget {
  const Step2PersonalInfoPage({super.key});

  @override
  State<Step2PersonalInfoPage> createState() => _Step2PersonalInfoPageState();
}
```

**Explanation:**
- `Step2PersonalInfoPage` = The page blueprint
- `createState()` = Creates the actual working version (`_Step2PersonalInfoPageState`)
- The `_` prefix means private (only this file can use it)

---

## **Section 2: Text Field Controllers**

### **What are Controllers?**
Controllers are bridges between your Dart code and text input fields. They:
- **Store** what user types
- **Read** the current value
- **Update** values programmatically
- **Listen** for changes

```dart
final _nameController = TextEditingController();
final _phoneController = TextEditingController();
final _idController = TextEditingController();
final _addressController = TextEditingController();
DateTime? _selectedDOB;  // Date of Birth (now using DateTime, not a controller)
final _monthlyIncomeController = TextEditingController();
final _yearsEmployedController = TextEditingController();
final _yearsCreditHistoryController = TextEditingController();
```

**Example Usage:**
```dart
// Read current value
String name = _nameController.text;

// Set a value
_nameController.text = "Nguyen Van A";

// Clear the field
_nameController.clear();
```

---

## **Section 3: Vietnamese Data Lists**

```dart
final List<String> employmentOptions = ['EMPLOYED', 'SELF_EMPLOYED', 'UNEMPLOYED', 'STUDENT', 'RETIRED'];
final List<String> homeOwnershipOptions = ['RENT', 'OWN', 'MORTGAGE', 'LIVING_WITH_PARENTS', 'OTHER'];
final List<String> loanPurposeOptions = [
  'PERSONAL', 
  'EDUCATION', 
  'MEDICAL', 
  'BUSINESS', 
  'HOME_IMPROVEMENT', 
  'DEBT_CONSOLIDATION', 
  'VENTURE', 
  'OTHER'
];
```

**Explanation:**
- These are dropdown menu options
- Used for fields like Employment Status, Home Ownership, Loan Purpose
- Enum-style (all caps) for database compatibility

---

## **Section 4: Form Validators**

### **What is Validation?**
Validation checks if user input is correct and safe. Each field has its own validator.

#### **Name Validator**
```dart
String? _validateName(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your full name';
  if (value.length < 3) return 'Name must be at least 3 characters';
  if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) return 'Name can only contain letters';
  return null;  // null = valid (no error)
}
```

**Checks:**
- Not empty ✓
- At least 3 characters ✓
- Only letters and spaces (no numbers) ✓

**Example:**
```
"A" → Error: "Name must be at least 3 characters"
"Nguyen123" → Error: "Name can only contain letters"
"Nguyen Van A" → Valid ✓
```

---

#### **Date of Birth Validator**
```dart
String? _validateDOB(DateTime? value) {
  if (value == null) return 'Please select your date of birth';
  final today = DateTime.now();
  final age = today.year - value.year;
  if (age < 18) return 'Must be 18 or older';
  if (age > 100) return 'Please enter a valid date of birth';
  return null;
}
```

**Checks:**
- Not empty ✓
- Age is 18 or older ✓
- Age is 100 or younger (reasonable) ✓

**Example:**
```
User born 2010 → Error: "Must be 18 or older"
User born 1950 → Error: "Please enter a valid date of birth"
User born 1998 → Valid ✓
```

---

#### **Phone Validator**
```dart
String? _validatePhone(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your phone number';
  final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');  // Remove formatting
  if (cleaned.length < 9 || cleaned.length > 12) return 'Invalid phone number';
  if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) return 'Phone can only contain numbers';
  return null;
}
```

**Checks:**
- Not empty ✓
- 9-12 digits (after removing formatting) ✓
- Only numbers (allows +, -, (, ), space for formatting) ✓

**Example:**
```
"+84 (901) 234-567" → Valid ✓ (9 digits: 84901234567)
"+84 901" → Error: "Invalid phone number" (too short)
"+84 901 ABC 1234" → Error: "Phone can only contain numbers"
```

---

#### **ID Number Validator**
```dart
String? _validateID(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your ID number';
  if (value.length < 9 || value.length > 12) return 'ID must be 9-12 digits';
  if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'ID can only contain numbers';
  return null;
}
```

**Checks:**
- Not empty ✓
- 9-12 digits (Vietnamese CCCD format) ✓
- Only digits ✓

**Example:**
```
"079" → Error: "ID must be 9-12 digits"
"079123456789" → Valid ✓ (12 digits)
```

---

#### **Monthly Income Validator**
```dart
String? _validateIncome(String? value) {
  if (value == null || value.isEmpty) return 'Please enter your monthly income';
  final cleaned = value.replaceAll(RegExp(r'[,\.]'), '');  // Remove thousand separators
  final income = double.tryParse(cleaned);
  if (income == null) return 'Income must be a number';
  if (income < 0) return 'Income cannot be negative';
  if (income > 1000000000) return 'Please enter a valid income';
  return null;
}
```

**Checks:**
- Not empty ✓
- Valid number ✓
- Non-negative ✓
- Less than 1 billion VND ✓

**Example:**
```
"15,000,000" → Valid ✓ (1.5M VND)
"-500,000" → Error: "Income cannot be negative"
"2,000,000,000" → Error: "Please enter a valid income" (over limit)
```

---

#### **Years Validator (Employment, Credit History)**
```dart
String? _validateYears(String? value, String fieldName) {
  if (value == null || value.isEmpty) return 'Please enter $fieldName';
  final years = double.tryParse(value);
  if (years == null) return '$fieldName must be a number';
  if (years < 0) return '$fieldName cannot be negative';
  if (years > 50) return 'Please enter a valid number of years';
  return null;
}
```

**Checks:**
- Not empty ✓
- Valid number (can be decimal like 2.5) ✓
- Non-negative ✓
- Less than 50 years ✓

**Example:**
```
"5" → Valid ✓
"2.5" → Valid ✓ (2.5 years)
"-1" → Error: "cannot be negative"
"100" → Error: "Please enter a valid number of years"
```

---

## **Section 5: Input Formatters**

### **What are Input Formatters?**
Formatters control what characters user can type and automatically format the display.

#### **Digits Only**
```dart
FilteringTextInputFormatter.digitsOnly
```
- Allows: 0-9 only
- Used for: Age, ID Number, Years

**Example:**
```
User types: "1 2 a 3"
Formatter removes letters and spaces
Result: "123"
```

---

#### **Phone Format**
```dart
FilteringTextInputFormatter.allow(RegExp(r'[0-9\+\-\(\)\s]'))
```
- Allows: Numbers, +, -, (, ), space
- Used for: Phone number

**Example:**
```
User can type: "+84 (901) 234-567"
Formatter removes other characters
Result: "+84 (901) 234-567" ✓
```

---

#### **Currency Formatting**
```dart
TextInputFormatter.withFunction((oldValue, newValue) {
  if (newValue.text.isEmpty) return newValue;
  final number = int.tryParse(newValue.text);
  if (number == null) return oldValue;
  final formatted = _currencyFormatter.format(number);
  return TextEditingValue(
    text: formatted,
    selection: TextSelection.collapsed(offset: formatted.length),
  );
})
```

**How it works:**
1. User types: "15000000"
2. Formatter parses as number: 15000000
3. Formatter applies thousand separators: "15,000,000"
4. Display shows: "15,000,000"
5. Save uses cleaned value: 15000000

**Example:**
```
User types:      "1" "5" "0" "0" "0" "0" "0" "0"
Formatter shows: "1" "15" "150" "1,500" "15,000" "150,000" "1,500,000" "15,000,000"
```

---

## **Section 6: initState() - Initialize Page**

```dart
@override
void initState() {
  super.initState();
  // Initialize controllers with data from ViewModel
  final viewModel = context.read<LoanViewModel>();
  _nameController.text = viewModel.fullName;
  _phoneController.text = viewModel.phoneNumber;
  _idController.text = viewModel.idNumber;
  _addressController.text = viewModel.address;
  _selectedDOB = viewModel.dob;  // Load saved DOB
  _monthlyIncomeController.text = viewModel.monthlyIncome.toStringAsFixed(0);
  _yearsEmployedController.text = viewModel.yearsEmployed.toString();
  _yearsCreditHistoryController.text = viewModel.yearsCreditHistory.toString();
}
```

**What it does:**
- Runs **once** when the page opens
- Loads saved data from ViewModel (from SharedPreferences)
- Fills all form fields with previous values
- If user closes app and reopens: **data persists** ✓

**Why important?**
- User doesn't lose their form data
- User can continue where they left off
- Better UX (not asking same questions again)

---

## **Section 7: Build() - Display UI**

```dart
@override
Widget build(BuildContext context) {
  final viewModel = context.watch<LoanViewModel>();
  
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(...),
    body: SafeArea(...),
  );
}
```

**Explanation:**
- `context.watch<LoanViewModel>()` = Watch for ViewModel changes
- When ViewModel updates, this widget rebuilds automatically
- `Scaffold` = Basic page structure (AppBar + Body)
- `SafeArea` = Avoid notches and status bars on phones

---

## **Section 8: Form Sections**

### **Personal Details Section**
```dart
_buildSectionHeader('Personal Details'),
_buildTextField(_nameController, 'Full Name', 'Nguyen Van A', validator: _validateName, ...),
_buildDateOfBirthField(viewModel),  // Date picker
_buildTextField(_phoneController, 'Phone Number', '+84', validator: _validatePhone, ...),
_buildTextField(_idController, 'ID Number (CCCD)', '079', validator: _validateID, ...),
```

**Fields:**
1. Full Name - Text input, Vietnamese name
2. Date of Birth - Date picker (calculates age automatically)
3. Phone Number - Text input, Vietnamese format
4. ID Number - Text input, 9-12 digits

---

### **Employment & Income Section**
```dart
_buildDropdown('Employment Status', viewModel.employmentStatus, employmentOptions, ...),
_buildTextField(_yearsEmployedController, 'Years Employed', '5', ...),
_buildTextField(_monthlyIncomeController, 'Monthly Income (VND)', '15,000,000', ...),
```

**Fields:**
1. Employment Status - Dropdown (EMPLOYED, SELF_EMPLOYED, etc.)
2. Years Employed - Number input (can be decimal like 2.5)
3. Monthly Income - Currency input with thousand separators

---

### **Residence & Assets Section**
```dart
_buildDropdown('Home Ownership', viewModel.homeOwnership, homeOwnershipOptions, ...),
_buildTextField(_addressController, 'Current Address', '123 Street...', ...),
```

**Fields:**
1. Home Ownership - Dropdown (RENT, OWN, MORTGAGE, etc.)
2. Current Address - Text input

---

### **Loan Request Section**
```dart
_buildDropdown('Loan Purpose', viewModel.loanPurpose, loanPurposeOptions, ...),
```

**Fields:**
1. Loan Purpose - Dropdown (PERSONAL, EDUCATION, MEDICAL, etc.)

---

### **Credit History Section**
```dart
_buildTextField(_yearsCreditHistoryController, 'Years Credit History', '2', ...),
SwitchListTile(title: const Text('Have you ever defaulted?'), ...),
SwitchListTile(title: const Text('Currently defaulting?'), ...),
```

**Fields:**
1. Years Credit History - Number input
2. Previous Defaults - Toggle switch (yes/no)
3. Current Defaulting - Toggle switch (yes/no)

---

## **Section 9: _buildTextField() - Reusable Text Input**

```dart
Widget _buildTextField(
  TextEditingController controller,        // Which field to control
  String label,                            // Label above field
  String hint,                             // Placeholder text
  {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,           // Called when text changes
    String? Function(String?)? validator,  // Validation function
    List<TextInputFormatter>? inputFormatters,  // Formatting rules
  }
) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    onChanged: onChanged,
    inputFormatters: inputFormatters,
    validator: validator ?? (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter $label';
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4C40F7), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
    ),
  );
}
```

**Parameters:**
- `controller` = Manages text input/output
- `label` = Field name (shown above)
- `hint` = Placeholder (gray text inside field)
- `keyboardType` = Mobile keyboard type (text, number, phone, email, etc.)
- `onChanged` = Callback when user types (auto-save to ViewModel)
- `validator` = Function to check if valid
- `inputFormatters` = Rules for what characters are allowed

**Visual Example:**
```
┌─────────────────────────────┐
│ Full Name                   │ ← Label
│ Nguyen Van A                │ ← User input
│ (Placeholder text faded)    │ ← Hint (before typing)
└─────────────────────────────┘

When focused (user typing):
┌═════════════════════════════┐  ← Purple border
│ Full Name                   │
│ Nguyen Van A                │
└═════════════════════════════┘

When validation error:
┌─────────────────────────────┐
│ Full Name                   │
│ (blank)                     │
└─────────────────────────────┘
! Name must be at least 3 chars  ← Red error text
```

---

## **Section 10: _buildDateOfBirthField() - Date Picker**

```dart
Widget _buildDateOfBirthField(LoanViewModel viewModel) {
  final dobText = _selectedDOB != null 
      ? '${_selectedDOB!.day.toString().padLeft(2, '0')}/${_selectedDOB!.month.toString().padLeft(2, '0')}/${_selectedDOB!.year}'
      : '';
  
  return TextFormField(
    readOnly: true,  // User can't type, only pick date
    controller: TextEditingController(text: dobText),
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _selectedDOB ?? DateTime(2000),
        firstDate: DateTime(1950),
        lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      );
      if (picked != null) {
        setState(() {
          _selectedDOB = picked;
        });
        viewModel.updatePersonalInfo(dob: picked);
      }
    },
    validator: (value) => _validateDOB(_selectedDOB),
    decoration: InputDecoration(...),
  );
}
```

**How it works:**
1. User taps the field
2. Date picker dialog opens (calendar)
3. User selects a date
4. Field shows formatted date: "DD/MM/YYYY"
5. Auto-save to ViewModel

**Date Picker Constraints:**
- `initialDate: _selectedDOB ?? DateTime(2000)` = Start at saved date or year 2000
- `firstDate: DateTime(1950)` = Can't select before 1950
- `lastDate: DateTime.now().subtract(Duration(days: 365 * 18))` = Can't select less than 18 years ago

---

## **Section 11: _buildDropdown() - Reusable Dropdown**

```dart
Widget _buildDropdown(
  String label,
  String value,
  List<String> items,
  Function(String?) onChanged,
) {
  return DropdownButtonFormField<String>(
    value: value,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      // ... styling
    ),
    items: items.map((item) => 
      DropdownMenuItem(value: item, child: Text(item, overflow: TextOverflow.ellipsis))
    ).toList(),
    onChanged: onChanged,
  );
}
```

**Visual Example:**
```
┌──────────────────────────┐
│ Employment Status        │ ← Label
│ [EMPLOYED           ▼]   │ ← Current value + dropdown arrow
└──────────────────────────┘

When tapped, shows:
┌──────────────────────────┐
│ EMPLOYED                 │ ← Highlighted (current)
│ SELF_EMPLOYED            │
│ UNEMPLOYED               │
│ STUDENT                  │
│ RETIRED                  │
└──────────────────────────┘
```

---

## **Section 12: Data Flow - Auto-Save**

When user types something:

```
User types in "Full Name" field
        ↓
onChanged callback triggered with new text
        ↓
viewModel.updatePersonalInfo(name: val)  ← Saves to ViewModel
        ↓
LoanViewModel calls _saveDraft()
        ↓
LocalStorageService.saveDraft() called
        ↓
SharedPreferences saves to device storage
        ↓
✓ Data persists across app restarts
```

**Code Example:**
```dart
_buildTextField(
  _nameController, 
  'Full Name', 
  'Nguyen Van A',
  validator: _validateName,
  onChanged: (val) => viewModel.updatePersonalInfo(name: val),  // ← Auto-save here
),
```

---

## **Section 13: Form Submission**

```dart
Future<void> _submitApplication(BuildContext context) async {
  if (_formKey.currentState!.validate()) {  // Check all validators pass
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProcessingPage(),
      ),
    );
  }
}
```

**Steps:**
1. User taps "Submit Application" button
2. `_formKey.currentState!.validate()` = Check all fields
3. If any field has error:
   - Show red border
   - Show error message
   - Don't proceed
4. If all valid:
   - Navigate to ProcessingPage
   - ProcessingPage triggers API call
   - Results displayed

---

## **Section 14: dispose() - Cleanup**

```dart
@override
void dispose() {
  _nameController.dispose();
  _phoneController.dispose();
  _idController.dispose();
  _addressController.dispose();
  _monthlyIncomeController.dispose();
  _yearsEmployedController.dispose();
  _yearsCreditHistoryController.dispose();
  super.dispose();
}
```

**What it does:**
- Runs **once** when user leaves the page
- Frees up memory used by controllers
- Stops listening to text changes
- **Prevents memory leaks** (very important!)

**Why important?**
- Over time, undisposed objects crash the app
- Memory usage increases continuously
- Garbage collector can't clean up old data

---

## **Integration with ViewModel**

The form connects to `LoanViewModel` which:
1. **Holds data** in memory (currentPersonalInfo object)
2. **Auto-saves** to SharedPreferences on every update
3. **Auto-loads** on app startup (in constructor)
4. **Validates** before submission
5. **Sends to API** on submit
6. **Clears draft** after successful submission

**Data Persistence Flow:**
```
App opens
    ↓
LocalStorageService.init() called
    ↓
ViewModel constructor calls _loadDraft()
    ↓
SharedPreferences returns saved data
    ↓
Form fields pre-populated with saved values
    ↓
User edits form
    ↓
onChanged calls updatePersonalInfo()
    ↓
_saveDraft() saves to SharedPreferences
    ↓
User closes app
    ↓
Next app open: data is there! ✓
```

---

## **Vietnamese Localization**

- **ID Placeholder:** `079` (CCCD format)
- **Phone Placeholder:** `+84` (Vietnam country code)
- **Currency:** VND with thousand separators (15,000,000)
- **Date Format:** DD/MM/YYYY
- **Validators:** Vietnamese age requirements (18+)
- **Numbers:** Support Vietnamese formatting

---

## **Key Learning Points**

1. **Controllers** = Text field managers
2. **Validators** = Check if input is correct
3. **Input Formatters** = Control what user can type
4. **onChanged** = Auto-save to ViewModel
5. **initState** = Load saved data on page open
6. **dispose** = Clean up memory
7. **Date Picker** = Better UX than typing dates
8. **LocalStorageService** = Persist data locally
9. **ViewModel** = Connect form to storage/API
10. **Form validation** = Check before submission

---

## **Common Problems & Solutions**

| Problem | Solution |
|---------|----------|
| Form data lost on app close | Make sure LocalStorageService.init() is called in main() |
| Date picker shows wrong date | Check DateTime.now() and ensure date math is correct |
| Currency formatter not working | Ensure FilteringTextInputFormatter.digitsOnly comes first |
| Phone validation too strict | Adjust regex if needed (currently 9-12 digits) |
| Vietnamese characters in name | Update regex from `^[a-zA-Z\s]` if needed |
| Fields not updating ViewModel | Check onChanged callback is calling updatePersonalInfo() |

---

## **Next Steps**

1. Test form with valid/invalid data
2. Close app and reopen to verify auto-save
3. Check currency formatting works (15000000 → 15,000,000)
4. Test date picker on mobile and desktop
5. Verify all validators show correct error messages
6. Test form submission flow to ProcessingPage

Good luck! 🚀
