class NotificationModel {
  String? status;
  List<NotificationDataList>? notificationDataList;

  NotificationModel({this.status, this.notificationDataList});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      notificationDataList = <NotificationDataList>[];
      json['data'].forEach((v) {
        notificationDataList!.add(NotificationDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (notificationDataList != null) {
      data['data'] = notificationDataList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationDataList {
  String? sId;
  String? userId;
  String? message;
  String? type;
  String? title;
  String? description;
  bool? isRead;
  String? createdAt;
  int? iV;

  NotificationDataList(
      {this.sId,
      this.userId,
      this.message,
      this.type,
      this.title,
      this.description,
      this.isRead,
      this.createdAt,
      this.iV});

  NotificationDataList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    message = json['message'];
    type = json['type'];
    title = json['title'];
    description = json['description'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['message'] = message;
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['isRead'] = isRead;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}
