// To parse this JSON data, do
//
//     final orderResponse = orderResponseFromJson(jsonString);

import 'dart:convert';

OrderResponse orderResponseFromJson(String str) => OrderResponse.fromJson(json.decode(str));

String orderResponseToJson(OrderResponse data) => json.encode(data.toJson());

class OrderResponse {
    int pageNumber;
    int pageSize;
    int totalNumberOfPages;
    int totalNumberOfRecords;
    List<Order> results;

    OrderResponse({
        required this.pageNumber,
        required this.pageSize,
        required this.totalNumberOfPages,
        required this.totalNumberOfRecords,
        required this.results,
    });

    factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
        pageNumber: json["pageNumber"],
        pageSize: json["pageSize"],
        totalNumberOfPages: json["totalNumberOfPages"],
        totalNumberOfRecords: json["totalNumberOfRecords"],
        results: List<Order>.from(json["results"].map((x) => Order.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "pageSize": pageSize,
        "totalNumberOfPages": totalNumberOfPages,
        "totalNumberOfRecords": totalNumberOfRecords,
        "results": List<dynamic>.from(results.map((x) => x.toJson())),
    };
}

class Order {
    String id;
    double totalPrice;
    dynamic creationDate;
    OrderStatus orderStatus;
    String address;
    List<dynamic> orderDetails;

    Order({
        required this.id,
        required this.totalPrice,
        required this.creationDate,
        required this.orderStatus,
        required this.address,
        required this.orderDetails,
    });

    factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json["id"],
        totalPrice: json["totalPrice"]?.toDouble(),
        creationDate: json["creationDate"],
        orderStatus: orderStatusValues.map[json["orderStatus"]]!,
        address: json["address"],
        orderDetails: List<dynamic>.from(json["orderDetails"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "totalPrice": totalPrice,
        "creationDate": creationDate,
        "orderStatus": orderStatusValues.reverse[orderStatus],
        "address": address,
        "orderDetails": List<dynamic>.from(orderDetails.map((x) => x)),
    };
}

enum OrderStatus {
    PENDING
}

final orderStatusValues = EnumValues({
    "Pending": OrderStatus.PENDING
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
            reverseMap = map.map((k, v) => MapEntry(v, k));
            return reverseMap;
    }
}
