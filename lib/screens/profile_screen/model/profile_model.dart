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

  factory ProfileModel.fromRawJson(String str) => ProfileModel.fromJson(json.decode(str));

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
    earnings: json["earnings"] == null ? null : Earnings.fromJson(json["earnings"]),
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

  factory Earnings.fromRawJson(String str) => Earnings.fromJson(json.decode(str));

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
  String? email;
  String? mobileNumber;
  String? image;
  String? role;
  bool? isTrial;
  bool? isVerified;
  int? freeDeliveries;
  int? totaltripsCompleted;
  int? totalOrders;
  int? totalDelivered;
  int? totalEarning;
  int? monthlyEarnings;
  int? totalAmountSpent;
  int? totalSentParcels;
  int? totalReceivedParcels;
  bool? notificationStatus;
  bool? isSubscribed;
  bool? isRestricted;
  String? subscriptionType;
  int? subscriptionPrice;
  int? subscriptionCount;
  int? avgRating;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionExpiryDate;
  List<Review>? reviews;
  DateTime? startDate;
  DateTime? expiryDate;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? facebook;
  String? instagram;
  String? whatsapp;
  String? fcmToken;

  User({
    this.id,
    this.fullName,
    this.country,
    this.email,
    this.mobileNumber,
    this.image,
    this.role,
    this.isTrial,
    this.isVerified,
    this.freeDeliveries,
    this.totaltripsCompleted,
    this.totalOrders,
    this.totalDelivered,
    this.totalEarning,
    this.monthlyEarnings,
    this.totalAmountSpent,
    this.totalSentParcels,
    this.totalReceivedParcels,
    this.notificationStatus,
    this.isSubscribed,
    this.isRestricted,
    this.subscriptionType,
    this.subscriptionPrice,
    this.subscriptionCount,
    this.avgRating,
    this.subscriptionStartDate,
    this.subscriptionExpiryDate,
    this.reviews,
    this.startDate,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.facebook,
    this.instagram,
    this.whatsapp,
    this.fcmToken,
  });

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    fullName: json["fullName"],
    country: json["country"],
    email: json["email"],
    mobileNumber: json["mobileNumber"],
    image: json["image"],
    role: json["role"],
    isTrial: json["isTrial"],
    isVerified: json["isVerified"],
    freeDeliveries: json["freeDeliveries"],
    totaltripsCompleted: json["TotaltripsCompleted"],
    totalOrders: json["totalOrders"],
    totalDelivered: json["totalDelivered"],
    totalEarning: json["totalEarning"],
    monthlyEarnings: json["monthlyEarnings"],
    totalAmountSpent: json["totalAmountSpent"],
    totalSentParcels: json["totalSentParcels"],
    totalReceivedParcels: json["totalReceivedParcels"],
    notificationStatus: json["notificationStatus"],
    isSubscribed: json["isSubscribed"],
    isRestricted: json["isRestricted"],
    subscriptionType: json["subscriptionType"],
    subscriptionPrice: json["subscriptionPrice"],
    subscriptionCount: json["subscriptionCount"],
    avgRating: json["avgRating"],
    subscriptionStartDate: json["subscriptionStartDate"] == null ? null : DateTime.parse(json["subscriptionStartDate"]),
    subscriptionExpiryDate: json["subscriptionExpiryDate"] == null ? null : DateTime.parse(json["subscriptionExpiryDate"]),
    reviews: json["reviews"] == null ? [] : List<Review>.from(json["reviews"]!.map((x) => Review.fromJson(x))),
    startDate: json["startDate"] == null ? null : DateTime.parse(json["startDate"]),
    expiryDate: json["expiryDate"] == null ? null : DateTime.parse(json["expiryDate"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    facebook: json["facebook"],
    instagram: json["instagram"],
    whatsapp: json["whatsapp"],
    fcmToken: json["fcmToken"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "fullName": fullName,
    "country": country,
    "email": email,
    "mobileNumber": mobileNumber,
    "image": image,
    "role": role,
    "isTrial": isTrial,
    "isVerified": isVerified,
    "freeDeliveries": freeDeliveries,
    "TotaltripsCompleted": totaltripsCompleted,
    "totalOrders": totalOrders,
    "totalDelivered": totalDelivered,
    "totalEarning": totalEarning,
    "monthlyEarnings": monthlyEarnings,
    "totalAmountSpent": totalAmountSpent,
    "totalSentParcels": totalSentParcels,
    "totalReceivedParcels": totalReceivedParcels,
    "notificationStatus": notificationStatus,
    "isSubscribed": isSubscribed,
    "isRestricted": isRestricted,
    "subscriptionType": subscriptionType,
    "subscriptionPrice": subscriptionPrice,
    "subscriptionCount": subscriptionCount,
    "avgRating": avgRating,
    "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
    "subscriptionExpiryDate": subscriptionExpiryDate?.toIso8601String(),
    "reviews": reviews == null ? [] : List<dynamic>.from(reviews!.map((x) => x.toJson())),
    "startDate": startDate?.toIso8601String(),
    "expiryDate": expiryDate?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "facebook": facebook,
    "instagram": instagram,
    "whatsapp": whatsapp,
    "fcmToken": fcmToken,
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
