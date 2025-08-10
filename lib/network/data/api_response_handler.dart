import 'package:dio/dio.dart';
import 'package:silvercart/core/models/base_response.dart';

class ApiResponseHandler {
  /// Handle API response and convert to BaseResponse
  static BaseResponse<T> handleResponse<T>(Response response, T Function(dynamic data) fromJson) {
    try {
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        // Success response
        final data = fromJson(response.data);
        return BaseResponse.success(data: data);
      } else {
        // Error response
        final errorMessage = _extractErrorMessage(response.data);
        return BaseResponse.error(message: errorMessage);
      }
    } catch (e) {
      return BaseResponse.error(message: 'Lỗi xử lý dữ liệu: ${e.toString()}');
    }
  }

  /// Handle DioException and convert to BaseResponse
  static BaseResponse<T> handleError<T>(DioException error) {
    String errorMessage = 'Đã xảy ra lỗi không xác định';

    if (error.response != null) {
      // Server responded with error status code
      errorMessage = _extractErrorMessage(error.response!.data);
    } else {
      // Network or other errors
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          errorMessage = 'Kết nối tới máy chủ bị timeout';
          break;
        case DioExceptionType.sendTimeout:
          errorMessage = 'Gửi yêu cầu bị timeout';
          break;
        case DioExceptionType.receiveTimeout:
          errorMessage = 'Nhận phản hồi bị timeout';
          break;
        case DioExceptionType.badResponse:
          errorMessage = 'Phản hồi không hợp lệ từ máy chủ';
          break;
        case DioExceptionType.cancel:
          errorMessage = 'Yêu cầu đã bị hủy';
          break;
        case DioExceptionType.connectionError:
          errorMessage = 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối internet';
          break;
        case DioExceptionType.unknown:
          errorMessage = 'Lỗi không xác định. Vui lòng thử lại sau';
          break;
        case DioExceptionType.badCertificate:
          errorMessage = 'Chứng chỉ SSL không hợp lệ';
          break;
      }
    }

    return BaseResponse.error(message: errorMessage);
  }

  /// Extract error message from response data
  static String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Check for common error message fields
      String? message = responseData['message'] ?? 
                       responseData['error'] ?? 
                       responseData['errorMessage'] ?? 
                       responseData['msg'] ??
                       responseData['Message'] ??
                       responseData['Error'];

      if (message != null && message.isNotEmpty) {
        return message;
      }
    } else if (responseData is String) {
      // Response is a string (error message)
      if (responseData.isNotEmpty) {
        return responseData;
      }
    }

    // Fallback to default error message
    return 'Đã xảy ra lỗi không xác định';
  }

  /// Check if response is successful
  static bool isSuccess(Response response) {
    return response.statusCode! >= 200 && response.statusCode! < 300;
  }

  /// Get default error message for status code
  static String getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Yêu cầu không hợp lệ';
      case 401:
        return 'Không có quyền truy cập. Vui lòng đăng nhập lại';
      case 403:
        return 'Truy cập bị từ chối';
      case 404:
        return 'Không tìm thấy tài nguyên yêu cầu';
      case 405:
        return 'Phương thức không được hỗ trợ';
      case 409:
        return 'Xung đột dữ liệu';
      case 422:
        return 'Dữ liệu không hợp lệ';
      case 429:
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 500:
        return 'Lỗi máy chủ nội bộ';
      case 502:
        return 'Lỗi cổng kết nối';
      case 503:
        return 'Dịch vụ không khả dụng';
      case 504:
        return 'Gateway timeout';
      default:
        return 'Đã xảy ra lỗi (Mã: $statusCode)';
    }
  }
}
