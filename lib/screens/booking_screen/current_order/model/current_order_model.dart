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
  SenderId? senderId;
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
  List<dynamic>? images;
  String? status;
  List<SenderId>? deliveryRequests;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  dynamic assignedDelivererId;
  String? typeParcel;
  List<SenderId>? deliveryRequestsWithRating;

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
    this.deliveryRequestsWithRating,
  });

  factory Datum.fromRawJson(String str) => Datum.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["_id"],
        senderId: json["senderId"] == null
            ? null
            : SenderId.fromJson(json["senderId"]),
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
            : List<dynamic>.from(json["images"]!.map((x) => x)),
        status: json["status"],
        deliveryRequests: json["deliveryRequests"] == null
            ? []
            : List<SenderId>.from(
                json["deliveryRequests"]!.map((x) => SenderId.fromJson(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        assignedDelivererId: json["assignedDelivererId"],
        typeParcel: json["typeParcel"],
        deliveryRequestsWithRating: json["deliveryRequestsWithRating"] == null
            ? []
            : List<SenderId>.from(json["deliveryRequestsWithRating"]!
                .map((x) => SenderId.fromJson(x))),
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
            : List<dynamic>.from(deliveryRequests!.map((x) => x.toJson())),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "assignedDelivererId": assignedDelivererId,
        "typeParcel": typeParcel,
        "deliveryRequestsWithRating": deliveryRequestsWithRating == null
            ? []
            : List<dynamic>.from(
                deliveryRequestsWithRating!.map((x) => x.toJson())),
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
  String? image;
  String? role;
  List<Review>? reviews;
  String? mobileNumber;

  SenderId({
    this.id,
    this.fullName,
    this.email,
    this.image,
    this.role,
    this.reviews,
    this.mobileNumber,
  });

  factory SenderId.fromRawJson(String str) =>
      SenderId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SenderId.fromJson(Map<String, dynamic> json) => SenderId(
        id: json["_id"],
        fullName: json["fullName"],
        email: json["email"],
        image: json["image"],
        role: json["role"],
        reviews: json["reviews"] == null
            ? []
            : List<Review>.from(
                json["reviews"]!.map((x) => Review.fromJson(x))),
        mobileNumber: json["mobileNumber"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullName": fullName,
        "email": email,
        "image": image,
        "role": role,
        "reviews": reviews == null
            ? []
            : List<dynamic>.from(reviews!.map((x) => x.toJson())),
        "mobileNumber": mobileNumber,
      };
}

class Review {
  String? parcelId;
  int? rating;
  String? id;

  Review({
    this.parcelId,
    this.rating,
    this.id,
  });

  factory Review.fromRawJson(String str) => Review.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        parcelId: json["parcelId"],
        rating: json["rating"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "parcelId": parcelId,
        "rating": rating,
        "_id": id,
      };
}
