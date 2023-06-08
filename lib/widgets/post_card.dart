import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:babmbino/models/user.dart' as model;
import 'package:babmbino/providers/user_provider.dart';
import 'package:babmbino/resources/firestore_methods.dart';
import 'package:babmbino/screens/comments_screen.dart';
import 'package:babmbino/utils/colors.dart';
import 'package:babmbino/utils/global_variable.dart';
import 'package:babmbino/utils/utils.dart';
import 'package:babmbino/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../screens/profile_screen.dart';

class PostCard extends StatefulWidget {
  final snap;

  const PostCard({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  //int commentLen = 0;
  bool isLikeAnimating = false;
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    fetchCommentLen();
    getSaving();
  }

  fetchCommentLen() async {
    try {
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.snap['postId'])
          .collection('comments')
          .get();
      // setState(() {
      //   commentLen = snap.docs.length;
      // });
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
    setState(() {});
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      showSnackBar(
        context,
        err.toString(),
      );
    }
  }

  void getSaving () async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('saved')
        .doc(widget.snap['postId']).get();
    setState(() {
      isSaved = widget.snap['postId'] == snapshot['postId'];
    });
    print (isSaved);
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final width = MediaQuery.of(context).size.width;
    return Container(
      // boundary needed for web
      decoration: BoxDecoration(
        border: Border.all(
          color: width > webScreenSize ? secondaryColor : Colors.white,
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Column(
        children: [
          // HEADER SECTION OF THE POST
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 16,
            ).copyWith(right: 0),
            child: Row(
              children: <Widget>[
                InkWell(
                  child: CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                      widget.snap['profImage'].toString(),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.snap['uid'],)));
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.snap['username'].toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd()
                              .format(widget.snap['datePublished'].toDate()),
                          style: const TextStyle(
                            color: secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                widget.snap['uid'].toString() == user.uid
                    ? IconButton(
                        onPressed: () {
                          showDialog(
                            useRootNavigator: false,
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: ListView(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shrinkWrap: true,
                                    children: [
                                      'Delete',
                                    ]
                                        .map(
                                          (e) => InkWell(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12,
                                                        horizontal: 16),
                                                child: Text(e),
                                              ),
                                              onTap: () {
                                                deletePost(
                                                  widget.snap['postId']
                                                      .toString(),
                                                );
                                                // remove the dialog box
                                                Navigator.of(context).pop();
                                              }),
                                        )
                                        .toList()),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert),
                      )
                    : Container(),
              ],
            ),
          ),
          // THE TITLE OF THE STORY
          Text(
            '${widget.snap['description']}',
            style: TextStyle(fontSize: 25, fontFamily: 'Schyler'),
          ),
          SizedBox(
            height: 10,
          ),
          // IMAGE SECTION OF THE POST
          GestureDetector(
            onDoubleTap: () {
              FireStoreMethods().likePost(
                widget.snap['postId'].toString(),
                user.uid,
                widget.snap['likes'],
              );
              setState(() {
                isLikeAnimating = true;
              });
            },
            onTap: () {
              print ('the saving state is $getSaving');
              if (mounted) {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(
                        builder: (context) => ResponsiveAddStory(
                              verticalScreen: AddStoryY(
                                storyTitle:
                                    widget.snap['description'].toString(),
                                profileImage:
                                    widget.snap['profImage'].toString(),
                                storyBody: widget.snap['story'],
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
                                storyBody: widget.snap['story'],
                                ImageURL: widget.snap['photos'],
                                scaleH: 1,
                                scaleW: 0.35,
                                Uid: widget.snap['uid'],
                              ),
                            )));
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.35,
                  width: double.infinity,
                  child: Image.network(
                    widget.snap['postUrl'].toString(),
                    fit: BoxFit.cover,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating,
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                    duration: const Duration(
                      milliseconds: 400,
                    ),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          // LIKE, COMMENT SECTION OF THE POST
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                children: [
                  LikeAnimation(
                    isAnimating: widget.snap['likes'].contains(user.uid),
                    smallLike: true,
                    child: IconButton(
                      icon: widget.snap['likes'].contains(user.uid)
                          ? const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            )
                          : const Icon(
                              Icons.favorite_border,
                            ),
                      onPressed: () {
                        FireStoreMethods().likePost(
                          widget.snap['postId'].toString(),
                          user.uid,
                          widget.snap['likes'],
                        );
                        // FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']).update({
                        //   'ranking': widget.snap['likes'].length
                        // });
                      }
                    ),
                  ),
                  Text(
                    '${widget.snap['likes'].length}',
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.comment_outlined,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsScreen(
                          postId: widget.snap['postId'].toString(),
                        ),
                      ),
                    ),
                  ),
                  Text('${widget.snap['commentLen']}')
                ],
              ),
              InkWell(
                child: isSaved
                    ? Icon(
                        Icons.bookmark_added,
                        color: Colors.blue,
                      )
                    : Icon(Icons.bookmark_border),
                onTap: () {
                  getSaving();
                  if (!isSaved) {
                    FireStoreMethods().saveStory(
                        widget.snap['postId'],
                        widget.snap['description'].toString(),
                        widget.snap['profImage'],
                        widget.snap['story'],
                        widget.snap['photos'],
                        widget.snap['uid']);
                  } else{
                    FireStoreMethods().unSave(widget.snap['postId']);
                    setState(() {
                      isSaved = false;
                    });
                  }
                },
              )
            ],
          ),
          Text(
            'By the pen of ${widget.snap['username'].toString()}',
            style: TextStyle(fontFamily: 'Schyler', fontSize: 20),
          )
        ],
      ),
    );
  }
}

class ResponsiveAddStory extends StatefulWidget {
  final Widget verticalScreen;
  final Widget horizontalScreen;

  const ResponsiveAddStory(
      {Key? key, required this.verticalScreen, required this.horizontalScreen})
      : super(key: key);

  @override
  State<ResponsiveAddStory> createState() => _ResponsiveAddStoryState();
}

class _ResponsiveAddStoryState extends State<ResponsiveAddStory> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth > webScreenSize) {
        // 600 can be changed to 900 if you want to display tablet screen with mobile screen layout
        return widget.horizontalScreen;
      }
      return widget.verticalScreen;
    });
  }
}

class AddStoryX extends StatefulWidget {
  final String storyTitle;
  final String profileImage;
  final List storyBody;
  final List ImageURL;
  final double scaleW;
  final double scaleH;
  final String Uid;

  const AddStoryX(
      {Key? key,
      required this.storyTitle,
      required this.profileImage,
      required this.storyBody,
      required this.ImageURL,
      required this.scaleW,
      required this.scaleH,
      required this.Uid})
      : super(key: key);

  @override
  State<AddStoryX> createState() => _AddStoryXState();
}

class _AddStoryXState extends State<AddStoryX> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xff1cb38b),
          title: Text(widget.storyTitle),
          actions: [
            InkWell(
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.profileImage),
              ),
              onTap: (){
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.Uid,)));
              },

            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      for (int i = 0; i < widget.ImageURL.length; i++)
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width *
                                widget.scaleW,
                            height: MediaQuery.of(context).size.height *
                                widget.scaleH,
                            child: Center(child: Text(widget.storyBody[i])),
                          ),
                        ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < widget.ImageURL.length; i++)
                        Card(
                            child: Container(
                          width:
                              MediaQuery.of(context).size.width * widget.scaleW,
                          height: MediaQuery.of(context).size.height *
                              widget.scaleH,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter,
                                  image: NetworkImage(widget.ImageURL[i]))),
                        )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}

class AddStoryY extends StatefulWidget {
  final String storyTitle;
  final String profileImage;
  final List storyBody;
  final List ImageURL;
  final double scaleW;
  final double scaleH;
  final String Uid;

  const AddStoryY(
      {Key? key,
      required this.storyTitle,
      required this.profileImage,
      required this.storyBody,
      required this.ImageURL,
      required this.scaleW,
      required this.scaleH,
      required this.Uid})
      : super(key: key);

  @override
  State<AddStoryY> createState() => _AddStoryYState();
}

class _AddStoryYState extends State<AddStoryY> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Color(0xff1cb38b),
          title: Text(widget.storyTitle),
          actions: [
            InkWell(
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.profileImage),
              ),
              onTap: (){
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen(uid: widget.Uid,)));
              },
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < widget.ImageURL.length; i++)
                    Column(
                      children: [
                        Card(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            width: MediaQuery.of(context).size.width *
                                widget.scaleW,
                            height: MediaQuery.of(context).size.height *
                                widget.scaleH,
                            child: Center(child: Text(widget.storyBody[i])),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Card(
                            child: Container(
                          width:
                              MediaQuery.of(context).size.width * widget.scaleW,
                          height: MediaQuery.of(context).size.height *
                              widget.scaleH,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.fill,
                                  alignment: FractionalOffset.topCenter,
                                  image: NetworkImage(widget.ImageURL[i]))),
                        )),
                      ],
                    ),
                  // const SizedBox(
                  //   width: 20,
                  // ),
                ],
              ),
            ),
          ),
        ));
  }
}
