import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../resources/firestore_methods.dart';
import '../utils/global_variable.dart';
import '../widgets/post_card.dart';

class SavedStories extends StatefulWidget {
  const SavedStories({Key? key}) : super(key: key);

  @override
  State<SavedStories> createState() => _SavedStoriesState();
}

class _SavedStoriesState extends State<SavedStories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Icon(Icons.bookmark_border, color: Color(0xff4ecca8), size: 30,),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('saved').snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasData){
                        print('the app have a data');
                        return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (ctx, index) => SavedCard(snap: snapshot.data!.docs[index].data(),)
                        );
                      }else {
                        return Center(
                          child: Text(
                            'No saved stories yet', style: TextStyle(color: Colors.black, fontSize: 25),
                          )
                        );
                      }
                    }),
              )
            ],
          ),
        ),

      ),
    );
  }
}

class SavedCard extends StatefulWidget {
  final snap;

  const SavedCard({Key? key, required this.snap,}) : super(key: key);

  @override
  State<SavedCard> createState() => _SavedCardState();
}

class _SavedCardState extends State<SavedCard> {
  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              children: [
                InkWell(
                    child: Container(
                      width: MediaQuery.of(context).size.width*0.7,
                      height: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: NetworkImage(
                              widget.snap['profImage'].toString(),
                            ),
                          ),
                          Text(widget.snap['description'],
                            style: TextStyle(fontSize: 20, fontFamily: 'Schyler'),),
                        ],
                      ),
                    ),
                    onTap: () {
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                            builder: (context) =>
                                ResponsiveAddStory(
                                  verticalScreen: AddStoryY(
                                    storyTitle:
                                    widget.snap['description'].toString(),
                                    profileImage:
                                    widget.snap['profImage'].toString(),
                                    storyBody: widget.snap['stories'],
                                    ImageURL: widget.snap['photos'],
                                    scaleH: 0.7,
                                    scaleW: 0.7,
                                    Uid: widget.snap['uid'],
                                  ),
                                  horizontalScreen: AddStoryX(
                                    storyTitle:
                                    widget.snap['description'].toString(),
                                    profileImage:
                                    widget.snap['profImage'].toString(),
                                    storyBody: widget.snap['stories'],
                                    ImageURL: widget.snap['photos'],
                                    scaleH: 1,
                                    scaleW: 0.35,
                                    Uid: widget.snap['uid'],
                                  ),
                                )));
                      }
                    }
                ),
                SizedBox(width: 25,),
                InkWell(child: Icon(Icons.delete, size: 25, color: Colors.red,),
                  onTap: (){
                    FireStoreMethods().unSave(widget.snap['postId']);
                  },)
              ],
            ),
            Divider(
              color: Color(0xff1cb38b),
              thickness: 1.5,
            ),
          ],
        ),
      );
  }
}
