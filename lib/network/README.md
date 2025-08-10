# Network Error Handling System

## Overview

This system provides comprehensive error handling for API requests with Vietnamese error messages. It consists of two main components:

1. **ErrorInterceptor** - Automatically intercepts all HTTP errors and converts them to Vietnamese messages
2. **ApiResponseHandler** - Utility class for handling API responses and errors consistently

## Components

### 1. ErrorInterceptor (`lib/network/data/error_interceptor.dart`)

Automatically intercepts all HTTP errors and provides Vietnamese error messages. It handles:

- **Server errors** (4xx, 5xx status codes)
- **Network errors** (timeout, connection issues)
- **SSL certificate errors**
- **Unknown errors**

#### Features:
- Extracts error messages from common response fields: `message`, `error`, `errorMessage`, `msg`, `Message`, `Error`
- Provides fallback Vietnamese messages for different HTTP status codes
- Handles different DioException types with appropriate Vietnamese messages

### 2. ApiResponseHandler (`lib/network/data/api_response_handler.dart`)

Utility class for consistent error handling across repositories.

#### Methods:
- `handleResponse<T>()` - Converts API responses to BaseResponse
- `handleError<T>()` - Converts DioException to BaseResponse with Vietnamese messages
- `_extractErrorMessage()` - Extracts error messages from response data
- `getDefaultErrorMessage()` - Returns Vietnamese messages for HTTP status codes

## Usage Examples

### In Repository Classes

```dart
@override
Future<BaseResponse<LoginResponse>> signIn(String email, String password) async {
  try {
    final response = await _api.signIn({'email': email, 'password': password});
    return BaseResponse.success(data: response);
  } catch (e) {
    if (e is DioException) {
      return ApiResponseHandler.handleError<LoginResponse>(e);
    }
    return BaseResponse.error(message: e.toString());
  }
}
```

### Error Messages

The system provides Vietnamese error messages for common scenarios:

#### HTTP Status Codes:
- **400**: "Yêu cầu không hợp lệ"
- **401**: "Không có quyền truy cập. Vui lòng đăng nhập lại"
- **403**: "Truy cập bị từ chối"
- **404**: "Không tìm thấy tài nguyên yêu cầu"
- **422**: "Dữ liệu không hợp lệ"
- **429**: "Quá nhiều yêu cầu. Vui lòng thử lại sau"
- **500**: "Lỗi máy chủ nội bộ"

#### Network Errors:
- **Connection Timeout**: "Kết nối tới máy chủ bị timeout"
- **Connection Error**: "Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối internet"
- **SSL Certificate**: "Chứng chỉ SSL không hợp lệ"

## Configuration

The ErrorInterceptor is automatically added to all Dio instances in `lib/network/data/dio_module.dart`:

```dart
// Add error interceptor first (to handle errors before logging)
dio.interceptors.add(ErrorInterceptor());
```

## Response Format

The system expects API responses to have error messages in one of these fields:
- `message`
- `error`
- `errorMessage`
- `msg`
- `Message`
- `Error`

If no error message is found in the response, it falls back to status code-based Vietnamese messages.

## Benefits

1. **Consistent Error Handling**: All API errors are handled uniformly
2. **Vietnamese Messages**: User-friendly error messages in Vietnamese
3. **Automatic Interception**: No need to handle errors manually in each repository
4. **Fallback Support**: Provides meaningful messages even when server doesn't return error details
5. **Type Safety**: Uses BaseResponse<T> for type-safe error handling
