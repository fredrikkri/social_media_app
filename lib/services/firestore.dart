import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        posts.orderBy('timestamp', descending: true).snapshots();
    return postsStream;
  }

  Future<void> addPost(String title, String text, String imageUrl) {
    return posts.add({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
      'imageUrl': imageUrl,
    });
  }

  Future<void> updatePost(
      String docID, String title, String text, String imageUrl) {
    return posts.doc(docID).update({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
      'imageUrl': imageUrl,
    });
  }

  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }
}
