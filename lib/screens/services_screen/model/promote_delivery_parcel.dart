import 'dart:convert';

class DeliveryPromote {
  List<dynamic>? images;
  String? id;
  String? senderId;
  String? pickupLocation;
  String? deliveryLocation;
  String? deliveryTime;
  String? deliveryType;
  String? senderType;
  String? status;
  List<dynamic>? deliveryRequests;
  String? createdAt;
  String? updatedAt;
  dynamic v;

  DeliveryPromote({
    this.images,
    this.id,
    this.senderId,
    this.pickupLocation,
    this.deliveryLocation,
    this.deliveryTime,
    this.deliveryType,
    this.senderType,
    this.status,
    this.deliveryRequests,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DeliveryPromote.fromRawJson(String str) => DeliveryPromote.fromJson(json.decode(str));


  factory DeliveryPromote.fromJson(Map<String, dynamic> json) => DeliveryPromote(
    images: json["images"] == null ? [] : List<dynamic>.from(json["images"]!.map((x) => x)),
    id: json["_id"],
    senderId: json["senderId"],
    pickupLocation: json["pickupLocation"],
    deliveryLocation: json["deliveryLocation"],
    deliveryTime: json["deliveryTime"],
    deliveryType: json["deliveryType"],
    senderType: json["senderType"],
    status: json["status"],
    deliveryRequests: json["deliveryRequests"] == null ? [] : List<dynamic>.from(json["deliveryRequests"]!.map((x) => x)),
    createdAt: json["createdAt"] ,
    updatedAt: json["updatedAt"] ,
    v: json["__v"],
  );


}
