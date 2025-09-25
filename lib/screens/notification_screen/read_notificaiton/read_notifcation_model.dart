import 'dart:convert';

class ReadingNotificaitonModel {
  String? status;
  Data? data;

  ReadingNotificaitonModel({
    this.status,
    this.data,
  });

  factory ReadingNotificaitonModel.fromRawJson(String str) =>
      ReadingNotificaitonModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory ReadingNotificaitonModel.fromJson(Map<String, dynamic> json) =>
      ReadingNotificaitonModel(
        status: json["status"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": data?.toJson(),
      };
}

class Data {
  int? unreadCount; // Change from double? to int?

  Data({
    this.unreadCount,
  });

  factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        unreadCount: json["unreadCount"]?.toInt(), // Convert to int
      );

  Map<String, dynamic> toJson() => {
        "unreadCount": unreadCount,
      };
}
