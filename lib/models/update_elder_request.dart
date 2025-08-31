import 'package:json_annotation/json_annotation.dart';

part 'update_elder_request.g.dart';

@JsonSerializable()
class UpdateElderRequest {
  final String id;
  final String fullName;
  final String userName;
  final String description;
  final DateTime birthDate;
  final double spendlimit;
  final String? avatar;
  final String emergencyPhoneNumber;
  final String relationShip;
  final int gender;

  UpdateElderRequest({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.description,
    required this.birthDate,
    required this.spendlimit,
    this.avatar,
    required this.emergencyPhoneNumber,
    required this.relationShip,
    required this.gender,
  });

  factory UpdateElderRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateElderRequestFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateElderRequestToJson(this);
}
