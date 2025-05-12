import 'dart:convert';

class ProfileModel {
  String? status;
  String? message;
  Data? data;

  ProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProfileModel.fromRawJson(String str) =>
      ProfileModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  User? user;
  Earnings? earnings;
  String? averageRating;
  int? totalReviews;

  Data({
    this.user,
    this.earnings,
    this.averageRating,
    this.totalReviews,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        earnings: json["earnings"] == null
            ? null
            : Earnings.fromJson(json["earnings"]),
        averageRating: json["averageRating"],
        totalReviews: json["totalReviews"],
      );

  Map<String, dynamic> toJson() => {
        "user": user?.toJson(),
        "earnings": earnings?.toJson(),
        "averageRating": averageRating,
        "totalReviews": totalReviews,
      };
}

class Earnings {
  int? totalEarnings;
  int? monthlyEarnings;
  int? totalAmountSpent;
  int? totalSentParcels;
  int? totalReceivedParcels;
  int? tripsCompleted;

  Earnings({
    this.totalEarnings,
    this.monthlyEarnings,
    this.totalAmountSpent,
    this.totalSentParcels,
    this.totalReceivedParcels,
    this.tripsCompleted,
  });

  factory Earnings.fromRawJson(String str) =>
      Earnings.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Earnings.fromJson(Map<String, dynamic> json) => Earnings(
        totalEarnings: json["totalEarnings"],
        monthlyEarnings: json["monthlyEarnings"],
        totalAmountSpent: json["totalAmountSpent"],
        totalSentParcels: json["totalSentParcels"],
        totalReceivedParcels: json["totalReceivedParcels"],
        tripsCompleted: json["tripsCompleted"],
      );

  Map<String, dynamic> toJson() => {
        "totalEarnings": totalEarnings,
        "monthlyEarnings": monthlyEarnings,
        "totalAmountSpent": totalAmountSpent,
        "totalSentParcels": totalSentParcels,
        "totalReceivedParcels": totalReceivedParcels,
        "tripsCompleted": tripsCompleted,
      };
}

class User {
  String? id;
  String? fullName;
  String? country;
  String? mobileNumber;
  String? image;
  String? role;
  bool? isTrial;
  bool? isVerified;
  int? freeDeliveries;
  int? totaltripsCompleted;
  int? totalOrders;
  int? totalDelivered;
  bool? isSubscribed;
  bool? isRestricted;
  String? subscriptionType;
  int? subscriptionPrice;
  int? subscriptionCount;
  List<Order>? sendOrders;
  List<Order>? recciveOrders;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionExpiryDate;
  List<dynamic>? reviews;
  DateTime? startDate;
  DateTime? expiryDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? totalReceivedParcels;
  int? monthlyEarnings;
  int? totalAmountSpent;
  int? totalEarning;
  int? totalSentParcels;
  String? email;
  String? facebook;
  String? instagram;
  String? whatsapp;

  int? avgRating;

  User({
    this.id,
    this.fullName,
    this.country,
    this.mobileNumber,
    this.image,
    this.role,
    this.isTrial,
    this.isVerified,
    this.freeDeliveries,
    this.totaltripsCompleted,
    this.totalOrders,
    this.totalDelivered,
    this.isSubscribed,
    this.isRestricted,
    this.subscriptionType,
    this.subscriptionPrice,
    this.subscriptionCount,
    this.sendOrders,
    this.recciveOrders,
    this.subscriptionStartDate,
    this.subscriptionExpiryDate,
    this.reviews,
    this.startDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.totalReceivedParcels,
    this.monthlyEarnings,
    this.totalAmountSpent,
    this.totalEarning,
    this.totalSentParcels,
    this.email,
    this.facebook,
    this.instagram,
    this.whatsapp,
    this.avgRating,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["_id"],
        fullName: json["fullName"],
        country: json["country"],
        mobileNumber: json["mobileNumber"],
        image: json["image"],
        role: json["role"],
        isTrial: json["isTrial"],
        isVerified: json["isVerified"],
        freeDeliveries: json["freeDeliveries"],
        totaltripsCompleted: json["TotaltripsCompleted"],
        totalOrders: json["totalOrders"],
        totalDelivered: json["totalDelivered"],
        isSubscribed: json["isSubscribed"],
        isRestricted: json["isRestricted"],
        subscriptionType: json["subscriptionType"],
        subscriptionPrice: json["subscriptionPrice"],
        subscriptionCount: json["subscriptionCount"],
        sendOrders: json["SendOrders"] == null
            ? []
            : List<Order>.from(
                json["SendOrders"]!.map((x) => Order.fromJson(x))),
        recciveOrders: json["RecciveOrders"] == null
            ? []
            : List<Order>.from(
                json["RecciveOrders"]!.map((x) => Order.fromJson(x))),
        subscriptionStartDate: json["subscriptionStartDate"] == null
            ? null
            : DateTime.parse(json["subscriptionStartDate"]),
        subscriptionExpiryDate: json["subscriptionExpiryDate"] == null
            ? null
            : DateTime.parse(json["subscriptionExpiryDate"]),
        reviews: json["reviews"] == null
            ? []
            : List<dynamic>.from(json["reviews"]!.map((x) => x)),
        startDate: json["startDate"] == null
            ? null
            : DateTime.parse(json["startDate"]),
        expiryDate: json["expiryDate"] == null
            ? null
            : DateTime.parse(json["expiryDate"]),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        totalReceivedParcels: json["totalReceivedParcels"],
        monthlyEarnings: json["monthlyEarnings"],
        totalAmountSpent: json["totalAmountSpent"],
        totalEarning: json["totalEarning"],
        totalSentParcels: json["totalSentParcels"],
        email: json["email"],
        facebook: json["facebook"],
        instagram: json["instagram"],
        whatsapp: json["whatsapp"],
        avgRating: json["avgRating"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "fullName": fullName,
        "country": country,
        "mobileNumber": mobileNumber,
        "image": image,
        "role": role,
        "isTrial": isTrial,
        "isVerified": isVerified,
        "freeDeliveries": freeDeliveries,
        "TotaltripsCompleted": totaltripsCompleted,
        "totalOrders": totalOrders,
        "totalDelivered": totalDelivered,
        "isSubscribed": isSubscribed,
        "isRestricted": isRestricted,
        "subscriptionType": subscriptionType,
        "subscriptionPrice": subscriptionPrice,
        "subscriptionCount": subscriptionCount,
        "SendOrders": sendOrders == null
            ? []
            : List<dynamic>.from(sendOrders!.map((x) => x.toJson())),
        "RecciveOrders": recciveOrders == null
            ? []
            : List<dynamic>.from(recciveOrders!.map((x) => x.toJson())),
        "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
        "subscriptionExpiryDate": subscriptionExpiryDate?.toIso8601String(),
        "reviews":
            reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
        "startDate": startDate?.toIso8601String(),
        "expiryDate": expiryDate?.toIso8601String(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "totalReceivedParcels": totalReceivedParcels,
        "monthlyEarnings": monthlyEarnings,
        "totalAmountSpent": totalAmountSpent,
        "totalEarning": totalEarning,
        "totalSentParcels": totalSentParcels,
        "email": email,
        "facebook": facebook,
        "instagram": instagram,
        "whatsapp": whatsapp,
      };
}

class Order {
  ParcelId? parcelId;
  String? pickupLocation;
  String? deliveryLocation;
  int? price;
  String? title;
  String? description;
  String? senderType;
  String? deliveryType;
  DateTime? deliveryStartTime;
  DateTime? deliveryEndTime;
  String? id;

  Order({
    this.parcelId,
    this.pickupLocation,
    this.deliveryLocation,
    this.price,
    this.title,
    this.description,
    this.senderType,
    this.deliveryType,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.id,
  });

  factory Order.fromRawJson(String str) => Order.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        parcelId: json["parcelId"] == null
            ? null
            : ParcelId.fromJson(json["parcelId"]),
        pickupLocation: json["pickupLocation"],
        deliveryLocation: json["deliveryLocation"],
        price: json["price"],
        title: json["title"],
        description: json["description"],
        senderType: json["senderType"],
        deliveryType: json["deliveryType"],
        deliveryStartTime: json["deliveryStartTime"] == null
            ? null
            : DateTime.parse(json["deliveryStartTime"]),
        deliveryEndTime: json["deliveryEndTime"] == null
            ? null
            : DateTime.parse(json["deliveryEndTime"]),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "parcelId": parcelId?.toJson(),
        "pickupLocation": pickupLocation,
        "deliveryLocation": deliveryLocation,
        "price": price,
        "title": title,
        "description": description,
        "senderType": senderType,
        "deliveryType": deliveryType,
        "deliveryStartTime": deliveryStartTime?.toIso8601String(),
        "deliveryEndTime": deliveryEndTime?.toIso8601String(),
        "_id": id,
      };
}

class ParcelId {
  Location? pickupLocation;
  Location? deliveryLocation;
  String? id;
  String? description;
  String? title;
  DateTime? deliveryStartTime;
  DateTime? deliveryEndTime;
  String? deliveryType;
  String? senderType;
  int? price;

  ParcelId({
    this.pickupLocation,
    this.deliveryLocation,
    this.id,
    this.description,
    this.title,
    this.deliveryStartTime,
    this.deliveryEndTime,
    this.deliveryType,
    this.senderType,
    this.price,
  });

  factory ParcelId.fromRawJson(String str) =>
      ParcelId.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ParcelId.fromJson(Map<String, dynamic> json) => ParcelId(
        pickupLocation: json["pickupLocation"] == null
            ? null
            : Location.fromJson(json["pickupLocation"]),
        deliveryLocation: json["deliveryLocation"] == null
            ? null
            : Location.fromJson(json["deliveryLocation"]),
        id: json["_id"],
        description: json["description"],
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
      );

  Map<String, dynamic> toJson() => {
        "pickupLocation": pickupLocation?.toJson(),
        "deliveryLocation": deliveryLocation?.toJson(),
        "_id": id,
        "description": description,
        "title": title,
        "deliveryStartTime": deliveryStartTime?.toIso8601String(),
        "deliveryEndTime": deliveryEndTime?.toIso8601String(),
        "deliveryType": deliveryType,
        "senderType": senderType,
        "price": price,
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
