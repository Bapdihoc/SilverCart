import 'package:dio/dio.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle different types of errors
    String errorMessage = 'Đã xảy ra lỗi không xác định';

    if (err.response != null) {
      // Server responded with error status code
      final statusCode = err.response!.statusCode;
      final responseData = err.response!.data;

      // Try to extract error message from response
      if (responseData is Map<String, dynamic>) {
        // Check for common error message fields
        String? message = responseData['message'] ?? 
                         responseData['error'] ?? 
                         responseData['errorMessage'] ?? 
                         responseData['msg'];

        if (message != null && message.isNotEmpty) {
          errorMessage = message;
        } else {
          // Fallback to status code based messages
          errorMessage = _getDefaultErrorMessage(statusCode);
        }
      } else if (responseData is String) {
        // Response is a string (error message)
        errorMessage = responseData.isNotEmpty ? responseData : _getDefaultErrorMessage(statusCode);
      } else {
        // No readable response data, use status code based message
        errorMessage = _getDefaultErrorMessage(statusCode);
      }
    } else if (err.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Kết nối tới máy chủ bị timeout';
    } else if (err.type == DioExceptionType.sendTimeout) {
      errorMessage = 'Gửi yêu cầu bị timeout';
    } else if (err.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Nhận phản hồi bị timeout';
    } else if (err.type == DioExceptionType.badResponse) {
      errorMessage = 'Phản hồi không hợp lệ từ máy chủ';
    } else if (err.type == DioExceptionType.cancel) {
      errorMessage = 'Yêu cầu đã bị hủy';
    } else if (err.type == DioExceptionType.connectionError) {
      errorMessage = 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra kết nối internet';
    } else if (err.type == DioExceptionType.unknown) {
      errorMessage = 'Lỗi không xác định. Vui lòng thử lại sau';
    } else if (err.type == DioExceptionType.badCertificate) {
      errorMessage = 'Chứng chỉ SSL không hợp lệ';
    }

    // Create a new error with the Vietnamese message
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: errorMessage,
      message: errorMessage,
    );

    handler.next(newError);
  }

  String _getDefaultErrorMessage(int? statusCode) {
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
