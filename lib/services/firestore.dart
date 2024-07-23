import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  Future<void> addPost(String title, String text) {
    return posts.add({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
    });
  }

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        posts.orderBy('timestamp', descending: true).snapshots();
    return postsStream;
  }

  Future<void> updatePost(String docID, String title, String text) {
    return posts.doc(docID).update({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
    });
  }

  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }
}
