import 'dart:convert';

class NotifyParcelModel {
  String? status;
  Data? data;

  NotifyParcelModel({
    this.status,
    this.data,
  });

  factory NotifyParcelModel.fromRawJson(String str) =>
      NotifyParcelModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory NotifyParcelModel.fromJson(Map<String, dynamic> json) =>
      NotifyParcelModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  List<Notification>? notifications;
  Pagination? pagination;

  Data({
    this.notifications,
    this.pagination,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        notifications: json["notifications"] == null
            ? []
            : List<Notification>.from(
                json["notifications"]!.map((x) => Notification.fromJson(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
        "notifications": notifications == null
            ? []
            : List<dynamic>.from(notifications!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
      };
}

class Notification {
  String? id;
  String? userId;
  String? message;
  Type? type;
  String? title;
  String? phoneNumber;
  String? mobileNumber;
  String? image;
  int? price;
  int? avgRating;
  String? description;
  bool? isRead;
  DateTime? createdAt;
  int? v;

  Notification({
    this.id,
    this.userId,
    this.message,
    this.type,
    this.title,
    this.phoneNumber,
    this.mobileNumber,
    this.image,
    this.price,
    this.avgRating,
    this.description,
    this.isRead,
    this.createdAt,
    this.v,
  });

  factory Notification.fromRawJson(String str) =>
      Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["_id"],
        userId: json["userId"]!,
        message: json["message"],
        type: typeValues.map[json["type"]]!,
        title: json["title"],
        phoneNumber: json["phoneNumber"],
        mobileNumber: json["mobileNumber"],
        image: json["image"],
        price: json["price"],
        avgRating: json["AvgRating"],
        description: json["description"],
        isRead: json["isRead"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userIdValues.reverse[userId],
        "message": message,
        "type": typeValues.reverse[type],
        "title": title,
        "phoneNumber": phoneNumber,
        "mobileNumber": mobileNumber,
        "image": image,
        "price": price,
        "AvgRating": avgRating,
        "description": description,
        "isRead": isRead,
        "createdAt": createdAt?.toIso8601String(),
        "__v": v,
      };
}

enum Type { SEND_PARCEL }

final typeValues = EnumValues({"send_parcel": Type.SEND_PARCEL});

enum UserId { THE_680_A5_FABD6030_C12_C9155707 }

final userIdValues = EnumValues(
    {"680a5fabd6030c12c9155707": UserId.THE_680_A5_FABD6030_C12_C9155707});

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? pages;

  Pagination({
    this.total,
    this.page,
    this.limit,
    this.pages,
  });

  factory Pagination.fromRawJson(String str) =>
      Pagination.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        pages: json["pages"],
      );

  Map<String, dynamic> toJson() => {
        "total": total,
        "page": page,
        "limit": limit,
        "pages": pages,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
