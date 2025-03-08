class ProfileModel {
  String? status;
  String? message;
  Data? data;

  ProfileModel({this.status, this.message, this.data});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
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

class Data {
  String? sId;
  String? fullName;
  String? email;
  List<dynamic>? socialLinks; // Changed from List<Null> to List<dynamic>
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
  String? facebook;
  String? instagram;
  String? whatsapp;

  Data({
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
    this.facebook,
    this.instagram,
    this.whatsapp,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    socialLinks = json['socialLinks'] != null ? List<dynamic>.from(json['socialLinks']) : null; // Corrected handling of socialLinks
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
    facebook = json['facebook'];
    instagram = json['instagram'];
    whatsapp = json['whatsapp'];
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
    data['facebook'] = facebook;
    data['instagram'] = instagram;
    data['whatsapp'] = whatsapp;
    return data;
  }
}