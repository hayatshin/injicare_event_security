class PhotoImageModel {
  final String? photoImageId;
  final String eventId;
  final String userId;
  final int createdAt;
  final String photo;
  final String title;
  final String? userName;

  PhotoImageModel({
    this.photoImageId,
    required this.eventId,
    required this.userId,
    required this.createdAt,
    required this.photo,
    required this.title,
    this.userName,
  });

  PhotoImageModel.fromJson(Map<String, dynamic> json)
      : photoImageId = json["photoImageId"],
        eventId = json["eventId"],
        userId = json["userId"],
        createdAt = json["createdAt"],
        photo = json["photo"],
        title = json["title"],
        userName = json["users"]["name"];

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "eventId": eventId,
      "createdAt": createdAt,
      "photo": photo,
      "title": title,
    };
  }
}
