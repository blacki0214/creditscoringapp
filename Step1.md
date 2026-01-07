# Step 1: eKYC Identity Verification (Front ID → Back ID → Selfie)

This document explains the Step 1 eKYC (Electronic Know-Your-Customer) flow. Users capture their ID card (front & back) and take a selfie. All images are stored as bytes for cross-platform compatibility (web, mobile, desktop).

## Changelog (What Changed)
- **Complete Rebuild:** All three pages (Front ID, Back ID, Selfie) rebuilt with clean, simple code
- **Camera Support:** Mobile devices (Android/iOS) use camera via `image_picker` package
- **Desktop/Web Fallback:** Desktop and web use `file_picker` to select images from file system
- **Bytes-Based Storage:** Images stored as `Uint8List` (no `dart:io File`) for web compatibility
- **Fixed Layout Issues:** Removed Spacer() and complex nesting; use SingleChildScrollView + SizedBox for spacing
- **Mobile Detection:** Automatic detection of platform type with fallback behavior
- **Navigation Flow:** Front ID → Back ID → Selfie → Step 2 Personal Information
- **Cross-Drive Build Fix:** Resolved Kotlin cache compilation errors by deleting build folder

## File Structure & Links
- Front ID page: [lib/loan/step1_front_id.dart](lib/loan/step1_front_id.dart) - Capture front side of ID card
- Back ID page: [lib/loan/step1_back_id.dart](lib/loan/step1_back_id.dart) - Capture back side of ID card
- Selfie page: [lib/loan/step1_selfie.dart](lib/loan/step1_selfie.dart) - Capture user's selfie photo
- Entry point: [lib/loan/step1_verify_identity.dart](lib/loan/step1_verify_identity.dart) - Step 1 intro screen
- ViewModel: [lib/viewmodels/loan_viewmodel.dart](lib/viewmodels/loan_viewmodel.dart) - State management

## Platform Behavior (All Three Pages)

### **Mobile (Android & iOS)**
- Uses **camera** via `image_picker` package
- Opens native camera app (rear camera for ID, front camera for selfie)
- User takes photo and confirms
- Requests runtime camera permission using `permission_handler`
- Image saved as `Uint8List` bytes in memory

### **Desktop (Windows/Linux/macOS)**
- Uses **file picker** via `file_picker` package
- Opens file explorer to select image files
- Supports JPG, PNG, and other image formats
- No camera access needed (files only)
- Image loaded as `Uint8List` bytes

### **Web**
- Uses **file picker** via `file_picker` package
- Opens browser file dialog
- No camera access (browser limitation)
- Image converted to bytes
- Works on all browsers

### **Storage Format**
- All images stored as `Uint8List` (byte array)
- No platform-specific File classes used
- Ensures compatibility across all platforms
- Bytes can be sent directly to API

### **Continue Button Behavior**
- **Disabled (gray)** until image is captured
- **Enabled (blue)** once image exists
- Visual feedback: color change + text color change

## Key Functions (Common Pattern Across All Pages)

### **takeCameraPhoto() / takeSelfie()**
```dart
Future<void> takePhoto() async {
  try {
    // Detect if running on mobile
    final _isMobile = !kIsWeb && (
      defaultTargetPlatform == TargetPlatform.android || 
      defaultTargetPlatform == TargetPlatform.iOS
    );

    if (_isMobile) {
      // Mobile: Open camera
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,  // Back camera for ID
      );
      // Store bytes
      if (photo != null) {
        setState(() {
          imageData = await photo.readAsBytes();
          isLoading = false;
        });
      }
    } else {
      // Desktop/Web: Open file picker
      final result = await _filePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.first.bytes != null) {
        setState(() {
          imageData = result.files.first.bytes!;
          isLoading = false;
        });
      }
    }
  } catch (e) {
    // Show error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

**Explanation:**
1. Check if running on mobile
2. If mobile: Open camera (different devices use device camera)
3. If desktop/web: Open file picker
4. Read image as bytes (`Uint8List`)
5. Store in `imageData` variable
6. Show error if something fails

**Front ID Page:**
- Rear camera on mobile
- Instructions: "Tap to take photo of your ID Card (Front)"

**Back ID Page:**
- Rear camera on mobile (same as front)
- Instructions: "Tap to take photo of your ID Card (Back)"

**Selfie Page:**
- Front camera on mobile (selfie mode)
- Rear camera on desktop/web via file picker
- Instructions: "Tap to take your selfie"

---

### **clearImage() / retakePhoto()**
```dart
void clearImage() {
  setState(() {
    imageData = null;  // Delete stored bytes
  });
}
```

**What happens:**
1. User taps "Retake Photo" button
2. Image bytes are deleted
3. UI shows camera placeholder again
4. Continue button becomes disabled
5. User can take another photo

---

### **Continue Button Check**
```dart
// Continue button is enabled only if imageData exists
onPressed: imageData != null
    ? () {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => const Step1BackIDPage(),  // Go to next page
        ));
      }
    : null,  // Button disabled
```

**Logic:**
- `imageData != null` = Photo taken → Button enabled (blue)
- `imageData == null` = No photo → Button disabled (gray)

## Navigation Flow

```
Loan Application Home
        ↓
Step1VerifyIdentity (Entry intro page)
        ↓
Step1FrontIDPage (Capture ID front)
        ↓
Step1BackIDPage (Capture ID back)
        ↓
Step1SelfiePage (Capture selfie)
        ↓
Step2PersonalInfoPage (Fill form)
        ↓
ProcessingPage (API call)
        ↓
Results Page (Loan decision)
```

**Each step requires image before proceeding:**
1. User can't skip Front ID → Continue button disabled until photo taken
2. User can't skip Back ID → Continue button disabled until photo taken
3. User can't skip Selfie → Continue button disabled until photo taken
4. Only then: Proceed to Step 2 Personal Information

---

## Code Structure Overview

### **Front ID Page (step1_front_id.dart)**
```dart
class Step1FrontIDPage extends StatefulWidget { ... }

class _Step1FrontIDPageState extends State<Step1FrontIDPage> {
  Uint8List? imageData;           // Stores image bytes (null = no photo)
  bool isLoading = false;         // Loading indicator while capturing
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.instance;
  
  Future<void> takePhoto() async { ... }   // Camera/file picker
  void clearImage() { ... }                // Retake photo
  
  @override
  Widget build(BuildContext context) { ... }  // Display UI
  
  @override
  void dispose() { ... }           // Cleanup
}
```

### **Back ID Page (step1_back_id.dart)**
- **Identical structure** to Front ID
- Same variable names, same functions
- Only difference: Label says "Back" instead of "Front"

### **Selfie Page (step1_selfie.dart)**
- **Same structure** as Front/Back
- Difference: Uses front camera on mobile (selfie mode)
- `preferredCameraDevice: CameraDevice.front` instead of `.rear`

### **Entry Point (step1_verify_identity.dart)**
- Shows Step 1 intro screen
- Explains what user will do
- "Continue" button navigates to Step1FrontIDPage
- Has LayoutBuilder to handle layout overflow issues

---

## Key Variables Explained

### **imageData / _capturedBytes**
```dart
Uint8List? imageData;
```
- Stores the image as bytes
- `Uint8List` = List of unsigned 8-bit integers (0-255 each byte)
- `?` = Optional (can be null/empty)
- Example: `[255, 200, 150, 100, ...]` represents pixel colors
- **Why bytes?** Can send directly to API, works on all platforms

### **isLoading**
```dart
bool isLoading = false;
```
- Shows loading spinner while camera app is open
- Set to `true` when user opens camera
- Set to `false` when photo is captured
- Used to disable/enable Continue button during loading

### **_imagePicker**
```dart
final ImagePicker _imagePicker = ImagePicker();
```
- Tool for accessing device camera
- `final` = Created once, never changes
- `_` prefix = Private (only this file uses it)
- Called with: `_imagePicker.pickImage(source: ImageSource.camera)`

### **_filePicker**
```dart
final FilePicker _filePicker = FilePicker.instance;
```
- Tool for selecting files from device
- Works on desktop/web (no camera)
- Called with: `_filePicker.pickFiles(type: FileType.image, withData: true)`
- `withData: true` = Return file bytes (not just path)

---

## **Detailed Code Breakdown**

### **Section 1: Imports**

```dart
import 'package:flutter/material.dart';
```
- Material Design library (buttons, cards, AppBar, etc.)

```dart
import 'package:image_picker/image_picker.dart';
```
- Camera and gallery access package
- Required for mobile camera

```dart
import 'package:file_picker/file_picker.dart';
```
- File selection on desktop and web
- Required for Windows/Linux/macOS/Web

```dart
import 'package:permission_handler/permission_handler.dart';
```
- Request runtime permissions (camera, photos, etc.)
- Android 6+ requires explicit permission requests

```dart
import 'package:flutter/foundation.dart';
```
- `kIsWeb` constant for detecting if running on web
- Used for platform detection

```dart
import 'step1_back_id.dart';
```
- Import the next page (Back ID)
- Allows navigation when user taps Continue

---

### **Section 2: StatefulWidget & State**

```dart
class Step1FrontIDPage extends StatefulWidget {
  const Step1FrontIDPage({super.key});

  @override
  State<Step1FrontIDPage> createState() => _Step1FrontIDPageState();
}
```

**Explanation:**
- `Step1FrontIDPage` = The page blueprint
- `createState()` = Creates the actual working version
- `_Step1FrontIDPageState` = Private state class (contains logic)

**Why StatefulWidget?**
- Page needs to remember if photo was taken
- Page needs to update when user takes photo
- Non-stateful pages can't change/update

---

### **Section 3: State Class & Variables**

```dart
class _Step1FrontIDPageState extends State<Step1FrontIDPage> {
  Uint8List? imageData;
  bool isLoading = false;
  final ImagePicker _imagePicker = ImagePicker();
  final FilePicker _filePicker = FilePicker.instance;
```

**Variable Breakdown:**

| Variable | Type | Purpose | Example |
|----------|------|---------|---------|
| `imageData` | `Uint8List?` | Stores photo as bytes | `[255, 200, 150, ...]` |
| `isLoading` | `bool` | Shows loading spinner | `true` while camera open |
| `_imagePicker` | `ImagePicker` | Camera tool | `_imagePicker.pickImage()` |
| `_filePicker` | `FilePicker` | File picker tool | `_filePicker.pickFiles()` |

---

### **Section 4: Platform Detection**

```dart
bool get _isMobile {
  return !kIsWeb && (
    defaultTargetPlatform == TargetPlatform.android || 
    defaultTargetPlatform == TargetPlatform.iOS
  );
}
```

**Explanation:**
- `_isMobile` = Getter function (read-only property)
- `!kIsWeb` = Not running on web
- `defaultTargetPlatform == TargetPlatform.android` = Running on Android
- `defaultTargetPlatform == TargetPlatform.iOS` = Running on iOS
- Result: `true` if mobile, `false` if desktop/web

**Usage:**
```dart
if (_isMobile) {
  // Open mobile camera
} else {
  // Open desktop file picker
}
```

---

### **Section 5: takePhoto() Function**

```dart
Future<void> takePhoto() async {
  try {
    setState(() => isLoading = true);
```

**Explanation:**
- `Future<void>` = This takes time and returns nothing
- `async` = Can wait for things (camera app)
- `try` = Try to do the following; catch errors if fail
- `setState(() => isLoading = true)` = Show loading spinner

---

```dart
    if (_isMobile) {
      final photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
```

**Explanation:**
- `if (_isMobile)` = Only do this on phones
- `await _imagePicker.pickImage()` = Open camera, wait for photo
- `source: ImageSource.camera` = Use camera (not gallery)
- `preferredCameraDevice: CameraDevice.rear` = Back camera for ID

---

```dart
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            imageData = bytes;
            isLoading = false;
          });
        }
      }
    } else {
```

**Explanation:**
- `if (photo != null)` = User didn't cancel
- `await photo.readAsBytes()` = Convert photo to bytes
- `if (mounted)` = Check page still exists (safety check)
- `setState()` = Update UI with new image data
- `imageData = bytes` = Store the bytes
- `isLoading = false` = Hide loading spinner

---

```dart
      final result = await _filePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final bytes = result.files.first.bytes;
        if (bytes != null && mounted) {
          setState(() {
            imageData = bytes;
            isLoading = false;
          });
        }
      }
```

**Explanation:**
- `await _filePicker.pickFiles()` = Open file picker, wait for selection
- `type: FileType.image` = Only show image files
- `withData: true` = Return bytes (not just file path)
- `result.files.first.bytes` = Get bytes of selected file
- Rest is same as mobile: store bytes, update UI

---

```dart
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
```

**Explanation:**
- `catch (e)` = If anything fails, catch error
- `e` = The error message/exception
- `ScaffoldMessenger.showSnackBar()` = Show message at bottom of screen
- `'Error: $e'` = Display the error to user

---

### **Section 6: clearImage() Function**

```dart
void clearImage() {
  setState(() {
    imageData = null;
  });
}
```

**Explanation:**
- `void` = Returns nothing
- `setState()` = Update the UI
- `imageData = null` = Delete stored bytes
- Result: Screen shows camera placeholder again, Continue button disabled

---

### **Section 7: Build Function**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(...),
    body: SafeArea(...),
  );
}
```

**Explanation:**
- `build()` = Creates the UI
- Called when page loads and when `setState()` is used
- `Scaffold` = Basic page structure (AppBar + Body)
- `SafeArea` = Avoids notches on phones
- `appBar` = Top bar with back button and title
- `body` = Main content

---

### **Section 8: AppBar (Top Bar)**

```dart
AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () => Navigator.pop(context),
  ),
  title: const Text(
    'Step 1: Verify your identity',
    style: TextStyle(color: Colors.black, fontSize: 16),
  ),
)
```

**Explanation:**
- `backgroundColor: Colors.transparent` = See-through background
- `elevation: 0` = No shadow
- `leading:` = Left side (back button)
- `IconButton()` = Clickable button
- `Icons.arrow_back` = Back arrow icon
- `onPressed: () => Navigator.pop(context)` = Go to previous page when tapped
- `title:` = Center text showing page title
- `'Step 1: Verify your identity'` = The title text

**Visual Result:**
```
┌──────────────────────────────────────┐
│ ← Step 1: Verify your identity       │
└──────────────────────────────────────┘
```

---

### **Section 9: Body Layout**

```dart
body: SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
```

**Explanation:**
- `SafeArea` = Avoid notches/status bars
- `SingleChildScrollView` = Allows scrolling if content too tall
- `padding: EdgeInsets.all(24)` = 24 pixels space on all sides
- `Column` = Arrange items vertically
- `crossAxisAlignment: CrossAxisAlignment.center` = Center items horizontally

**Visual:**
```
┌─────────────────────────────────────────┐
│ (24px padding)                          │
│   ┌───────────────────────────────────┐ │
│   │   Step 1: Verify your identity    │ │
│   │   (content centered here)         │ │
│   │                                   │ │
│   │   [Camera Placeholder or Photo]   │ │
│   │                                   │ │
│   │        [Continue Button ⭕]        │ │
│   └───────────────────────────────────┘ │
│ (24px padding)                          │
└─────────────────────────────────────────┘
```

---

### **Section 10: Title & Description**

```dart
const Text(
  'Step 1: Verify your identity',
  style: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1F3F),
  ),
),
const SizedBox(height: 20),
const Text(
  'Please capture a clear photo of your ID Card',
  style: TextStyle(fontSize: 14, color: Colors.grey),
),
const SizedBox(height: 40),
```

**Explanation:**
- First Text = Title (24px, bold, dark blue)
- `SizedBox(height: 20)` = 20px space
- Second Text = Description (14px, gray)
- `SizedBox(height: 40)` = 40px space before content

---

### **Section 11: Camera Placeholder (When No Photo)**

```dart
if (imageData == null)
  GestureDetector(
    onTap: takePhoto,
    child: Container(
      width: double.infinity,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF4C40F7),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 80,
            color: const Color(0xFF4C40F7),
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to take photo\nof your ID Card (Front)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    ),
  )
```

**Explanation:**
- `if (imageData == null)` = Show placeholder if no photo taken yet
- `GestureDetector(onTap: takePhoto)` = Tapping the box opens camera
- `Container` = Box to hold content
- `width: double.infinity` = Full width
- `height: 280` = Fixed 280px height
- `color: Colors.grey.shade200` = Light gray background
- `borderRadius: BorderRadius.circular(16)` = Round corners
- `border: Border.all(...)` = Purple border
- `Column` with `mainAxisAlignment: MainAxisAlignment.center` = Center content vertically
- `Icons.camera_alt` = Camera icon (80px, purple)
- `Text` = Instructions

**Visual Result:**
```
┌─────────────────────────────────────┐
│                                     │
│              📷                     │
│                                     │
│    Tap to take photo               │
│    of your ID Card (Front)         │
│                                     │
└─────────────────────────────────────┘
```

---

### **Section 12: Image Preview (When Photo Taken)**

```dart
else
  Column(
    children: [
      Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.green,
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            imageData!,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: clearImage,
        icon: const Icon(Icons.refresh),
        label: const Text('Retake Photo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade400,
        ),
      ),
    ],
  )
```

**Explanation:**
- `else` = Show this if photo IS taken
- `Container` = Same size box as placeholder
- `border: Border.all(color: Colors.green, ...)` = Green border (shows success)
- `ClipRRect` = Clip image to rounded corners
- `Image.memory(imageData!, ...)` = Display the photo bytes
- `imageData!` = Force unwrap (we know it's not null)
- `fit: BoxFit.cover` = Fill box, crop if needed
- `ElevatedButton.icon()` = Button with icon + text
- `onPressed: clearImage` = Tapping retake calls clearImage()
- `Icons.refresh` = Refresh/reload icon
- `'Retake Photo'` = Button text

**Visual Result:**
```
┌─────────────────────────────────────┐
│     [Actual photo displayed]        │ (green border)
│        (rounded corners)            │
└─────────────────────────────────────┘
       [🔄 Retake Photo]  (gray button)
```

---

### **Section 13: Continue Button**

```dart
const Spacer(),
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: imageData != null
        ? const Color(0xFF4C40F7)
        : Colors.grey.shade300,
    shape: BoxShape.circle,
  ),
  child: IconButton(
    onPressed: imageData != null
        ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const Step1BackIDPage(),
              ),
            );
          }
        : null,
    icon: Icon(
      Icons.arrow_forward,
      color: imageData != null ? Colors.white : Colors.grey,
      size: 32,
    ),
  ),
),
const SizedBox(height: 20),
Text(
  'Continue',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: imageData != null
        ? const Color(0xFF4C40F7)
        : Colors.grey.shade400,
  ),
),
```

**Explanation:**
- `Spacer()` = Takes up remaining space (pushes button to bottom)
- `Container` = Circular button container
- `width: 80, height: 80` = 80x80 pixels (circle)
- `color: imageData != null ? ... : ...` = Conditional color
  - If photo taken: Purple (`0xFF4C40F7`)
  - If no photo: Light gray (`Colors.grey.shade300`)
- `shape: BoxShape.circle` = Make it circular
- `IconButton` = Button inside circle
- `onPressed: imageData != null ? ... : null` = Conditional action
  - If photo taken: Navigate to next page
  - If no photo: `null` (disabled)
- `Icons.arrow_forward` = Right arrow
- `color: ... ? Colors.white : Colors.grey` = Icon color
  - White if enabled, gray if disabled
- `Text` = "Continue" label below button
- `color: ... ? Color(0xFF4C40F7) : Colors.grey.shade400` = Text color

**Visual Result (No Photo):**
```
         ⭕  (gray circle with gray arrow)
        Continue  (gray text)
```

**Visual Result (Photo Taken):**
```
         ⭕  (blue circle with white arrow)
        Continue  (blue text)
```

---

### **Section 14: dispose() - Cleanup**

```dart
@override
void dispose() {
  super.dispose();
}
```

**Explanation:**
- Runs when user leaves the page
- Cleans up resources (if any were allocated)
- Prevents memory leaks

---

## **Key Concepts Summary**

| Concept | Meaning |
|---------|---------|
| **StatefulWidget** | Page that can change |
| **State** | The logic/data of a page |
| **setState()** | Tell Flutter data changed, rebuild UI |
| **async/await** | Handle slow tasks (camera) |
| **Future** | Task that takes time to complete |
| **Uint8List** | List of bytes (0-255 each) |
| **?** | Optional (can be null) |
| **!** | Force unwrap (definitely not null) |
| **GestureDetector** | Make widget tappable |
| **Navigator.push()** | Go to next page |
| **Navigator.pop()** | Go to previous page |

---

## **Notes for Future Development**

1. **Keep `Uint8List` Storage:** Never switch to `File` class for web compatibility
2. **Mobile Detection:** Always check `_isMobile` before opening camera
3. **Fallback Behavior:** Desktop/web should always fallback to file picker
4. **Platform-Specific UI:** Consider showing different instructions for mobile vs desktop
5. **Image Compression:** Add image compression if file size becomes issue
6. **Gallery Option:** Can add gallery option on mobile (reuse same bytes logic)
7. **Camera Permissions:** Always request permissions before opening camera
8. **Error Handling:** Show friendly error messages to users

---

## **Testing Checklist**

- [ ] Mobile: Camera works for Front ID
- [ ] Mobile: Camera works for Back ID
- [ ] Mobile: Camera works for Selfie (front camera)
- [ ] Desktop: File picker works for Front ID
- [ ] Desktop: File picker works for Back ID
- [ ] Desktop: File picker works for Selfie
- [ ] Web: File picker works (all three pages)
- [ ] Continue button disabled until photo taken
- [ ] Continue button enabled after photo taken
- [ ] Retake button clears photo and shows placeholder
- [ ] Navigation works Front → Back → Selfie → Step 2
- [ ] Error messages show when camera/picker fails
- [ ] No memory leaks on page leave

Good luck! 🚀
