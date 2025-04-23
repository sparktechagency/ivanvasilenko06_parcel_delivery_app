class ServiceScreenModel {
  String? status;
  List<ServiceScreenDataList>? serviceScreenDataList;

  ServiceScreenModel({this.status, this.serviceScreenDataList});

  ServiceScreenModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      serviceScreenDataList = <ServiceScreenDataList>[];
      json['data'].forEach((v) {
        serviceScreenDataList!.add(ServiceScreenDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    if (this.serviceScreenDataList != null) {
      data['data'] =
          this.serviceScreenDataList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceScreenDataList {
  PickupLocation? pickupLocation;
  PickupLocation? deliveryLocation;
  String? sId;
  SenderId? senderId;
  String? title;
  String? deliveryType;
  String? senderType;
  String? name;
  String? phoneNumber;
  List<String>? images;
  String? status;
  List<DeliveryRequest>? deliveryRequests;
  String? createdAt;
  String? updatedAt;

  ServiceScreenDataList({
    this.pickupLocation,
    this.deliveryLocation,
    this.sId,
    this.senderId,
    this.title,
    this.deliveryType,
    this.senderType,
    this.name,
    this.phoneNumber,
    this.images,
    this.status,
    this.deliveryRequests,
    this.createdAt,
    this.updatedAt,
  });

  ServiceScreenDataList.fromJson(Map<String, dynamic> json) {
    pickupLocation = json['pickupLocation'] != null
        ? PickupLocation.fromJson(json['pickupLocation'])
        : null;
    deliveryLocation = json['deliveryLocation'] != null
        ? PickupLocation.fromJson(json['deliveryLocation'])
        : null;
    sId = json['_id'];
    senderId =
        json['senderId'] != null ? SenderId.fromJson(json['senderId']) : null;
    title = json['title'];
    deliveryType = json['deliveryType'];
    senderType = json['senderType'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    images = json['images']?.cast<String>();
    status = json['status'];
    if (json['deliveryRequests'] != null) {
      deliveryRequests = <DeliveryRequest>[];
      json['deliveryRequests'].forEach((v) {
        deliveryRequests!.add(
            DeliveryRequest.fromJson(v)); // Assuming DeliveryRequest is a class
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pickupLocation != null) {
      data['pickupLocation'] = pickupLocation!.toJson();
    }
    if (deliveryLocation != null) {
      data['deliveryLocation'] = deliveryLocation!.toJson();
    }
    data['_id'] = sId;
    if (senderId != null) {
      data['senderId'] = senderId!.toJson();
    }
    data['title'] = title;
    data['deliveryType'] = deliveryType;
    data['senderType'] = senderType;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['images'] = images;
    data['status'] = status;
    if (deliveryRequests != null) {
      data['deliveryRequests'] =
          deliveryRequests!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }
}

class PickupLocation {
  String? type;
  List<double>? coordinates;

  PickupLocation({this.type, this.coordinates});

  PickupLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates']?.cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}

class SenderId {
  String? sId;
  String? fullName;
  String? email;
  String? role;
  String? profileImage;

  SenderId({this.sId, this.fullName, this.email, this.role, this.profileImage});

  SenderId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    role = json['role'];
    profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['role'] = role;
    data['profileImage'] = profileImage;
    return data;
  }
}

// Example DeliveryRequest class
class DeliveryRequest {
  String? requestId;
  String? status;

  DeliveryRequest({this.requestId, this.status});

  DeliveryRequest.fromJson(Map<String, dynamic> json) {
    requestId = json['requestId'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['requestId'] = requestId;
    data['status'] = status;
    return data;
  }
}
