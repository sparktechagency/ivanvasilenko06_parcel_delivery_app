class DeliverParcelModel {
  String? status;
  List<DeliverParcelList>? deliveryParcelList;

  DeliverParcelModel({this.status, this.deliveryParcelList});

  DeliverParcelModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      deliveryParcelList = <DeliverParcelList>[];
      json['data'].forEach((v) {
        deliveryParcelList!.add(new DeliverParcelList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (deliveryParcelList != null) {
      data['data'] = deliveryParcelList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliverParcelList {
  String? sId;
  SenderId? senderId;
  PickupLocation? pickupLocation;
  PickupLocation? deliveryLocation;
  String? title;
  String? deliveryStartTime;
  String? deliveryEndTime;
  String? deliveryType;
  int? price;
  String? name;
  String? phoneNumber;
  List<String>? images;
  String? status;
  String? description; // Added the description field

  DeliverParcelList(
      {this.sId,
      this.senderId,
      this.pickupLocation,
      this.deliveryLocation,
      this.title,
      this.deliveryStartTime,
      this.deliveryEndTime,
      this.deliveryType,
      this.price,
      this.name,
      this.phoneNumber,
      this.images,
      this.status,
      this.description}); // Added description to the constructor

  DeliverParcelList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    senderId = json['senderId'] != null
        ? new SenderId.fromJson(json['senderId'])
        : null;
    pickupLocation = json['pickupLocation'] != null
        ? new PickupLocation.fromJson(json['pickupLocation'])
        : null;
    deliveryLocation = json['deliveryLocation'] != null
        ? new PickupLocation.fromJson(json['deliveryLocation'])
        : null;
    title = json['title'];
    deliveryStartTime = json['deliveryStartTime'];
    deliveryEndTime = json['deliveryEndTime'];
    deliveryType = json['deliveryType'];
    price = json['price'];
    name = json['name'];
    phoneNumber = json['phoneNumber'];
    images = json['images']?.cast<String>();
    status = json['status'];
    description = json['description']; // Added description field mapping
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (senderId != null) {
      data['senderId'] = senderId!.toJson();
    }
    if (pickupLocation != null) {
      data['pickupLocation'] = pickupLocation!.toJson();
    }
    if (deliveryLocation != null) {
      data['deliveryLocation'] = deliveryLocation!.toJson();
    }
    data['title'] = title;
    data['deliveryStartTime'] = deliveryStartTime;
    data['deliveryEndTime'] = deliveryEndTime;
    data['deliveryType'] = deliveryType;
    data['price'] = price;
    data['name'] = name;
    data['phoneNumber'] = phoneNumber;
    data['images'] = images;
    data['status'] = status;
    data['description'] =
        description; // Added description field to the JSON output
    return data;
  }
}

class SenderId {
  String? sId;
  String? fullName;
  String? email;
  String? role;

  SenderId({this.sId, this.fullName, this.email, this.role});

  SenderId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'];
    email = json['email'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['fullName'] = fullName;
    data['email'] = email;
    data['role'] = role;
    return data;
  }
}

class PickupLocation {
  String? type;
  List<double>? coordinates;

  PickupLocation({this.type, this.coordinates});

  PickupLocation.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    coordinates = json['coordinates'].cast<double>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['coordinates'] = coordinates;
    return data;
  }
}
