// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDetailResponse _$UserDetailResponseFromJson(Map<String, dynamic> json) =>
    UserDetailResponse(
      message: json['message'] as String,
      data: UserDetailData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserDetailResponseToJson(UserDetailResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'data': instance.data,
    };

UserDetailData _$UserDetailDataFromJson(Map<String, dynamic> json) =>
    UserDetailData(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String?,
      avatar: json['avatar'] as String?,
      gender: (json['gender'] as num).toInt(),
      phoneNumber: json['phoneNumber'] as String?,
      birthDate: DateTime.parse(json['birthDate'] as String),
      age: (json['age'] as num).toInt(),
      rewardPoint: (json['rewardPoint'] as num).toInt(),
      description: json['description'] as String,
      relationShip: json['relationShip'] as String,
      guardianId: json['guardianId'] as String,
      roleId: json['roleId'] as String,
      roleName: json['roleName'] as String,
      addresses: (json['addresses'] as List<dynamic>)
          .map((e) => UserDetailAddress.fromJson(e as Map<String, dynamic>))
          .toList(),
      categoryValues: (json['categoryValues'] as List<dynamic>)
          .map((e) => UserCategoryValue.fromJson(e as Map<String, dynamic>))
          .toList(),
      emergencyPhoneNumber: json['emergencyPhoneNumber'] as String?,
    );

Map<String, dynamic> _$UserDetailDataToJson(UserDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullName': instance.fullName,
      'userName': instance.userName,
      'email': instance.email,
      'avatar': instance.avatar,
      'gender': instance.gender,
      'phoneNumber': instance.phoneNumber,
      'birthDate': instance.birthDate.toIso8601String(),
      'age': instance.age,
      'rewardPoint': instance.rewardPoint,
      'description': instance.description,
      'relationShip': instance.relationShip,
      'guardianId': instance.guardianId,
      'roleId': instance.roleId,
      'roleName': instance.roleName,
      'addresses': instance.addresses,
      'categoryValues': instance.categoryValues,
      'emergencyPhoneNumber': instance.emergencyPhoneNumber,
    };

UserDetailAddress _$UserDetailAddressFromJson(Map<String, dynamic> json) =>
    UserDetailAddress(
      id: json['id'] as String,
      streetAddress: json['streetAddress'] as String,
      wardCode: json['wardCode'] as String,
      wardName: json['wardName'] as String,
      districtID: (json['districtID'] as num).toInt(),
      districtName: json['districtName'] as String,
      provinceID: (json['provinceID'] as num).toInt(),
      provinceName: json['provinceName'] as String,
      phoneNumber: json['phoneNumber'] as String,
    );

Map<String, dynamic> _$UserDetailAddressToJson(UserDetailAddress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'streetAddress': instance.streetAddress,
      'wardCode': instance.wardCode,
      'wardName': instance.wardName,
      'districtID': instance.districtID,
      'districtName': instance.districtName,
      'provinceID': instance.provinceID,
      'provinceName': instance.provinceName,
      'phoneNumber': instance.phoneNumber,
    };

UserCategoryValue _$UserCategoryValueFromJson(Map<String, dynamic> json) =>
    UserCategoryValue(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      label: json['label'] as String,
      type: (json['type'] as num).toInt(),
      childrenId: json['childrenId'] as String?,
      childrentLabel: json['childrentLabel'] as String?,
    );

Map<String, dynamic> _$UserCategoryValueToJson(UserCategoryValue instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'label': instance.label,
      'type': instance.type,
      'childrenId': instance.childrenId,
      'childrentLabel': instance.childrentLabel,
    };
