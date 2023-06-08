import 'package:babmbino/widgets/post_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:babmbino/resources/auth_methods.dart';
import 'package:babmbino/resources/firestore_methods.dart';
import 'package:babmbino/screens/login_screen.dart';
import 'package:babmbino/utils/utils.dart';
import 'package:babmbino/widgets/follow_button.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  int postLen = 0;
  int followers = 0;
  int following = 0;
  bool isFollowing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);
      setState(() {});
    } catch (e) {
      showSnackBar(
        context,
        e.toString(),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xff1cb38b),
              title: Text(
                userData['username'],
              ),
              centerTitle: false,
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey,
                            backgroundImage: NetworkImage(
                              userData['photoUrl'],
                            ),
                            radius: 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColumn(postLen, "posts"),
                                    buildStatColumn(followers, "followers"),
                                    buildStatColumn(following, "following"),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FirebaseAuth.instance.currentUser!.uid ==
                                            widget.uid
                                        ? SizedBox(
                                            width: 200,
                                            child: FollowButton(
                                              text: 'Sign Out',
                                              backgroundColor:
                                                  Color(0xff4a9987),
                                              textColor: Colors.white,
                                              borderColor: Color(0xff4a9987),
                                              function: () async {
                                                await AuthMethods().signOut();
                                                Navigator.of(context)
                                                    .pushReplacement(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const LoginScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : isFollowing
                                            ? SizedBox(
                                                width: 200,
                                                child: FollowButton(
                                                  text: 'Unfollow',
                                                  backgroundColor:
                                                      Color(0xff4a9987),
                                                  textColor: Colors.white,
                                                  borderColor:
                                                      Color(0xff4a9987),
                                                  function: () async {
                                                    await FireStoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );
                                                    setState(() {
                                                      isFollowing = false;
                                                      followers--;
                                                    });
                                                  },
                                                ),
                                              )
                                            : SizedBox(
                                                width: 200,
                                                child: FollowButton(
                                                  text: 'Follow',
                                                  backgroundColor:
                                                      Color(0xff4a9987),
                                                  textColor: Colors.white,
                                                  borderColor:
                                                      Color(0xff4a9987),
                                                  function: () async {
                                                    await FireStoreMethods()
                                                        .followUser(
                                                      FirebaseAuth.instance
                                                          .currentUser!.uid,
                                                      userData['uid'],
                                                    );

                                                    setState(() {
                                                      isFollowing = true;
                                                      followers++;
                                                    });
                                                  },
                                                ),
                                              )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 15,
                        ),
                        child: Text(
                          userData['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(
                          top: 1,
                        ),
                        child: Text(
                          userData['bio'],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                StreamBuilder(
                  stream: FirebaseAuth.instance.currentUser!.uid == widget.uid
                      ? FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .snapshots()
                      : FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: widget.uid)
                          .where('privacy', isEqualTo: 'public')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: (snapshot.data! as dynamic).docs.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 6,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        return profilePost(
                          snap: snapshot.data!.docs[index].data(),
                        );
                      },
                    );
                  },
                )
              ],
            ),
          );
  }

  Column buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

class profilePost extends StatefulWidget {
  final snap;

  const profilePost({Key? key, required this.snap}) : super(key: key);

  @override
  State<profilePost> createState() => _profilePostState();
}

class _profilePostState extends State<profilePost> {
  @override
  Widget build(BuildContext context) {
    return Container(
          child: Column(
        //mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
              child: CircleAvatar(
                backgroundImage: NetworkImage(widget.snap['postUrl']),
                radius: 40,
              ),
              onTap: () {
                print('the privacy is ${widget.snap['privacy'] == 'private'}');
                Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                    builder: (context) => ResponsiveAddStory(
                          verticalScreen: AddStoryY(
                            storyTitle: widget.snap['description'],
                            profileImage: widget.snap['profImage'],
                            storyBody: widget.snap['story'],
                            ImageURL: widget.snap['photos'],
                            scaleW: 0.8,
                            scaleH: 0.7,
                            Uid: widget.snap['uid'],
                          ),
                          horizontalScreen: AddStoryX(
                            storyTitle: widget.snap['description'],
                            profileImage: widget.snap['profImage'],
                            storyBody: widget.snap['story'],
                            ImageURL: widget.snap['photos'],
                            scaleH: 1,
                            scaleW: 0.35,
                            Uid: widget.snap['uid'],
                          ),
                        )));
              }),
          //SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Text(
                  widget.snap['description'],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12
                  ),
                ),
              widget.snap['privacy'] == 'private'
                  ? Icon(
                      Icons.lock,
                      size: 15,
                    )
                  : Container()
            ],
          )
        ],
      )
    );
  }
}