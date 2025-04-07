class Sender {
  final String id;
  final String fullName;
  final String email;
  final String role;

  Sender({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  factory Sender.fromJson(Map<String, dynamic> json) {
    return Sender(
      id: json["_id"] ?? '',
      fullName: json["fullName"] ?? '',
      email: json["email"] ?? '',
      role: json["role"] ?? '',
    );
  }
}

class Parcel {
  final String id;
  final Sender sender;
  final String pickupLocation;
  final String deliveryLocation;
  final String deliveryType;
  final String status;
  final List<String> images;
  final String? title;
  final String? name;
  final String? phoneNumber;
  final String? deliveryStartTime;
  final String? deliveryEndTime;

  Parcel({
    required this.id,
    required this.sender,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.deliveryType,
    required this.status,
    required this.images,
    this.title,
    this.name,
    this.phoneNumber,
    this.deliveryStartTime,
    this.deliveryEndTime,
  });

  factory Parcel.fromJson(Map<String, dynamic> json) {
    return Parcel(
      id: json["_id"] ?? '',
      sender: Sender.fromJson(json["senderId"]),
      pickupLocation: json["pickupLocation"] ?? '',
      deliveryLocation: json["deliveryLocation"] ?? '',
      deliveryType: json["deliveryType"] ?? '',
      status: json["status"] ?? '',
      images: List<String>.from(json["images"] ?? []),
      title: json["title"],
      name: json["name"],
      phoneNumber: json["phoneNumber"],
      deliveryStartTime: json["deliveryStartTime"],
      deliveryEndTime: json["deliveryEndTime"],
    );
  }
}
