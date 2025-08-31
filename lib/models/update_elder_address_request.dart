import 'package:json_annotation/json_annotation.dart';

part 'update_elder_address_request.g.dart';

@JsonSerializable()
class UpdateElderAddressRequest {
  final String streetAddress;
  final String wardCode;
  final String wardName;
  final int districtID;
  final String districtName;
  final int provinceID;
  final String provinceName;
  final String phoneNumber;

  UpdateElderAddressRequest({
    required this.streetAddress,
    required this.wardCode,
    required this.wardName,
    required this.districtID,
    required this.districtName,
    required this.provinceID,
    required this.provinceName,
    required this.phoneNumber,
  });

  factory UpdateElderAddressRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateElderAddressRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateElderAddressRequestToJson(this);
}
