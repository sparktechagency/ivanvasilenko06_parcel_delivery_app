import 'dart:convert';

class CurrentOrderModel {
  String? status;
  List<Datum>? data;

  CurrentOrderModel({
    this.status,
    this.data,
  });

  factory CurrentOrderModel.fromRawJson(String str) =>
      CurrentOrderModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CurrentOrderModel.fromJson(Map<String, dynamic> json) =>
      CurrentOrderModel(
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
  ErId? senderId;
  String? description;
  Location? pickupLocation;
  Location? deliveryLocation;
  String? title;
  DateTime? deliveryStartTime;
  DateTime? deliveryEndTime;
  String? deliveryType;
  String? senderType;
  int? price;
  String? name;
  String? phoneNumber;
  List<String>? images;
  String? status;
  List<dynamic>? deliveryRequests;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  ErId? assignedDelivererId;

  String? typeParcel;

  Datum({
    this.id,
    this.senderId,
    this.description,
    this.pickupLocation,
    this.deliveryLocation,
    this.title,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.deliveryType,
    this.senderType,
    this.price,
    this.name,
    this.phoneNumber,
    this.images,
    this.status,
    this.deliveryRequests,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.assignedDelivererId,
    this.typeParcel,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        senderId:
            json["senderId"] == null ? null : ErId.fromJson(json["senderId"]),
        description: json["description"],
        pickupLocation: json["pickupLocation"] == null
            ? null
            : Location.fromJson(json["pickupLocation"]),
        deliveryLocation: json["deliveryLocation"] == null
            ? null
            : Location.fromJson(json["deliveryLocation"]),
        title: json["title"],
        deliveryStartTime: json["deliveryStartTime"] == null
            ? null
            : DateTime.parse(json["deliveryStartTime"]),
        deliveryEndTime: json["deliveryEndTime"] == null
            ? null
            : DateTime.parse(json["deliveryEndTime"]),
        deliveryType: json["deliveryType"],
        senderType: json["senderType"],
        price: json["price"],
        name: json["name"],
        phoneNumber: json["phoneNumber"],
        images: json["images"] == null
            ? []
            : List<String>.from(json["images"]!.map((x) => x)),
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
        v: json["__v"],
        assignedDelivererId: json["assignedDelivererId"] == null
            ? null
            : ErId.fromJson(json["assignedDelivererId"]),
        typeParcel: json["typeParcel"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "senderId": senderId?.toJson(),
        "description": description,
        "pickupLocation": pickupLocation?.toJson(),
        "deliveryLocation": deliveryLocation?.toJson(),
        "title": title,
        "deliveryStartTime": deliveryStartTime?.toIso8601String(),
        "deliveryEndTime": deliveryEndTime?.toIso8601String(),
        "deliveryType": deliveryType,
        "senderType": senderType,
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
        "__v": v,
        "assignedDelivererId": assignedDelivererId?.toJson(),
        "typeParcel": typeParcel,
      };
}

class ErId {
  String? id;
  String? fullName;
  String? mobileNumber;
  String? role;
  String? email;
  String? image;

  int? avgRating;

  ErId({
    this.id,
    this.fullName,
    this.mobileNumber,
    this.role,
    this.email,
    this.image,
    this.avgRating,
  });

  factory ErId.fromRawJson(String str) => ErId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ErId.fromJson(Map<String, dynamic> json) => ErId(
        id: json["_id"],
        fullName: json["fullName"],
        mobileNumber: json["mobileNumber"],
        role: json["role"],
        email: json["email"],
        image: json["image"],
        avgRating: json["avgRating"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullName": fullName,
        "mobileNumber": mobileNumber,
        "role": role,
        "email": email,
        "image": image,
      };
}

class Location {
  Type? type;
  List<double>? coordinates;

  Location({
    this.type,
    this.coordinates,
  });

  factory Location.fromRawJson(String str) =>
      Location.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        type: typeValues.map[json["type"]]!,
        coordinates: json["coordinates"] == null
            ? []
            : List<double>.from(json["coordinates"]!.map((x) => x?.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        "type": typeValues.reverse[type],
        "coordinates": coordinates == null
            ? []
            : List<dynamic>.from(coordinates!.map((x) => x)),
      };
}

enum Type { POINT }

final typeValues = EnumValues({"Point": Type.POINT});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
