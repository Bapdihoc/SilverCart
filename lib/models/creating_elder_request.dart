// To parse this JSON data, do
//
//     final creatingElderRequest = creatingElderRequestFromJson(jsonString);

import 'dart:convert';

CreatingElderRequest creatingElderRequestFromJson(String str) => CreatingElderRequest.fromJson(json.decode(str));

String creatingElderRequestToJson(CreatingElderRequest data) => json.encode(data.toJson());

class CreatingElderRequest {
    List<DependentUser> dependentUsers;

    CreatingElderRequest({
        required this.dependentUsers,
    });

    factory CreatingElderRequest.fromJson(Map<String, dynamic> json) => CreatingElderRequest(
        dependentUsers: List<DependentUser>.from(json["dependentUsers"].map((x) => DependentUser.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "dependentUsers": List<dynamic>.from(dependentUsers.map((x) => x.toJson())),
    };
}

class DependentUser {
    String phone;
    String fullName;
    String gender;
    AddressData address;

    DependentUser({
        required this.phone,
        required this.fullName,
        required this.gender,
        required this.address,
    });

    factory DependentUser.fromJson(Map<String, dynamic> json) => DependentUser(
        phone: json["phone"],
        fullName: json["fullName"],
        gender: json["gender"],
        address: AddressData.fromJson(json["address"]),
    );

    Map<String, dynamic> toJson() => {
        "phone": phone,
        "fullName": fullName,
        "gender": gender,
        "address": address.toJson(),
    };
}

class AddressData {
    String streetAddress;
    String wardCode;
    int districtId;
    String toDistrictName;
    String toProvinceName;

    AddressData({
        required this.streetAddress,
        required this.wardCode,
        required this.districtId,
        required this.toDistrictName,
        required this.toProvinceName,
    });

    factory AddressData.fromJson(Map<String, dynamic> json) => AddressData(
        streetAddress: json["streetAddress"],
        wardCode: json["wardCode"],
        districtId: json["districtId"],
        toDistrictName: json["toDistrictName"],
        toProvinceName: json["toProvinceName"],
    );

    Map<String, dynamic> toJson() => {
        "streetAddress": streetAddress,
        "wardCode": wardCode,
        "districtId": districtId,
        "toDistrictName": toDistrictName,
        "toProvinceName": toProvinceName,
    };
}
