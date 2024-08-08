import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/firestore_post.dart';

class UserPage extends StatefulWidget {
  final String email;

  const UserPage({super.key, required this.email});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final firestoreService = FirestorePostService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.email,
          style: const TextStyle(color: Colors.blue),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getPostsStreamByEmail(widget.email),
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
          } else {
            return const Center(
                child: CircularProgressIndicator(
              backgroundColor: Colors.purple,
            ));
          }
        },
      ),
    );
  }
}
