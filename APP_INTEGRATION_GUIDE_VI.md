# Hướng Dẫn Tích Hợp App (Mobile/Web) - Credit Scoring

## 1) Mục tiêu
Tài liệu này hướng dẫn team app tích hợp API production theo chuẩn ổn định:
- URL production và fallback
- Luồng API 2 bước
- Xử lý auth/token
- Retry/timeout/error handling
- Checklist trước khi release

## 2) Endpoint production
- Base URL chính: https://swincredit.duckdns.org
- Health check: https://swincredit.duckdns.org/api/health

Khuyến nghị:
- App client luôn gọi qua domain ở trên (không hardcode Cloud Run URL nội bộ).
- Nếu triển khai fallback, chỉ dùng để giám sát nội bộ, không expose cho người dùng cuối.

Biến môi trường khuyến nghị:
- `API_BASE_URL=https://swincredit.duckdns.org/api`
- `API_KEY=` nếu backend bật `X-API-Key`

## 3) Cơ chế xác thực
Hiện có 2 lớp phổ biến trong backend:
1. Firebase ID Token (Authorization Bearer)
2. API Key (X-API-Key) cho các endpoint yêu cầu key

Header mẫu:
```http
Authorization: Bearer <firebase_id_token>
X-API-Key: <api_key>
Content-Type: application/json
```

Quy tắc phía app:
- Token Firebase lấy từ phiên đăng nhập hiện tại.
- Không hardcode API key trong source public.
- API key lưu trong secure storage (hoặc cấp từ backend gateway nội bộ nếu có).

## 4) Luồng nghiệp vụ khuyến nghị (2 bước)

### Bước 1: Tính hạn mức và điểm tín dụng
- Endpoint: POST /api/calculate-limit
- Mục tiêu: lấy credit_score + loan_limit_vnd + risk_level + approved

Payload tối thiểu (ví dụ):
```json
{
  "full_name": "Nguyen Van A",
  "age": 30,
  "monthly_income": 20000000,
  "employment_status": "EMPLOYED",
  "years_employed": 5,
  "home_ownership": "MORTGAGE",
  "years_credit_history": 3,
  "has_previous_defaults": false,
  "currently_defaulting": false
}
```

### Bước 2: Tính điều khoản khoản vay
- Endpoint: POST /api/calculate-terms
- Input cần dùng credit_score từ bước 1

Payload ví dụ:
```json
{
  "loan_amount": 300000000,
  "loan_purpose": "CAR",
  "credit_score": 750
}
```

## 5) Timeout, retry, circuit breaker
Thiết lập khuyến nghị phía app:
- Connect timeout: 5s
- Read timeout: 20s
- Retry: tối đa 2 lần cho lỗi mạng (không retry vô hạn)
- Backoff: exponential (300ms -> 900ms)

Chỉ retry với lỗi tạm thời:
- Network timeout
- HTTP 429
- HTTP 502/503/504

Không retry tự động với:
- HTTP 400/401/403/422

## 6) Mapping lỗi cho UX
- 400/422: dữ liệu đầu vào sai -> hiển thị lỗi form cụ thể
- 401: token hết hạn/thiếu -> refresh token hoặc login lại
- 403: không đủ quyền/API key sai -> hiển thị lỗi truy cập
- 429: quá hạn mức -> báo người dùng thử lại sau
- 5xx: lỗi hệ thống -> hiển thị fallback message và cho phép retry

Message UX nên ngắn, rõ:
- "Kết nối tạm thời gián đoạn. Vui lòng thử lại."
- "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại."

## 7) Logging phía app (không lộ dữ liệu nhạy cảm)
Bắt buộc log:
- request_id (nếu có)
- endpoint
- status code
- latency
- retry count

Không log:
- API key
- Firebase token
- thông tin PII đầy đủ (CMND/CCCD, email đầy đủ, số điện thoại đầy đủ)

## 8) Kiểm tra health trước khi mở app flow
Trước khi vào luồng apply/recalculate:
1. Gọi GET /api/health
2. Nếu không 200 -> bật maintenance banner nhẹ
3. Cho phép user retry thủ công

Gợi ý triển khai phía app:
- Kiểm tra health ngay lúc splash/init app.
- Nếu API down, vẫn cho app vào chế độ xem thông tin nhưng chặn các hành động submit mới.

## 9) Checklist QA trước release app
1. /api/health trả 200 từ app thật
2. calculate-limit trả dữ liệu đúng schema
3. calculate-terms dùng credit_score từ bước 1 chạy ổn
4. Token hết hạn được xử lý đúng (401 flow)
5. 429/5xx có thông báo UX và retry hợp lý
6. Không lộ secrets trong log
7. Test trên mạng yếu (3G/4G chập chờn)

## 10) Mẫu pseudo-code client
```text
onSubmitLimitForm():
  validateLocalInput()
  token = getFirebaseToken()
  apiKey = getApiKeyFromSecureStore()
  resp = call POST /api/calculate-limit
  if success -> save credit_score, loan_limit
  else -> mapErrorToUserMessage()

onSubmitTermsForm():
  require credit_score from step1
  resp = call POST /api/calculate-terms
  if success -> render loan terms
  else -> mapErrorToUserMessage()
```

## 11) Runbook mini cho team app khi có incident
Nếu app báo lỗi hàng loạt:
1. Kiểm tra ngay /api/health
2. Kiểm tra status code phổ biến trong app logs
3. Nếu 5xx tăng mạnh -> thông báo backend ops + bật maintenance banner
4. Nếu 401 tăng mạnh -> kiểm tra luồng refresh token
5. Nếu 429 tăng mạnh -> kiểm tra retry logic và tần suất gọi API

## 12) Ghi chú vận hành
- Domain production hiện tại đã gắn qua LB + HTTPS + Cloud Armor.
- Alerting backend đã cấu hình cho API 5xx, exporter errors, retrain errors.
- Với release app lớn, nên test end-to-end trên production ngoài giờ cao điểm.
