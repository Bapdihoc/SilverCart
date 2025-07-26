class ProductRequest {
   String? productName;
   String? productType;
   int? requestPage;
   int? requestSize;
   ProductRequest({this.productName, this.productType, this.requestPage, this.requestSize});
   ProductRequest copyWith({String? productName, String? productType, int? requestPage, int? requestSize}) {
    return ProductRequest(
      productName: productName ?? this.productName,
      productType: productType ?? this.productType,
      requestPage: requestPage ?? this.requestPage,
      requestSize: requestSize ?? this.requestSize,
    );
   }
   Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'productType': productType,
      'requestPage': requestPage,
      'requestSize': requestSize,
    }..removeWhere((key, value) => (value == null));
   }
}