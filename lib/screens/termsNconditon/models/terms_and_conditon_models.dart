import 'dart:convert';

class TermsAndConditonModel {
    bool? success;
    String? message;
    Data? data;

    TermsAndConditonModel({
        this.success,
        this.message,
        this.data,
    });

    factory TermsAndConditonModel.fromRawJson(String str) => TermsAndConditonModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory TermsAndConditonModel.fromJson(Map<String, dynamic> json) => TermsAndConditonModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
    };
}

class Data {
    String? id;
    String? content;
    int? v;

    Data({
        this.id,
        this.content,
        this.v,
    });

    factory Data.fromRawJson(String str) => Data.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["_id"],
        content: json["content"],
        v: json["__v"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "content": content,
        "__v": v,
    };
}
