import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:babmbino/models/post.dart';
import 'package:babmbino/resources/storage_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<String> uploadPost(String description, Uint8List file, String uid,
      String username, String profImage, String story, List multibleStories, List multiblePics, String privacy, String isSaved) async {
    // asking uid here because we dont want to make extra calls to firebase auth when we can just get from our state management
    String res = "Some error occurred";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);
      String postId = const Uuid().v1(); // creates unique id based on time
      Post post = Post(
        body: story,
        story: multibleStories,
        title: description,
        uid: uid,
        username: username,
        likes: [],
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        photos: multiblePics,
        ranking: 0,
          commentLen: 0,
        privacy: privacy,
        isSaved: isSaved
      );
      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        // if the likes list contains the user uid, we need to remove it
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
        _firestore.collection('posts').doc(postId).update({
          'ranking': likes.length -1
        });
      } else {
        // else we need to add uid to the likes array
        _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
        _firestore.collection('posts').doc(postId).update({
          'ranking': likes.length +1
        });
      }
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Post comment
  Future<String> postComment(String postId, String text, String uid,
      String name, String profilePic) async {
    AggregateQuerySnapshot query = await _firestore.collection('posts').doc(postId).collection('comments').count().get();
    String res = "Some error occurred";
    try {
      if (text.isNotEmpty) {
        // if the likes list contains the user uid, we need to remove it
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        res = 'success';
      } else {
        res = "Please enter text";
      }
      _firestore.collection('posts').doc(postId).update({
        'commentLen': query.count +1
      });
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> saveStory (String postId, String descreption, String profImage, List story, List photos, String uid) async {
   String res = "Some error occurred";
   try{
     _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
         .collection('saved')
         .doc(postId)
         .set({
       'description': descreption,
       'profImage': profImage,
       'stories': story,
       'photos': photos,
       'uid': uid,
       'postId' : postId,
     });
     res = 'success';
   }catch(e){
     res = e.toString();
   }
   return res;
  }

  Future <String> unSave (String postId) async {
    String res = "Some error occurred";
    try {
      _firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('saved').doc(postId).delete();
    }catch(e){
      res = e.toString();
    }
    return res;
  }

  // Delete Post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> followUser(
    String uid,
    String followId
  ) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });

        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }

    } catch(e) {
      print(e.toString());
    }
  }
}
