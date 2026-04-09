# Hướng Dẫn Tích Hợp App (Mobile/Web) - Credit Scoring

## 1) Mục tiêu
Tài liệu này là bản triển khai thực thi để team app:
- Tích hợp nhanh 2 luồng API: thường và sinh viên.
- Lấy và truyền Firebase token đúng chuẩn.
- Test end-to-end được ngay trên production.
- Có checklist pass/fail rõ ràng trước khi release.

## 2) Base URL và endpoint cần dùng

Production URL (ưu tiên):
- https://swincredit.duckdns.org

Production URL trực tiếp Cloud Run (fallback kỹ thuật):
- https://credit-scoring-api-513943636250.asia-southeast1.run.app

Health:
- GET /api/health

Luồng thường:
- POST /api/calculate-limit
- POST /api/calculate-terms

Luồng sinh viên:
- POST /api/student/credit-score
- POST /api/student/calculate-limit

## 3) Xác thực cho app

### 3.1 Header bắt buộc cho endpoint sinh viên
```http
Authorization: Bearer <firebase_id_token>
Content-Type: application/json
```

### 3.2 Header cho endpoint monitoring nội bộ
```http
X-API-Key: <api_key>
```

### 3.3 Lấy token trong Flutter
```dart
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> getFirebaseIdToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return user.getIdToken(true); // force refresh
}
```

Quy tắc app:
1. Luôn gọi `getIdToken(true)` trước request quan trọng.
2. Nếu 401, refresh token 1 lần rồi retry 1 lần.
3. Nếu vẫn 401, bắt user login lại.

## 4) Contract payload để app implement

### 4.1 Student request
```json
{
  "age": 21,
  "gpa_latest": 3.2,
  "academic_year": 3,
  "major": "technology",
  "program_level": "undergraduate",
  "living_status": "dormitory",
  "has_buffer": true,
  "support_sources": ["family", "part_time"],
  "monthly_income": 2000000,
  "monthly_expenses": 3000000
}
```

### 4.2 Student response chính
Các field cần map trong app model:
1. `credit_score`
2. `risk_level`
3. `approved`
4. `message`
5. `default_probability`
6. `approval_threshold`
7. `score_model`
8. `score_range`
9. `decision_band`
10. `manual_review`

Riêng endpoint `student/calculate-limit` có thêm:
1. `loan_limit_vnd`

## 5) Luồng UI/UX khuyến nghị cho app

### 5.1 Luồng sinh viên
1. User nhập form hồ sơ sinh viên.
2. App gọi `POST /api/student/credit-score` để hiển thị đánh giá nhanh.
3. App gọi `POST /api/student/calculate-limit` để lấy hạn mức chính thức.
4. Render theo trạng thái:
- `approved=true`: hiện hạn mức và CTA tiếp tục.
- `decision_band=manual_review`: hiện thông báo chờ thẩm định.
- `approved=false`: hiện lý do trong `message`.

### 5.2 Luồng thường (không sinh viên)
1. `POST /api/calculate-limit`
2. `POST /api/calculate-terms` dùng `credit_score` từ bước 1.

## 6) HTTP client policy (mobile/web)

Khuyến nghị:
1. Connect timeout: 5s
2. Read timeout: 20s
3. Retry tối đa 2 lần
4. Backoff: 300ms -> 900ms

Retry với:
1. Network timeout
2. 429
3. 502/503/504

Không retry tự động với:
1. 400
2. 401
3. 403
4. 422

## 7) Mapping lỗi cho app

1. 400/422: lỗi input form, highlight field cụ thể.
2. 401: refresh token 1 lần, fail thì login lại.
3. 403: không đủ quyền hoặc sai key.
4. 429: thông báo thử lại sau.
5. 5xx: thông báo lỗi tạm thời + nút retry.

Message đề xuất:
1. "Kết nối tạm thời gián đoạn. Vui lòng thử lại."
2. "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."

## 8) Test end-to-end cho team app

### 8.1 Smoke test health
```powershell
Invoke-RestMethod -Method Get -Uri "https://swincredit.duckdns.org/api/health" | ConvertTo-Json -Depth 6
```

### 8.2 Lấy token test bằng Firebase REST
Chuẩn bị:
1. Firebase Web API Key
2. User test email/password

```powershell
$apiKey = "<FIREBASE_WEB_API_KEY>"
$email = "<TEST_EMAIL>"
$password = "<TEST_PASSWORD>"

$body = @{ email = $email; password = $password; returnSecureToken = $true } | ConvertTo-Json
$authResp = Invoke-RestMethod -Method Post `
  -Uri "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey" `
  -ContentType "application/json" -Body $body

$idToken = $authResp.idToken
```

### 8.3 Test student calculate-limit với token
```powershell
$payload = @{
  age = 21
  gpa_latest = 3.2
  academic_year = 3
  major = "technology"
  program_level = "undergraduate"
  living_status = "dormitory"
  has_buffer = $true
  support_sources = @("family", "part_time")
  monthly_income = 2000000
  monthly_expenses = 3000000
} | ConvertTo-Json

Invoke-RestMethod -Method Post `
  -Uri "https://swincredit.duckdns.org/api/student/calculate-limit" `
  -Headers @{ Authorization = "Bearer $idToken" } `
  -ContentType "application/json" `
  -Body $payload | ConvertTo-Json -Depth 8
```

Pass condition:
1. HTTP 200
2. Có đủ field `decision_band`, `approved`, `credit_score`, `loan_limit_vnd`
3. App parse JSON thành model thành công

## 9) Checklist QA trước release

1. `/api/health` trả 200 từ app thật.
2. Luồng student gọi được cả 2 endpoint với Firebase token thật.
3. 401 flow (token hết hạn) được xử lý đúng.
4. 429/5xx có UX fallback và retry hợp lý.
5. Không log token, API key, PII đầy đủ.
6. Test mạng yếu (3G/4G chập chờn) không crash.
7. Mapping `decision_band` đúng với UI state.

## 10) Pseudo-code tích hợp app
```text
submitStudentApplication():
  validateLocalInput()
  token = getFirebaseIdToken(forceRefresh=true)
  scoreResp = POST /api/student/credit-score (Bearer token)
  limitResp = POST /api/student/calculate-limit (Bearer token)
  renderUI(scoreResp, limitResp)

submitRegularApplication():
  validateLocalInput()
  limitResp = POST /api/calculate-limit
  termsResp = POST /api/calculate-terms using limitResp.credit_score
  renderLoanTerms(termsResp)
```

## 11) Runbook sự cố cho team app

1. Kiểm tra `/api/health` ngay khi lỗi hàng loạt.
2. Nếu 401 tăng đột biến: kiểm tra refresh token flow.
3. Nếu 5xx tăng: bật maintenance banner tạm thời + báo backend.
4. Nếu 429 tăng: giảm tần suất gọi và xem lại retry policy.

## 12) Ghi chú triển khai production

1. Không hardcode API key trong source public.
2. Tách base URL theo môi trường (`dev/staging/prod`).
3. Với release lớn, chạy canary app và theo dõi lỗi tối thiểu 24h.
