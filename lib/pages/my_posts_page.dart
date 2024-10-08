import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:message_app/pages/following_page.dart';
import 'package:message_app/pages/home_page.dart';
import 'package:message_app/pages/profile_page.dart';

import 'package:message_app/services/firestore_post.dart';
import 'package:message_app/services/upload_image.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});
  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  final firestoreService = FirestorePostService();
  final titlePostController = TextEditingController();
  final textPostController = TextEditingController();

  Future<User?> _getCurrentUser() async {
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
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                createThePost();
              } else {
                updateThePost(docID);
              }
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
      await firestoreService.addPost(titlePostController.text,
          textPostController.text, imageUrl, currUser?.email ?? 'undefined');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "My Posts",
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
          IconButton(onPressed: openPostBox, icon: const Icon(Icons.add))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStreamCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List postsList = snapshot.data!.docs;
            return ListView.builder(
              itemCount: postsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = postsList[index];
                String docID = document.id;
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String postTitle = data['title'];
                String postText = data['text'];
                List<String> likedBy = List<String>.from(data['likedBy'] ?? []);
                bool isLiked =
                    likedBy.contains(FirebaseAuth.instance.currentUser?.email);
                return Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233)),
                      height: 400,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data['createdBy']}',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                postTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => firestoreService.likePost(docID),
                              icon: Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('${likedBy.length} likes'),
                            ),
                            IconButton(
                                onPressed: () => openPostBox(docID: docID),
                                icon: const Icon(Icons.settings)),
                            IconButton(
                              onPressed: () =>
                                  firestoreService.deletePost(docID),
                              icon: const Icon(
                                Icons.delete,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(postText),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(
                child: Text(
                    'You have no posts. Click the button (+) in the top right corner to create a post.'));
          }
        },
      ),
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
                    'SocialApp',
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.content_copy_sharp, color: Colors.white),
                title: const Text('My Posts',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.emoji_people, color: Colors.white),
                title: const Text('Following',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FollowingPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Profile',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
