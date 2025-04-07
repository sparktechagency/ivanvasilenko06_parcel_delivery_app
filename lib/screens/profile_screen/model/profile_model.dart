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
  int? totaltripsCompleted;
  int? totalOrders;
  int? totalDelivered;
  String? id;
  String? fullName;
  String? email;
  List<dynamic>? socialLinks;
  String? role;
  bool? isVerified;
  int? freeDeliveries;
  int? tripsCompleted;
  int? tripsPerDay;
  int? monthlyEarnings;
  int? totalAmountSpent;
  int? totalSentParcels;
  int? totalReceivedParcels;
  bool? isRestricted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? profileImage;
  DateTime? expiryDate;
  bool? isSubscribed;
  DateTime? startDate;
  int? subscriptionCount;
  DateTime? subscriptionExpiryDate;
  int? subscriptionPrice;
  DateTime? subscriptionStartDate;
  String? subscriptionType;
  List<dynamic>? sendOrders;
  List<dynamic>? recciveOrders;
  List<dynamic>? reviews;

  Data({
    this.totaltripsCompleted,
    this.totalOrders,
    this.totalDelivered,
    this.id,
    this.fullName,
    this.email,
    this.socialLinks,
    this.role,
    this.isVerified,
    this.freeDeliveries,
    this.tripsCompleted,
    this.tripsPerDay,
    this.monthlyEarnings,
    this.totalAmountSpent,
    this.totalSentParcels,
    this.totalReceivedParcels,
    this.isRestricted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.profileImage,
    this.expiryDate,
    this.isSubscribed,
    this.startDate,
    this.subscriptionCount,
    this.subscriptionExpiryDate,
    this.subscriptionPrice,
    this.subscriptionStartDate,
    this.subscriptionType,
    this.sendOrders,
    this.recciveOrders,
    this.reviews,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        totaltripsCompleted: json["TotaltripsCompleted"],
        totalOrders: json["totalOrders"],
        totalDelivered: json["totalDelivered"],
        id: json["_id"],
        fullName: json["fullName"],
        email: json["email"],
        socialLinks: json["socialLinks"] == null
            ? []
            : List<dynamic>.from(json["socialLinks"]!.map((x) => x)),
        role: json["role"],
        isVerified: json["isVerified"],
        freeDeliveries: json["freeDeliveries"],
        tripsCompleted: json["tripsCompleted"],
        tripsPerDay: json["tripsPerDay"],
        monthlyEarnings: json["monthlyEarnings"],
        totalAmountSpent: json["totalAmountSpent"],
        totalSentParcels: json["totalSentParcels"],
        totalReceivedParcels: json["totalReceivedParcels"],
        isRestricted: json["isRestricted"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        profileImage: json["profileImage"],
        expiryDate: json["expiryDate"] == null
            ? null
            : DateTime.parse(json["expiryDate"]),
        isSubscribed: json["isSubscribed"],
        startDate: json["startDate"] == null
            ? null
            : DateTime.parse(json["startDate"]),
        subscriptionCount: json["subscriptionCount"],
        subscriptionExpiryDate: json["subscriptionExpiryDate"] == null
            ? null
            : DateTime.parse(json["subscriptionExpiryDate"]),
        subscriptionPrice: json["subscriptionPrice"],
        subscriptionStartDate: json["subscriptionStartDate"] == null
            ? null
            : DateTime.parse(json["subscriptionStartDate"]),
        subscriptionType: json["subscriptionType"],
        sendOrders: json["SendOrders"] == null
            ? []
            : List<dynamic>.from(json["SendOrders"]!.map((x) => x)),
        recciveOrders: json["RecciveOrders"] == null
            ? []
            : List<dynamic>.from(json["RecciveOrders"]!.map((x) => x)),
        reviews: json["reviews"] == null
            ? []
            : List<dynamic>.from(json["reviews"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "TotaltripsCompleted": totaltripsCompleted,
        "totalOrders": totalOrders,
        "totalDelivered": totalDelivered,
        "_id": id,
        "fullName": fullName,
        "email": email,
        "socialLinks": socialLinks == null
            ? []
            : List<dynamic>.from(socialLinks!.map((x) => x)),
        "role": role,
        "isVerified": isVerified,
        "freeDeliveries": freeDeliveries,
        "tripsCompleted": tripsCompleted,
        "tripsPerDay": tripsPerDay,
        "monthlyEarnings": monthlyEarnings,
        "totalAmountSpent": totalAmountSpent,
        "totalSentParcels": totalSentParcels,
        "totalReceivedParcels": totalReceivedParcels,
        "isRestricted": isRestricted,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "profileImage": profileImage,
        "expiryDate": expiryDate?.toIso8601String(),
        "isSubscribed": isSubscribed,
        "startDate": startDate?.toIso8601String(),
        "subscriptionCount": subscriptionCount,
        "subscriptionExpiryDate": subscriptionExpiryDate?.toIso8601String(),
        "subscriptionPrice": subscriptionPrice,
        "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
        "subscriptionType": subscriptionType,
        "SendOrders": sendOrders == null
            ? []
            : List<dynamic>.from(sendOrders!.map((x) => x)),
        "RecciveOrders": recciveOrders == null
            ? []
            : List<dynamic>.from(recciveOrders!.map((x) => x)),
        "reviews":
            reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x)),
      };
}
