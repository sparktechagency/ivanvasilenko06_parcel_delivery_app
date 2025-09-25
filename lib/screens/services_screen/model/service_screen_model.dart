import 'dart:convert';

class ServiceScreenModel {
  String? status;
  List<Datum>? data;

  ServiceScreenModel({
    this.status,
    this.data,
  });

  factory ServiceScreenModel.fromRawJson(String str) =>
      ServiceScreenModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ServiceScreenModel.fromJson(Map<String, dynamic> json) =>
      ServiceScreenModel(
        status: json["status"],
        data: json["data"] == null
            ? []
            : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data == null
            ? []
            : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Datum {
  String? id;
  Location? pickupLocation;
  Location? deliveryLocation;
  SenderId? senderId;
  String? description;
  String? title;
  String? deliveryType;
  String? senderType;
  int? price;
  String? name;
  String? phoneNumber;
  List<dynamic>? images;
  String? deliveryStartTime;
  String? deliveryEndTime;
  String? status;
  List<dynamic>? deliveryRequests;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isRequestedByMe;

  Datum({
    this.id,
    this.pickupLocation,
    this.deliveryLocation,
    this.senderId,
    this.description,
    this.title,
    this.deliveryType,
    this.senderType,
    this.price,
    this.name,
    this.phoneNumber,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.images,
    this.status,
    this.deliveryRequests,
    this.createdAt,
    this.updatedAt,
    this.isRequestedByMe,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        pickupLocation: json["pickupLocation"] == null
            ? null
            : Location.fromJson(json["pickupLocation"]),
        deliveryLocation: json["deliveryLocation"] == null
            ? null
            : Location.fromJson(json["deliveryLocation"]),
        senderId: json["senderId"] == null
            ? null
            : SenderId.fromJson(json["senderId"]),
        description: json["description"],
        title: json["title"],
        deliveryType: json["deliveryType"],
        senderType: json["senderType"],
        price: json["price"],
        deliveryStartTime: json["deliveryStartTime"],
        deliveryEndTime: json["deliveryEndTime"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        images: json["images"] == null
            ? []
            : List<dynamic>.from(json["images"]!.map((x) => x)),
        status: json["status"],
        deliveryRequests: json["deliveryRequests"] == null
            ? []
            : List<dynamic>.from(json["deliveryRequests"]!.map((x) => x)),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        isRequestedByMe: json["isRequestedByMe"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "pickupLocation": pickupLocation?.toJson(),
        "deliveryLocation": deliveryLocation?.toJson(),
        "senderId": senderId?.toJson(),
        "description": description,
        "title": title,
        "deliveryType": deliveryType,
        "senderType": senderType,
        "deliveryStartTime": deliveryStartTime,
        "deliveryEndTime": deliveryEndTime,
        "price": price,
        "name": name,
        "phoneNumber": phoneNumber,
        "images":
            images == null ? [] : List<dynamic>.from(images!.map((x) => x)),
        "status": status,
        "deliveryRequests": deliveryRequests == null
            ? []
            : List<dynamic>.from(deliveryRequests!.map((x) => x)),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "isRequestedByMe": isRequestedByMe,
      };
}

class Location {
  String? type;
  List<double>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: json["type"],
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x)),
      };
}

class SenderId {
  String? id;
  String? fullName;
  String? email;
  String? role;

  SenderId({
    this.id,
    this.fullName,
    this.email,
    this.role,
  });

  factory SenderId.fromRawJson(String str) =>
      SenderId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SenderId.fromJson(Map<String, dynamic> json) => SenderId(
        id: json["_id"],
        fullName: json["fullName"],
        email: json["email"],
        role: json["role"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullName": fullName,
        "email": email,
        "role": role,
      };
}
