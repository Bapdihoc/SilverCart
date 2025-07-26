
class BaseResponse <T>{
  final String? message;
  final bool isSuccess;
  final T? data;
  BaseResponse({
    required this.isSuccess,
    this.message,
    this.data,
  });
  factory BaseResponse.success({required T data}) {
    return BaseResponse(data: data, isSuccess: true);
  }

  factory BaseResponse.error({required String message}) {
    return BaseResponse(
      message: message,
      isSuccess: false,
    );
  }
}