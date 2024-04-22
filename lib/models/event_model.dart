import 'package:injicare_event/utils.dart';

class EventModel {
  final bool allUsers;
  final String? contractRegionId;
  final String? contractCommunityId;
  final String eventImage;
  final String startDate;
  final String endDate;
  final String? state;
  final String title;
  final String description;
  final String eventId;
  final int targetScore;
  final int achieversNumber;
  final int createdAt;
  final int stepPoint;
  final int diaryPoint;
  final int commentPoint;
  final int likePoint;
  final int invitationPoint;
  final int quizPoint;
  final bool adminSecret;

  final String bannerImage;
  final String eventType;
  final int diaryCount;
  final int commentCount;
  final int likeCount;
  final int invitationCount;
  final int quizCount;

  // user-point-count
  final int? userStepPoint;
  final int? userDiaryPoint;
  final int? userCommentPoint;
  final int? userLikePoint;
  final int? userInvitationPoint;
  final int? userQuizPoint;
  final int? userTotalPoint;
  final int? userDiaryCount;
  final int? userCommentCount;
  final int? userLikeCount;
  final int? userInvitationCount;
  final int? userQuizCount;
  final bool? userAchieveOrNot;

  final int? leftDays;
  final int? participantsNumber;
  final int? ageLimit;

  final int? maxStepCount;
  final int? maxCommentCount;
  final int? maxLikeCount;
  final int? maxInvitationCount;

  EventModel({
    required this.allUsers,
    this.contractRegionId,
    this.contractCommunityId,
    required this.eventImage,
    required this.startDate,
    required this.endDate,
    this.state,
    required this.title,
    required this.description,
    required this.eventId,
    required this.targetScore,
    required this.achieversNumber,
    required this.createdAt,
    required this.stepPoint,
    required this.diaryPoint,
    required this.commentPoint,
    required this.likePoint,
    required this.invitationPoint,
    required this.quizPoint,
    required this.adminSecret,
    required this.bannerImage,
    required this.eventType,
    required this.diaryCount,
    required this.commentCount,
    required this.likeCount,
    required this.invitationCount,
    required this.quizCount,
    this.userStepPoint,
    this.userDiaryPoint,
    this.userCommentPoint,
    this.userLikePoint,
    this.userInvitationPoint,
    this.userQuizPoint,
    this.userTotalPoint,
    this.userDiaryCount,
    this.userCommentCount,
    this.userLikeCount,
    this.userInvitationCount,
    this.userQuizCount,
    this.userAchieveOrNot,
    this.leftDays,
    this.participantsNumber,
    this.ageLimit,
    this.maxStepCount,
    this.maxCommentCount,
    this.maxLikeCount,
    this.maxInvitationCount,
  });

  EventModel.fromJson(Map<String, dynamic> json)
      : allUsers = json["allUsers"],
        contractRegionId = json.containsKey("contractRegionId") &&
                json["contractRegionId"] != null
            ? json["contractRegionId"]
            : "",
        contractCommunityId = json.containsKey("contractCommunityId") &&
                json["contractCommunityId"] != null
            ? json["contractCommunityId"]
            : "",
        eventImage = json["eventImage"],
        startDate = json["startDate"],
        endDate = json["endDate"],
        state =
            convertEndDateStringToSeconds(json["endDate"]) > getCurrentSeconds()
                ? "진행"
                : "종료",
        title = json["title"],
        description = json["description"],
        eventId = json["eventId"],
        targetScore =
            json.containsKey("targetScore") && json["targetScore"] != null
                ? json["targetScore"]
                : 0,
        achieversNumber = json.containsKey("achieversNumber") &&
                json["achieversNumber"] != null
            ? json["achieversNumber"]
            : 0,
        createdAt = json["createdAt"],
        stepPoint = json["stepPoint"] ?? 0,
        diaryPoint = json["diaryPoint"] ?? 0,
        commentPoint = json["commentPoint"] ?? 0,
        likePoint = json["likePoint"] ?? 0,
        invitationPoint = json["invitationPoint"] ?? 0,
        quizPoint = json["quizPoint"] ?? 0,
        adminSecret = json["adminSecret"] ?? true,
        bannerImage = json["bannerImage"] ?? "",
        eventType = json["eventType"],
        diaryCount = json["diaryCount"] ?? 0,
        commentCount = json["commentCount"] ?? 0,
        likeCount = json["likeCount"] ?? 0,
        invitationCount = json["invitationCount"] ?? 0,
        quizCount = json["quizCount"] ?? 0,
        userStepPoint = 0,
        userDiaryPoint = 0,
        userCommentPoint = 0,
        userLikePoint = 0,
        userInvitationPoint = 0,
        userQuizPoint = 0,
        userTotalPoint = 0,
        userDiaryCount = 0,
        userCommentCount = 0,
        userLikeCount = 0,
        userInvitationCount = 0,
        userQuizCount = 0,
        userAchieveOrNot = false,
        leftDays = getEventLeftDaysFromNow(json["endDate"]),
        participantsNumber = 0,
        ageLimit = json["ageLimit"] ?? 0,
        maxStepCount = json["maxStepCount"] ?? 10000,
        maxCommentCount = json["maxCommentCount"] ?? 0,
        maxLikeCount = json["maxLikeCount"] ?? 0,
        maxInvitationCount = json["maxInvitationCount"] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      "allUsers": allUsers,
      "contractRegionId": contractRegionId,
      "contractCommunityId": contractCommunityId,
      "eventImage": eventImage,
      "startDate": startDate,
      "endDate": endDate,
      "title": title,
      "description": description,
      "eventId": eventId,
      "targetScore": targetScore,
      "achieversNumber": achieversNumber,
      "createdAt": createdAt,
      "stepPoint": stepPoint,
      "diaryPoint": diaryPoint,
      "commentPoint": commentPoint,
      "likePoint": likePoint,
      "invitationPoint": invitationPoint,
      "quizPoint": quizPoint,
      "adminSecret": adminSecret,
      "bannerImage": bannerImage,
      "eventType": eventType,
      "diaryCount": diaryCount,
      "commentCount": commentCount,
      "likeCount": likeCount,
      "invitationCount": invitationCount,
      "quizCount": quizCount,
      "ageLimit": ageLimit,
      "maxStepCount": maxStepCount,
      "maxCommentCount": maxCommentCount,
      "maxLikeCount": maxLikeCount,
      "maxInvitationCount": maxInvitationCount,
    };
  }

  EventModel copyWith({
    bool? allUsers,
    String? contractRegionId,
    String? contractCommunityId,
    String? eventImage,
    String? startDate,
    String? endDate,
    String? state,
    String? title,
    String? description,
    String? eventId,
    int? targetScore,
    int? achieversNumber,
    int? stepPoint,
    int? diaryPoint,
    int? commentPoint,
    int? likePoint,
    int? invitationPoint,
    int? quizPoint,
    bool? adminSecret,
    String? bannerImage,
    String? eventType,
    int? diaryCount,
    int? commentCount,
    int? likeCount,
    int? invitationCount,
    int? quizCount,
    int? userStepPoint,
    int? userDiaryPoint,
    int? userCommentPoint,
    int? userLikePoint,
    int? userInvitationPoint,
    int? userQuizPoint,
    int? userTotalPoint,
    int? userDiaryCount,
    int? userCommentCount,
    int? userLikeCount,
    int? userInvitationCount,
    int? userQuizCount,
    bool? userAchieveOrNot,
    int? leftDays,
    int? participantsNumber,
    int? ageLimit,
    int? maxStepCount,
    int? maxCommentCount,
    int? maxLikeCount,
    int? maxInvitationCount,
  }) {
    return EventModel(
      allUsers: allUsers ?? this.allUsers,
      contractRegionId: contractRegionId ?? this.contractRegionId,
      contractCommunityId: contractCommunityId ?? this.contractCommunityId,
      eventImage: eventImage ?? this.eventImage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      state: state ?? this.state,
      title: title ?? this.title,
      description: description ?? this.description,
      eventId: eventId ?? this.eventId,
      targetScore: targetScore ?? this.targetScore,
      achieversNumber: achieversNumber ?? this.achieversNumber,
      createdAt: createdAt,
      stepPoint: stepPoint ?? this.stepPoint,
      diaryPoint: diaryPoint ?? this.diaryPoint,
      commentPoint: commentPoint ?? this.commentPoint,
      likePoint: likePoint ?? this.likePoint,
      invitationPoint: invitationPoint ?? this.invitationPoint,
      quizPoint: quizPoint ?? this.quizPoint,
      adminSecret: adminSecret ?? this.adminSecret,
      bannerImage: bannerImage ?? this.bannerImage,
      eventType: eventType ?? this.eventType,
      diaryCount: diaryCount ?? this.diaryCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      invitationCount: invitationCount ?? this.invitationCount,
      quizCount: quizCount ?? this.quizCount,
      userStepPoint: userStepPoint ?? this.userStepPoint,
      userDiaryPoint: userDiaryPoint ?? this.userDiaryPoint,
      userCommentPoint: userCommentPoint ?? this.userCommentPoint,
      userLikePoint: userLikePoint ?? this.userLikePoint,
      userInvitationPoint: userInvitationPoint ?? this.userInvitationPoint,
      userQuizPoint: userQuizPoint ?? userQuizPoint,
      userTotalPoint: userTotalPoint ?? this.userTotalPoint,
      userDiaryCount: userDiaryCount ?? this.userDiaryCount,
      userCommentCount: userCommentCount ?? this.userCommentCount,
      userLikeCount: userLikeCount ?? this.userLikeCount,
      userInvitationCount: userInvitationCount ?? this.userInvitationCount,
      userQuizCount: userQuizCount ?? userQuizCount,
      userAchieveOrNot: userAchieveOrNot ?? this.userAchieveOrNot,
      leftDays: leftDays ?? this.leftDays,
      participantsNumber: participantsNumber ?? this.participantsNumber,
      ageLimit: ageLimit ?? this.ageLimit,
      maxStepCount: maxStepCount ?? this.maxStepCount,
      maxCommentCount: maxCommentCount ?? this.maxCommentCount,
      maxLikeCount: maxLikeCount ?? this.maxLikeCount,
      maxInvitationCount: maxInvitationCount ?? this.maxInvitationCount,
    );
  }

  EventModel.empty()
      : allUsers = false,
        contractRegionId = "",
        contractCommunityId = "",
        eventImage = "",
        startDate = "",
        endDate = "",
        state = "진행",
        title = "",
        description = "",
        eventId = "",
        targetScore = 0,
        achieversNumber = 0,
        createdAt = 0,
        stepPoint = 0,
        diaryPoint = 0,
        commentPoint = 0,
        likePoint = 0,
        invitationPoint = 0,
        quizPoint = 0,
        adminSecret = true,
        bannerImage = "",
        eventType = "",
        diaryCount = 0,
        commentCount = 0,
        likeCount = 0,
        invitationCount = 0,
        quizCount = 0,
        userStepPoint = 0,
        userDiaryPoint = 0,
        userCommentPoint = 0,
        userLikePoint = 0,
        userInvitationPoint = 0,
        userQuizPoint = 0,
        userTotalPoint = 0,
        userDiaryCount = 0,
        userCommentCount = 0,
        userLikeCount = 0,
        userInvitationCount = 0,
        userQuizCount = 0,
        userAchieveOrNot = false,
        leftDays = 0,
        participantsNumber = 0,
        ageLimit = 0,
        maxStepCount = 10000,
        maxCommentCount = 0,
        maxLikeCount = 0,
        maxInvitationCount = 0;
}
