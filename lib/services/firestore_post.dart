import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestorePostService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  Stream<QuerySnapshot> getPostsStream() {
    final postsStream =
        posts.orderBy('timestamp', descending: true).snapshots();
    return postsStream;
  }

  Stream<QuerySnapshot> getPostsStreamByEmail(String email) {
    final postsStream = posts
        .where('createdBy', isEqualTo: email)
        .orderBy('timestamp', descending: true)
        .snapshots();
    return postsStream;
  }

  Stream<QuerySnapshot> getPostsStreamCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    String currentUserEmail = user.email!;

    final postsStream = posts
        .where('createdBy', isEqualTo: currentUserEmail)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .handleError((error) {
      print('Feil ved henting av data: $error');
    });

    return postsStream;
  }

  Future<void> addPost(
      String title, String text, String imageUrl, String user) {
    return posts.add({
      'title': title,
      'timestamp': Timestamp.now(),
      'text': text,
      'imageUrl': imageUrl,
      'createdBy': user,
      'likedBy': [],
    });
  }

  Future<void> updatePost(
      String docID, String? title, String? text, String? imageUrl) {
    Map<String, dynamic> updateData = {
      'timestamp': Timestamp.now(),
    };

    if (title != null && title.isNotEmpty) {
      updateData['title'] = title;
    }
    if (text != null && text.isNotEmpty) {
      updateData['text'] = text;
    }
    if (imageUrl != null && imageUrl.isNotEmpty) {
      updateData['imageUrl'] = imageUrl;
    }

    return posts.doc(docID).update(updateData);
  }

  Future<void> deletePost(String docID) {
    return posts.doc(docID).delete();
  }

  Future<void> likePost(String postId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String userEmail = user.email!;
    DocumentReference postRef = posts.doc(postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception("Post does not exist!");
      }

      List<String> likedBy = List<String>.from(snapshot['likedBy'] ?? []);
      if (likedBy.contains(userEmail)) {
        likedBy.remove(userEmail);
      } else {
        likedBy.add(userEmail);
      }

      transaction.update(postRef, {'likedBy': likedBy});
    });
  }
}
