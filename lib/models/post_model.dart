import 'dart:convert';

// ฟังก์ชันเพื่อแปลง JSON เป็น PostModel
PostModel postModelFromJson(String str) => PostModel.fromJson(json.decode(str));

// ฟังก์ชันเพื่อแปลง PostModel เป็น JSON
String postModelToJson(PostModel data) => json.encode(data.toJson());

class PostModel {
  String id;
  String title;
  String content;
  String address;
  String tel;
  String message;
  DateTime date;

  PostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.address,
    required this.tel,
    required this.message,
    required this.date,
  });

  // ฟังก์ชันเพื่อสร้าง PostModel จาก JSON
  factory PostModel.fromJson(Map<String, dynamic> json) => PostModel(
        id: json["_id"],
        title: json["title"],
        content: json["content"],
        address: json["address"],
        tel: json["tel"],
        message: json["message"],
        date: DateTime.parse(json["date"]), // แปลงค่า date เป็น DateTime
      );

  // ฟังก์ชันเพื่อแปลง PostModel เป็น JSON
  Map<String, dynamic> toJson() => {
        "_id": id,
        "title": title,
        "content": content,
        "address": address,
        "tel": tel,
        "message": message,
        "date": date.toIso8601String(), // แปลง DateTime เป็น ISO 8601 string
      };
}
