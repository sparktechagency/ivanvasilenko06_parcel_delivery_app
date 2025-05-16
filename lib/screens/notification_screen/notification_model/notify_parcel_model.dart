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
  Location? pickupLocation;
  Location? deliveryLocation;
  String? parcelId;
  int? avgRating;
  String? description;
  String? deliveryStartTime;
  String? deliveryEndTime;
  bool? isRead;
  DateTime? createdAt;

  DateTime? localCreatedAt;
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
    this.pickupLocation,
    this.deliveryLocation,
    this.parcelId,
    this.avgRating,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.description,
    this.isRead,
    this.createdAt,
    this.localCreatedAt,
    this.v,
  });

  factory Notification.fromRawJson(String str) =>
      Notification.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["_id"],
        userId: json["userId"],
        message: json["message"],
        type: json["type"] == null ? null : typeValues.map[json["type"]],
        title: json["title"],
        phoneNumber: json["phoneNumber"],
        mobileNumber: json["mobileNumber"],
        image: json["image"],
        price: json["price"],
        pickupLocation: json["pickupLocation"] == null
            ? null
            : Location.fromJson(json["pickupLocation"]),
        deliveryLocation: json["deliveryLocation"] == null
            ? null
            : Location.fromJson(json["deliveryLocation"]),
        parcelId: json["parcelId"],
        avgRating: json["AvgRating"],
        deliveryStartTime: json["deliveryStartTime"],
        deliveryEndTime: json["deliveryEndTime"],
        description: json["description"],
        isRead: json["isRead"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        localCreatedAt: json["localCreatedAt"] == null
            ? null
            : DateTime.parse(json["localCreatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "message": message,
        "type": type == null ? null : typeValues.reverse[type],
        "title": title,
        "phoneNumber": phoneNumber,
        "mobileNumber": mobileNumber,
        "image": image,
        "price": price,
        "pickupLocation": pickupLocation?.toJson(),
        "deliveryLocation": deliveryLocation?.toJson(),
        "deliveryStartTime": deliveryStartTime,
        "deliveryEndTime": deliveryEndTime,
        "parcelId": parcelId,
        "AvgRating": avgRating,
        "description": description,
        "isRead": isRead,
        "createdAt": createdAt?.toIso8601String(),
        "localCreatedAt": localCreatedAt?.toIso8601String(),
        "__v": v,
      };
}

class Location {
  double? latitude;
  double? longitude;
  String? id;

  Location({
    this.latitude,
    this.longitude,
    this.id,
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        latitude: json["latitude"]?.toDouble(),
        longitude: json["longitude"]?.toDouble(),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "_id": id,
      };
}

enum Type { SEND_PARCEL }

final typeValues = EnumValues({"send_parcel": Type.SEND_PARCEL});

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
