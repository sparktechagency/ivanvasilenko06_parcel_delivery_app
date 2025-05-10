class NotificationModel {
  String? status;
  Data? data;

  NotificationModel({this.status, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  List<Notifications>? notifications;
  Pagination? pagination;

  Data({this.notifications, this.pagination});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['notifications'] != null) {
      notifications = <Notifications>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notifications.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    if (pagination != null) {
      data['pagination'] = pagination!.toJson();
    }
    return data;
  }
}

class Notifications {
  String? sId;
  String? userId;
  String? message;
  String? type;
  String? title;
  String? phoneNumber;
  String? mobileNumber;
  String? image;
  String? name;
  int? price;
  int? avgRating;
  String? description;
  bool? isRead;
  String? createdAt;
  int? iV;
  Location? pickupLocation;
  Location? deliveryLocation;

  Notifications(
      {this.sId,
      this.userId,
      this.message,
      this.type,
      this.title,
      this.phoneNumber,
      this.mobileNumber,
      this.image,
      this.price,
      this.avgRating,
      this.description,
      this.isRead,
      this.createdAt,
      this.name,
      this.pickupLocation,
      this.deliveryLocation,
      this.iV});

  Notifications.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    message = json['message'];
    type = json['type'];
    title = json['title'];
    phoneNumber = json['phoneNumber'];
    mobileNumber = json['mobileNumber'];
    image = json['image'];
    name = json['name'];
    price = json['price'];
    avgRating = json['AvgRating'];
    description = json['description'];
    isRead = json['isRead'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    pickupLocation = json['pickupLocation'] != null
        ? Location.fromJson(json['pickupLocation'])
        : null;
    deliveryLocation = json['deliveryLocation'] != null
        ? Location.fromJson(json['deliveryLocation'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['userId'] = userId;
    data['message'] = message;
    data['type'] = type;
    data['name'] = name;
    data['title'] = title;
    data['phoneNumber'] = phoneNumber;
    data['mobileNumber'] = mobileNumber;
    data['image'] = image;
    data['price'] = price;
    data['AvgRating'] = avgRating;
    data['description'] = description;
    data['isRead'] = isRead;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    if (pickupLocation != null) {
      data['pickupLocation'] = pickupLocation!.toJson();
    }
    if (deliveryLocation != null) {
      data['deliveryLocation'] = deliveryLocation!.toJson();
    }
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;
  String? sId;

  Location({this.latitude, this.longitude, this.sId});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'] is int
        ? (json['latitude'] as int).toDouble()
        : json['latitude'];
    longitude = json['longitude'] is int
        ? (json['longitude'] as int).toDouble()
        : json['longitude'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['_id'] = sId;
    return data;
  }
}

class Pagination {
  int? total;
  int? page;
  int? limit;
  int? pages;

  Pagination({this.total, this.page, this.limit, this.pages});

  Pagination.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    limit = json['limit'];
    pages = json['pages'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['page'] = page;
    data['limit'] = limit;
    data['pages'] = pages;
    return data;
  }
}
