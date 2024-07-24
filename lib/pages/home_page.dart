import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:message_app/components/feed_posts.dart';
import 'package:message_app/pages/my_posts_page.dart';
import 'package:message_app/services/firestore.dart';
import 'package:message_app/services/upload_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestoreService = FirestoreService();
  final titlePostController = TextEditingController();
  final textPostController = TextEditingController();

  Future<User?> _getCurrentUser() async {
    // Get the current user
    return FirebaseAuth.instance.currentUser;
  }

  void openPostBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              TextField(
                controller: titlePostController,
                decoration: const InputDecoration(
                  hintText: 'Enter title',
                ),
              ),
              TextField(
                controller: textPostController,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                ),
              ),
            ],
          ),
        ),
        actions: [
          // button to save
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                createThePost();
              } else {
                updateThePost(docID);
              }
              // titlePostController.clear();
              // textPostController.clear();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<void> createThePost() async {
    final pickedFile = await const UploadImageService().pickImage();
    final currUser = await _getCurrentUser();
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final imageUrl = await const UploadImageService().uploadImage(imageFile);
      await firestoreService.addPost(
          titlePostController.text,
          textPostController.text,
          imageUrl.toString(),
          currUser?.email ?? 'undefined');
    } else {
      print('No image selected.');
    }
    titlePostController.clear();
    textPostController.clear();
  }

  Future<void> updateThePost(String docID) async {
    final pickedFile = await const UploadImageService().pickImage();
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final imageUrl = await const UploadImageService().uploadImage(imageFile);
      await firestoreService.updatePost(docID, titlePostController.text,
          textPostController.text, imageUrl.toString());
    } else {
      print('No image selected.');
    }
    titlePostController.clear();
    textPostController.clear();
  }

  Widget getCurrentUserEmailTextWidget() {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          User? user = snapshot.data;
          return Text(
            user?.email ?? 'No user signed in',
            style: const TextStyle(fontSize: 20, color: Colors.blue),
          );
        } else {
          return const Text('No user signed in');
        }
      },
    );
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "MessageApp",
          style: TextStyle(color: Colors.blue),
        ),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          // sign out button
          IconButton(
            onPressed: signOut,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openPostBox,
        child: const Icon(Icons.add),
      ),
      body: FeedPosts(firestoreService: firestoreService),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 77, 103, 125),
                Color.fromARGB(255, 122, 67, 132),
                Color.fromARGB(255, 179, 131, 188)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Colors.white),
                title:
                    const Text('Home', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.content_copy_sharp, color: Colors.white),
                title: const Text('My Posts',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPostsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Current User:',
                      style:
                          TextStyle(color: Color.fromARGB(126, 241, 241, 241)),
                    ),
                    getCurrentUserEmailTextWidget(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
