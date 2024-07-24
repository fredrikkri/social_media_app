import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:message_app/services/firestore.dart';

class FeedPosts extends StatelessWidget {
  const FeedPosts({
    super.key,
    required this.firestoreService,
  });

  final FirestoreService firestoreService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List postsList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: postsList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = postsList[index];
              //String docID = document.id;
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String postTitle = data['title'];
              String postText = data['text'];
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          // Favorite button
                          IconButton(
                            //padding: const EdgeInsets.only(top: 15, right: 15),
                            onPressed: () {},
                            icon: const Icon(
                              Icons.favorite,
                              size: 30,
                            ),
                          ),
                          // updatebutton
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
        } else {
          return const Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.purple,
          ));
        }
      },
    );
  }
}
