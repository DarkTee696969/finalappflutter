import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mongo_lab1/Page/EditPostPage.dart';
import 'dart:math';
import 'package:flutter_mongo_lab1/Widget/customCliper.dart';
import 'package:flutter_mongo_lab1/controllers/auth_controller.dart';
import 'package:flutter_mongo_lab1/models/user_model.dart';
import 'package:flutter_mongo_lab1/providers/user_provider.dart';
import 'package:flutter_mongo_lab1/models/post_model.dart';
import 'package:flutter_mongo_lab1/controllers/post_controller.dart';
import 'package:provider/provider.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  List<PostModel> posts = []; 
  List<PostModel> filteredPosts = []; // เพิ่มตัวแปรนี้
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = ''; // ตัวแปรสำหรับคำค้นหา

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันการออกจากระบบ'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('ออกจากระบบ'),
              onPressed: () {
                Provider.of<UserProvider>(context, listen: false).onLogout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchPosts() async {
    try {
      final postList = await PostController().getPosts(context);
      setState(() {
        posts = postList; 
        filteredPosts = postList; // กำหนดค่าให้ filteredPosts เริ่มต้นเท่ากับ posts
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = 'Error fetching posts: $error';
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching posts: $error')));
    }
  }

  void _filterPosts(String query) {
    setState(() {
      searchQuery = query;
      filteredPosts = posts.where((post) {
        return post.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void updatePost(PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPostPage(post: post),
      ),
    );
  }

  Future<void> deletePost(PostModel post) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ยืนยันโพสต์'),
          content: const Text('คุณแน่ใจหรือไม่ว่าต้องการลบโพสต์นี้?'),
          actions: <Widget>[
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('ลบ'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        await PostController().deletePost(context, post.id);
        await _fetchPosts();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ลบโพสต์สำเร็จ')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting post: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        height: height,
        child: Stack(
          children: [
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xffE9EFEC),
                          Color(0xffFABC3F),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: height * .1),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        text: 'จัดการ',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                          color: Color(0xffC7253E),
                        ),
                        children: [
                          TextSpan(
                            text: 'โพสต์',
                            style: TextStyle(color: Color(0xffE85C0D), fontSize: 35),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),

                    // เพิ่ม TextField สำหรับการค้นหา
                    TextField(
                      onChanged: _filterPosts,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาตามชื่อโพสต์...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_post');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // ขอบมน
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15), // ขนาดปุ่ม
                      ),
                      child: Text(
                        'เพิ่มโพสต์ใหม่',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (isLoading)
                      CircularProgressIndicator()
                    else if (errorMessage != null)
                      Text(errorMessage!, style: TextStyle(color: Colors.red, fontSize: 16))
                    else
                      _buildPostList(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50.0,
              right: 16.0,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  _showLogoutConfirmationDialog(context);
                },
                child: Icon(
                  Icons.logout,
                  color: Color(0xff821131),
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: filteredPosts.length, // เปลี่ยนจาก posts เป็น filteredPosts
      itemBuilder: (context, index) {
        final post = filteredPosts[index]; // เปลี่ยนจาก posts เป็น filteredPosts
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xffC7253E)),
                      ),
                      SizedBox(height: 8),
                      Text('เนื้อหา: ${post.content}', style: TextStyle(fontSize: 14)),
                      Text('ที่อยู่: ${post.address}', style: TextStyle(fontSize: 14)),
                      Text('เบอร์โทร: ${post.tel}', style: TextStyle(fontSize: 14)),
                      Text('ข้อความ: ${post.message}', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Color(0xffFABC3F)),
                  onPressed: () {
                    updatePost(post);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Color(0xff821131)),
                  onPressed: () {
                    deletePost(post);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }  
}
