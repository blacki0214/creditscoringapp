# VNPT eKYC - Hướng Dẫn Cài Đặt Credentials

## Tổng Quan

VNPT eKYC service yêu cầu các credentials sau để hoạt động:
- **Token ID**: ID định danh từ VNPT dashboard
- **Token Key**: Public key để xác thực
- **Public Key CA**: Certificate Authority public key  
- **Access Token**: Bearer token để gọi API

Vì lý do bảo mật, các credentials này **KHÔNG** được hardcode trong source code mà được load từ file `.env` hoặc Flutter Secure Storage.

## Cách Lấy Credentials từ VNPT

1. Đăng ký tài khoản tại [VNPT AI Cloud](https://ai.vnpt.vn)
2. Đăng nhập vào Dashboard
3. Vào phần **eKYC Service** → **API Credentials**
4. Copy các giá trị:
   - Token ID
   - Token Key
   - Public Key CA
5. Để lấy Access Token:
   - Sử dụng Token ID và Token Key để authenticate
   - Hoặc copy trực tiếp từ dashboard nếu có

## Setup cho Development

### Bước 1: Tạo File .env

Trong thư mục root của project, copy file `.env.example` thành `.env`:

```bash
cp .env.example .env
```

### Bước 2: Điền Credentials vào .env

Mở file `.env` và điền các giá trị thực tế:

```env
# Token ID from VNPT Dashboard
VNPT_TOKEN_ID=your_actual_token_id_here

# Token Key (Public Key)
VNPT_TOKEN_KEY=your_actual_token_key_here

# Public Key CA
VNPT_PUBLIC_KEY_CA=your_actual_public_key_ca_here

# Access Token (Bearer token)
VNPT_ACCESS_TOKEN=bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
```

**LƯU Ý**: 
- Access token phải bắt đầu bằng `bearer ` (có khoảng trắng)
- Không commit file `.env` vào Git (file này đã có trong `.gitignore`)

### Bước 3: Load .env khi App Khởi Động

Credentials sẽ tự động được load khi khởi tạo `VnptEkycService`.

## Setup cho Production

Trong môi trường production, nên sử dụng **Flutter Secure Storage** thay vì file `.env`:

### Option 1: Hardcode ban đầu rồi lưu vào Secure Storage

```dart
import 'package:creditscoringapp/services/vnpt_credentials_manager.dart';

// Lần đầu tiên, lưu credentials vào secure storage
final credentials = VnptCredentials(
  tokenId: 'your_token_id',
  tokenKey: 'your_token_key',
  publicKeyCa: 'your_public_key_ca',
  accessToken: 'bearer your_access_token',
);

await VnptCredentialsManager.saveCredentials(credentials);
```

Sau đó xóa đoạn code trên đi. Lần sau app sẽ tự load từ secure storage.

### Option 2: Có UI cho User nhập Credentials

Tạo một settings page để admin nhập credentials:

```dart
Future<void> saveCredentialsFromUI() async {
  final credentials = VnptCredentials(
    tokenId: tokenIdController.text,
    tokenKey: tokenKeyController.text,
    publicKeyCa: publicKeyCaController.text,
    accessToken: accessTokenController.text,
  );
  
  await VnptCredentialsManager.saveCredentials(credentials);
}
```

## Sử Dụng Service

### Khởi Tạo Service

```dart
import 'package:creditscoringapp/services/vnpt_ekyc_service.dart';

// Tạo service instance
final ekycService = VnptEkycService(
  onTokenExpiryWarning: (message, expiryTime) {
    // Handle warning khi token sắp hết hạn
    print('Warning: $message');
    // Hiển thị notification cho user
  },
);

// QUAN TRỌNG: Phải gọi initialize trước khi sử dụng
try {
  await ekycService.initialize();
  print('VNPT eKYC service ready!');
} catch (e) {
  print('Failed to initialize: $e');
  // Handle error - có thể credentials không đúng hoặc token đã expire
}
```

### Kiểm Tra Credentials

```dart
// Check xem có credentials chưa
final hasCredentials = await VnptCredentialsManager.hasCredentials();

if (!hasCredentials) {
  // Yêu cầu user cấu hình credentials
}
```

### Update Access Token

Khi token hết hạn, update token mới:

```dart
await VnptCredentialsManager.updateAccessToken('bearer new_token_here');

// Sau đó reinitialize service
await ekycService.initialize();
```

## Token Management

### Token Expiry Warning

Service sẽ tự động:
1. **Check token expiry** khi initialize
2. **Throw error** nếu token đã hết hạn
3. **Warning** nếu token sắp hết hạn (trong vòng 5 phút)

Xem token info:

```dart
import 'package:creditscoringapp/utils/jwt_token_helper.dart';

final token = 'bearer eyJhbGciOiJSUzI1NiI...';

// Get expiry time
final expiryTime = JwtTokenHelper.getExpiryTime(token);
print('Token expires at: $expiryTime');

// Check if expired
if (JwtTokenHelper.isExpired(token)) {
  print('Token is expired!');
}

// Get time until expiry
final timeLeft = JwtTokenHelper.getTimeUntilExpiry(token);
print('Time left: ${timeLeft?.inHours} hours');

// Get formatted info
print(JwtTokenHelper.getExpiryInfo(token));
```

### Token Hết Hạn - Cách Xử Lý

VNPT hiện tại **KHÔNG** cung cấp API refresh token tự động. Khi token hết hạn:

1. Vào VNPT Dashboard
2. Generate token mới
3. Update vào `.env` file hoặc secure storage
4. Restart app hoặc reinitialize service

## Troubleshooting

### "Service not initialized" Error

```
VnptException: Service not initialized. Call initialize() first.
```

**Giải pháp**: Gọi `await ekycService.initialize()` trước khi sử dụng API methods.

### "VNPT credentials not found" Error

```
VnptCredentialsException: VNPT credentials not found. Please configure credentials...
```

**Giải pháp**: 
1. Kiểm tra file `.env` có tồn tại không
2. Kiểm tra các biến trong `.env` đã điền đầy đủ chưa
3. Verify file `.env` nằm ở đúng root folder

### "Token đã hết hạn" Error

```
VnptException: VNPT Access Token đã hết hạn! Vui lòng cập nhật token mới...
```

**Giải pháp**: Update token mới trong `.env` và restart app.

### Credentials Load Failed

Nếu credentials không load được:

```dart
// Clear và reset credentials
await VnptCredentialsManager.clearCredentials();

// Sau đó setup lại
```

## Best Practices

### ✅ DO:
- Dùng `.env` cho development
- Dùng Flutter Secure Storage cho production
- Monitor token expiry warnings
- Update token trước khi hết hạn
- Verify credentials ngay khi app start

### ❌ DON'T:
- Hardcode credentials trong Dart files
- Commit file `.env` vào Git
- Share credentials công khai
- Ignore token expiry warnings

## Security Notes

1. **File `.env` đã được thêm vào `.gitignore`** - Không bị commit
2. **Flutter Secure Storage** encrypt data trên device
3. **Tokens are sensitive** - Không log ra console trong production
4. **Rotate tokens regularly** - Thay đổi token định kỳ để bảo mật

## Support

Nếu có vấn đề về credentials hoặc token:

1. Check logs trong console: `[VNPT]` và `[VnptCredentials]`
2. Verify token bằng [JWT.io](https://jwt.io)
3. Liên hệ VNPT support nếu cần token mới
