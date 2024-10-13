import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/varibles.dart';
import 'package:flutter_mongo_lab1/models/post_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PostController {
  final _authController = AuthController();
  static int retryCount = 0; // นับจำนวนการพยายามรีเฟรช token

  Future<List<PostModel>> getPosts(BuildContext context) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$apiURL/api/posts'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken", // ใส่ accessToken ใน header
        },
      );

      if (response.statusCode == 200) {
        // Decode the response and map it to PostModel objects
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((post) => PostModel.fromJson(post))
            .toList();
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Wrong Token. Please login again.');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        // Refresh token and retry
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;

        return await getPosts(context);
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token expired. Please login again.');
      } else {
        throw Exception('Failed to load posts with status code: ${response.statusCode}');
      }
    } catch (err) {
      throw Exception('Failed to load posts: $err');
    }
  }

  Future<void> insertPost(BuildContext context, String title, String content,
      String address, String tel, String message, DateTime date) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    final Map<String, dynamic> insertData = {
      "title": title,
      "content": content,
      "address": address,
      "tel": tel,
      "message": message,
      "date": date.toIso8601String(),
    };

    try {
      // Make POST request to insert the post
      final response = await http.post(
        Uri.parse("$apiURL/api/post"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(insertData), // แก้ชื่อให้ถูกต้อง
      );

      // Handle successful post insertion
      if (response.statusCode == 201) {
        print("Post inserted successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Wrong Token. Please login again.');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken; // Update the accessToken after refresh
        retryCount++;

        return await insertPost(context, title, content, address, tel, message, date); // แก้ชื่อให้ถูกต้อง
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token expired. Please login again.');
      } else {
        print("Failed to insert post. Status code: ${response.statusCode}");
        throw Exception('Failed to insert post. Server response: ${response.body}');
      }
    } catch (error) {
      print('Error inserting post: $error');
      throw Exception('Failed to insert post due to error: $error');
    }
  }

  Future<void> updatePost(BuildContext context, String postId,
      String title, String content, String address, String tel, String message, DateTime date) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    final Map<String, dynamic> updateData = {
      "title": title,
      "content": content,
      "address": address,
      "tel": tel,
      "message": message,
      "date": date.toIso8601String(), // แปลง date เป็น ISO string
    };

    try {
      // Send PUT request to update the post
      final response = await http.put(
        Uri.parse("$apiURL/api/post/$postId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
        body: jsonEncode(updateData),
      );

      // Handle successful post update
      if (response.statusCode == 200) {
        print("Post updated successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Wrong Token. Please login again.');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken; // Update the accessToken after refresh
        retryCount++;

        return await updatePost(context, postId, title, content, address, tel, message, date); // แก้ชื่อให้ถูกต้อง
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token expired. Please login again.');
      } else {
        print("Failed to update post. Status code: ${response.statusCode}");
        throw Exception('Failed to update post. Server response: ${response.body}');
      }
    } catch (error) {
      print('Error updating post: $error');
      throw Exception('Failed to update post due to error: $error');
    }
  }

  Future<void> deletePost(BuildContext context, String postId) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    var accessToken = userProvider.accessToken;

    try {
      final response = await http.delete(
        Uri.parse("$apiURL/api/post/$postId"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken"
        },
      );

      if (response.statusCode == 200) {
        print("Post deleted successfully!");
      } else if (response.statusCode == 401) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Wrong Token. Please login again.');
      } else if (response.statusCode == 403 && retryCount <= 1) {
        print("Access token expired. Refreshing token...");

        // Refresh the accessToken
        await _authController.refreshToken(context);
        accessToken = userProvider.accessToken;
        retryCount++;

        return await deletePost(context, postId); // เรียกซ้ำ deletePost หลัง refresh token
      } else if (response.statusCode == 403 && retryCount > 1) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        throw Exception('Token expired. Please login again.');
      } else {
        print("Failed to delete post. Status code: ${response.statusCode}");
        throw Exception('Failed to delete post. Server response: ${response.body}');
      }
    } catch (error) {
      print('Error deleting post: $error');
      throw Exception('Failed to delete post due to error: $error');
    }
  }
}
