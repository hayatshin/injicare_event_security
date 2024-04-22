import 'package:injicare_event/utils.dart';

class UserProfile {
  final String userId;
  final String loginType;
  final String avatar;
  final String name;
  final String gender;
  final String birthYear;
  final String birthDay;
  final String phone;
  final int createdAt;
  final int? lastVisit;
  final String? fcmToken;
  final int? partnerDates;
  final String? subdistrictId;
  final String? subdistrictName;
  final String? contractCommunityId;
  final String? contractCommunityName;
  final String? userAge;

  UserProfile({
    required this.userId,
    required this.loginType,
    required this.avatar,
    required this.name,
    required this.gender,
    required this.birthYear,
    required this.birthDay,
    required this.phone,
    required this.createdAt,
    this.lastVisit,
    this.fcmToken,
    this.partnerDates,
    this.subdistrictId,
    this.subdistrictName,
    this.contractCommunityId,
    this.contractCommunityName,
    this.userAge,
  });

  UserProfile.fromJson(Map<String, dynamic> json)
      : userId = json.containsKey("userId") && json["userId"] != null
            ? json['userId']
            : "",
        loginType = json.containsKey("loginType") && json["loginType"] != null
            ? json['loginType']
            : checkLoginType(json["userId"]),
        avatar = json.containsKey("avatar") && json["avatar"] != null
            ? json['avatar']
            : "",
        name = json.containsKey("name") && json["name"] != null
            ? json['name']
            : "-",
        gender = json.containsKey("gender") && json["gender"] != null
            ? json['gender']
            : "여성",
        birthYear = json.containsKey("birthYear") && json["birthYear"] != null
            ? json['birthYear']
            : "1960",
        birthDay = json.containsKey("birthDay") && json["birthDay"] != null
            ? json['birthDay']
            : "0101",
        phone = json.containsKey("phone") && json["phone"] != null
            ? json['phone']
            : "010-0000-0000",
        createdAt = json.containsKey("createdAt") && json["createdAt"] != null
            ? (json['createdAt'])
            : getCurrentSeconds(),
        lastVisit = json.containsKey("lastVisit") && json["lastVisit"] != null
            ? (json['lastVisit'])
            : 0,
        fcmToken = json.containsKey("fcmToken") && json["fcmToken"] != null
            ? json['fcmToken']
            : "",
        partnerDates =
            json.containsKey("partnerDates") && json["partnerDates"] != null
                ? json["partnerDates"]
                : 0,
        subdistrictId =
            json.containsKey("subdistrictId") && json["subdistrictId"] != null
                ? json['subdistrictId']
                : "",
        subdistrictName =
            json.containsKey("subdistricts") && json["subdistricts"] != null
                ? json["subdistricts"]["subdistrict"]
                : "",
        contractCommunityId = json.containsKey("contractCommunityId") &&
                json["contractCommunityId"] != null
            ? json["contractCommunityId"]
            : null,
        contractCommunityName = json.containsKey("contract_communities") &&
                json["contract_communities"] != null
            ? json["contract_communities"]["name"]
            : "",
        userAge = userAgeCalculation(json['birthYear'], json['birthDay']);

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "loginType": loginType,
      "avatar": avatar,
      "name": name,
      "gender": gender,
      "birthYear": birthYear,
      "birthDay": birthDay,
      "phone": phone,
      "createdAt": createdAt,
      "subdistrictId": subdistrictId,
      "contractCommunityId":
          contractCommunityId == "" ? null : contractCommunityId,
      "partnerDates": partnerDates,
    };
  }

  UserProfile.empty()
      : userId = "",
        loginType = "",
        avatar = "",
        name = "",
        gender = "",
        birthYear = "",
        birthDay = "",
        phone = "",
        createdAt = getCurrentSeconds(),
        lastVisit = 0,
        fcmToken = "",
        partnerDates = 0,
        subdistrictId = "",
        subdistrictName = "",
        contractCommunityId = "",
        contractCommunityName = "",
        userAge = "";

  UserProfile copyWith({
    String? userId,
    String? loginType,
    String? avatar,
    String? name,
    String? gender,
    String? birthYear,
    String? birthDay,
    String? phone,
    int? createdAt,
    int? partnerDates,
    String? subdistrictId,
    String? subdistrictName,
    String? contractCommunityId,
    String? contractCommunityName,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      loginType: loginType ?? this.loginType,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      birthDay: birthDay ?? this.birthDay,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      fcmToken: fcmToken,
      partnerDates: partnerDates ?? this.partnerDates,
      subdistrictId: subdistrictId ?? this.subdistrictId,
      subdistrictName: subdistrictName ?? this.subdistrictName,
      contractCommunityId: contractCommunityId ?? this.contractCommunityId,
      contractCommunityName:
          contractCommunityName ?? this.contractCommunityName,
      userAge: userAge ?? userAge,
    );
  }
}

String checkLoginType(String? userId) {
  if (userId != null && userId.startsWith("kakao:")) {
    return "카카오";
  } else {
    return "일반";
  }
}
