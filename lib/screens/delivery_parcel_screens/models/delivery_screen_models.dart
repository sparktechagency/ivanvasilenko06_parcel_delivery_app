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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    if (this.deliveryParcelList != null) {
      data['data'] = this.deliveryParcelList!.map((v) => v.toJson()).toList();
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
      this.status});

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
    images = json['images'].cast<String>();
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.senderId != null) {
      data['senderId'] = this.senderId!.toJson();
    }
    if (this.pickupLocation != null) {
      data['pickupLocation'] = this.pickupLocation!.toJson();
    }
    if (this.deliveryLocation != null) {
      data['deliveryLocation'] = this.deliveryLocation!.toJson();
    }
    data['title'] = this.title;
    data['deliveryStartTime'] = this.deliveryStartTime;
    data['deliveryEndTime'] = this.deliveryEndTime;
    data['deliveryType'] = this.deliveryType;
    data['price'] = this.price;
    data['name'] = this.name;
    data['phoneNumber'] = this.phoneNumber;
    data['images'] = this.images;
    data['status'] = this.status;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['email'] = this.email;
    data['role'] = this.role;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['coordinates'] = this.coordinates;
    return data;
  }
}
