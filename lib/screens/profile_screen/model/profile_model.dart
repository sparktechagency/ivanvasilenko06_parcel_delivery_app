class ProfileModel {
  String? status;
  String? message;
  ProfileData? data;

  ProfileModel({this.status, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ProfileData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ProfileData {
  String? sId;
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
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? profileImage;
  String? expiryDate;
  bool? isSubscribed;
  String? startDate;
  int? subscriptionCount;
  String? subscriptionExpiryDate;
  int? subscriptionPrice;
  String? subscriptionStartDate;
  String? subscriptionType;
  List<dynamic>? recciveOrders;
  List<dynamic>? sendOrders;
  int? totaltripsCompleted;
  bool? isTrial;
  List<dynamic>? reviews;
  int? totalDelivered;
  int? totalOrders;

  ProfileData({
    this.sId,
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
    this.iV,
    this.profileImage,
    this.expiryDate,
    this.isSubscribed,
    this.startDate,
    this.subscriptionCount,
    this.subscriptionExpiryDate,
    this.subscriptionPrice,
    this.subscriptionStartDate,
    this.subscriptionType,
    this.recciveOrders,
    this.sendOrders,
    this.totaltripsCompleted,
    this.isTrial,
    this.reviews,
    this.totalDelivered,
    this.totalOrders
  });

  ProfileData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    if (json['socialLinks'] != null) {
      socialLinks = List<dynamic>.from(json['socialLinks']);
    }
    role = json['role'];
    isVerified = json['isVerified'];
    freeDeliveries = json['freeDeliveries'];
    tripsCompleted = json['tripsCompleted'];
    tripsPerDay = json['tripsPerDay'];
    monthlyEarnings = json['monthlyEarnings'];
    totalAmountSpent = json['totalAmountSpent'];
    totalSentParcels = json['totalSentParcels'];
    totalReceivedParcels = json['totalReceivedParcels'];
    isRestricted = json['isRestricted'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    profileImage = json['profileImage'];
    expiryDate = json['expiryDate'];
    isSubscribed = json['isSubscribed'];
    startDate = json['startDate'];
    subscriptionCount = json['subscriptionCount'];
    subscriptionExpiryDate = json['subscriptionExpiryDate'];
    subscriptionPrice = json['subscriptionPrice'];
    subscriptionStartDate = json['subscriptionStartDate'];
    subscriptionType = json['subscriptionType'];
    if (json['RecciveOrders'] != null) {
      recciveOrders = List<dynamic>.from(json['RecciveOrders']);
    }
    if (json['SendOrders'] != null) {
      sendOrders = List<dynamic>.from(json['SendOrders']);
    }
    totaltripsCompleted = json['TotaltripsCompleted'];
    isTrial = json['isTrial'];
    if (json['reviews'] != null) {
      reviews = List<dynamic>.from(json['reviews']);
    }
    totalDelivered = json['totalDelivered'];
    totalOrders = json['totalOrders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = this.email;
    if (socialLinks != null) {
      data['socialLinks'] = socialLinks!;
    }
    data['role'] = role;
    data['isVerified'] = isVerified;
    data['freeDeliveries'] = freeDeliveries;
    data['tripsCompleted'] = tripsCompleted;
    data['tripsPerDay'] = tripsPerDay;
    data['monthlyEarnings'] = monthlyEarnings;
    data['totalAmountSpent'] = totalAmountSpent;
    data['totalSentParcels'] = totalSentParcels;
    data['totalReceivedParcels'] = totalReceivedParcels;
    data['isRestricted'] = isRestricted;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['profileImage'] = profileImage;
    data['expiryDate'] = expiryDate;
    data['isSubscribed'] = isSubscribed;
    data['startDate'] = startDate;
    data['subscriptionCount'] = subscriptionCount;
    data['subscriptionExpiryDate'] = subscriptionExpiryDate;
    data['subscriptionPrice'] = subscriptionPrice;
    data['subscriptionStartDate'] = subscriptionStartDate;
    data['subscriptionType'] = subscriptionType;
    if (recciveOrders != null) {
      data['RecciveOrders'] = recciveOrders!;
    }
    if (sendOrders != null) {
      data['SendOrders'] = sendOrders!;
    }
    data['TotaltripsCompleted'] = totaltripsCompleted;
    data['isTrial'] = isTrial;
    if (reviews != null) {
      data['reviews'] = reviews!;
    }
    data['totalDelivered'] = totalDelivered;
    data['totalOrders'] = totalOrders;
    return data;
  }
}