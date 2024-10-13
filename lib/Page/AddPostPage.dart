import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart'; // Assuming you already have customClipper
import 'package:flutter_mongo_lab1/controllers/post_controller.dart';

class AddPostPage extends StatefulWidget {
  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _formKey = GlobalKey<FormState>();
  final PostController _postController = PostController(); // Create PostController instance
  String title = '';
  String content = '';
  String address = '';
  String tel = '';
  String message = '';
  DateTime date = DateTime.now();

  // Separate function to add a new post
  void _addNewPost() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save new post data by calling insertPost function
      _postController.insertPost(
        context,
        title,
        content,
        address,
        tel,
        message,
        date,
      ).then((_) {
        // Success action here (e.g. navigate back or show success message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เพิ่มสินค้าเรียบร้อยแล้ว')),
        );
        Navigator.pushReplacementNamed(context, '/admin');
      }).catchError((error) {
        // Check if the error is due to expired token
        if (error.toString().contains('401')) {
          // Token expired, redirect to login
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token หมดอายุแล้ว กรุณา login ใหม่')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        } else {
          // Error action here (e.g. show error message)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เกิดข้อผิดพลาด: $error')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffE9EFEC), Color(0xffFABC3F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Background Shape
            Positioned(
              top: -height * .15,
              right: -width * .4,
              child: Transform.rotate(
                angle: -pi / 3.5,
                child: ClipPath(
                  clipper: ClipPainter(),
                  child: Container(
                    height: height * .5,
                    width: width,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
            // Form content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'เพิ่ม',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'โพสต์ใหม่',
                            style: TextStyle(color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          _buildTextField(
                            label: 'ชื่อเรื่อง',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกชื่อเรื่อง';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              title = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'เนื้อหา',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเนื้อหา';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              content = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'ที่อยู่',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกที่อยู่';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              address = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'เบอร์โทร',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกเบอร์โทร';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              tel = value!;
                            },
                          ),
                          SizedBox(height: 16),
                          _buildTextField(
                            label: 'ข้อความ',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'กรุณากรอกข้อความ';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              message = value!;
                            },
                          ),
                          SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _addNewPost,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xffC7253E),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'บันทึก',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/admin'); // เปลี่ยนไปยังหน้าแสดงสินค้า
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromRGBO(103, 103, 103, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                                  child: Text(
                                    'ยกเลิก',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    TextInputType? keyboardType,
    required FormFieldValidator<String> validator,
    required FormFieldSetter<String> onSaved,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2), // Shadow position
          ),
        ],
      ),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
