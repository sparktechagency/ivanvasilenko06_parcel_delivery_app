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
  UserData? user;
  EarningsData? earnings;

  ProfileData({this.user, this.earnings});

  ProfileData.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserData.fromJson(json['user']) : null;
    earnings = json['earnings'] != null
        ? EarningsData.fromJson(json['earnings'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (earnings != null) {
      data['earnings'] = earnings!.toJson();
    }
    return data;
  }
}

class UserData {
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
  List<Review>? reviews;
  int? totalDelivered;
  int? totalOrders;

  UserData(
      {this.sId,
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
      this.totalOrders});

  UserData.fromJson(Map<String, dynamic> json) {
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
      reviews = <Review>[];
      json['reviews'].forEach((v) {
        reviews!.add(Review.fromJson(v));
      });
    }
    totalDelivered = json['totalDelivered'];
    totalOrders = json['totalOrders'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
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
      data['reviews'] = reviews!.map((v) => v.toJson()).toList();
    }
    data['totalDelivered'] = totalDelivered;
    data['totalOrders'] = totalOrders;
    return data;
  }
}

class Review {
  String? parcelId;
  int? rating;
  String? review;
  String? id;

  Review({this.parcelId, this.rating, this.review, this.id});

  Review.fromJson(Map<String, dynamic> json) {
    parcelId = json['parcelId'];
    rating = json['rating'];
    review = json['review'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['parcelId'] = parcelId;
    data['rating'] = rating;
    data['review'] = review;
    data['_id'] = id;
    return data;
  }
}

class EarningsData {
  int? totalEarnings;
  int? monthlyEarnings;
  int? totalAmountSpent;
  int? totalSentParcels;
  int? totalReceivedParcels;

  EarningsData({
    this.totalEarnings,
    this.monthlyEarnings,
    this.totalAmountSpent,
    this.totalSentParcels,
    this.totalReceivedParcels,
  });

  EarningsData.fromJson(Map<String, dynamic> json) {
    totalEarnings = json['totalEarnings'];
    monthlyEarnings = json['monthlyEarnings'];
    totalAmountSpent = json['totalAmountSpent'];
    totalSentParcels = json['totalSentParcels'];
    totalReceivedParcels = json['totalReceivedParcels'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalEarnings'] = totalEarnings;
    data['monthlyEarnings'] = monthlyEarnings;
    data['totalAmountSpent'] = totalAmountSpent;
    data['totalSentParcels'] = totalSentParcels;
    data['totalReceivedParcels'] = totalReceivedParcels;
    return data;
  }
}
