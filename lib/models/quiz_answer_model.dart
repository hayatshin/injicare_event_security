class QuizAnswerModel {
  final String? answerId;
  final String userId;
  final String eventId;
  final String? quizEventId;
  final int answer;
  final int createdAt;
  final String? userName;

  QuizAnswerModel({
    this.answerId,
    required this.userId,
    required this.eventId,
    required this.quizEventId,
    required this.answer,
    required this.createdAt,
    this.userName,
  });

  QuizAnswerModel.fromJson(Map<String, dynamic> json)
      : answerId = json["answerId"],
        userId = json["userId"],
        eventId = json["eventId"],
        quizEventId = json["quizEventId"],
        answer = json["answer"],
        createdAt = json["createdAt"],
        userName = json["users"]["name"];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "eventId": eventId,
      "quizEventId": quizEventId,
      "answer": answer,
      "createdAt": createdAt,
    };
  }
}
