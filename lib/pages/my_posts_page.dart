import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:message_app/pages/home_page.dart';

import 'package:message_app/services/firestore.dart';
import 'package:message_app/services/upload_image.dart';

class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});
  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openPostBox,
        child: const Icon(Icons.add),
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
                // A Post
                return Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 233, 233, 233)),
                      height: 400,
                      width: double.infinity,
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
                            // Favorite button
                            IconButton(
                              //padding: const EdgeInsets.only(top: 15, right: 15),
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
                            // updatebutton
                            IconButton(
                                //padding: const EdgeInsets.only(top: 15, right: 15),
                                onPressed: () => openPostBox(docID: docID),
                                icon: const Icon(Icons.settings)),

                            // deletebutton
                            IconButton(
                              //padding: const EdgeInsets.only(top: 15, right: 15),
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
                              child: Flexible(
                                //padding: const EdgeInsets.only(left: 10, top: 5),
                                child: Text(postText),
                              ),
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
                child: CircularProgressIndicator(
              backgroundColor: Colors.purple,
            ));
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
