class NotificationModel {
  String? status;
  List<NotificationDataList>? notificationData;

  NotificationModel({this.status, this.notificationData});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      notificationData = <NotificationDataList>[];
      json['data'].forEach((v) {
        notificationData!.add(NotificationDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (notificationData != null) {
      data['data'] = notificationData!.map((v) => v.toJson()).toList();
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
  String? mobileNumber;
  String? phoneNumber;
  bool? isRead;
  String? createdAt;
  int? iV;
  String? image;

  NotificationDataList({
    this.sId,
    this.userId,
    this.message,
    this.type,
    this.title,
    this.description,
    this.mobileNumber,
    this.phoneNumber,
    this.isRead,
    this.createdAt,
    this.iV,
    this.image,
  });

  NotificationDataList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    message = json['message'];
    type = json['type'];
    title = json['title'];
    mobileNumber = json['mobileNumber'];
    phoneNumber = json['PhoneNumber'];
    description = json['description'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['message'] = message;
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['mobileNumber'] = mobileNumber;
    data['PhoneNumber'] = phoneNumber;
    data['isRead'] = isRead;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    data['image'] = image;
    return data;
  }
}
