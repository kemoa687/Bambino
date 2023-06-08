import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:babmbino/screens/profile_screen.dart';
import 'package:babmbino/utils/colors.dart';
import 'package:babmbino/utils/global_variable.dart';

import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isShowUsers = false;
  String _dropDownValue = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1cb38b),
        title: Form(
          child: TextFormField(
            controller: searchController,
            decoration:
                const InputDecoration(labelText: 'Search...',labelStyle: TextStyle(
                  color: Colors.white
                )),
            onFieldSubmitted: (String _) {
              setState(() {
                isShowUsers = true;
              });
              print(_);
            },
          ),
        ),
        actions: [
          IconButton(onPressed: (){
            setState(() {
              isShowUsers = true;
            });
          }, icon: Icon(Icons.search))
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30),
          child: Container(
            width: 120,
            child: DropdownButton<String>(
              isExpanded: true,
              hint: _dropDownValue == ''
                  ? Text('Search for...')
                  : Text(
                _dropDownValue,
              ),
              items: <String>['Users','Stories'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _dropDownValue = value!;
                });
              },
            ),
          ),
        ) ,
      ),
      body: isShowUsers
          ? FutureBuilder(
              future: _dropDownValue == 'Stories'?
              FirebaseFirestore.instance
                  .collection('posts')
                  .where(
                'description',
                isGreaterThanOrEqualTo: searchController.text,
              ).get():
              FirebaseFirestore.instance
                  .collection('users')
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _dropDownValue == 'Users'?
                        Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                            uid: (snapshot.data! as dynamic).docs[index]['uid'],
                          ),
                        ),
                      ):
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ResponsiveAddStory(
                              verticalScreen: AddStoryY(
                                storyTitle:
                                (snapshot.data! as dynamic).docs[index]['description'].toString(),
                                profileImage:
                                (snapshot.data! as dynamic).docs[index]['profImage'].toString(),
                                storyBody: (snapshot.data! as dynamic).docs[index]['story'],
                                ImageURL: (snapshot.data! as dynamic).docs[index]['photos'],
                                scaleH: 0.7,
                                scaleW: 0.7,
                                Uid: (snapshot.data! as dynamic).docs[index]['uid'],
                              ),
                              horizontalScreen: AddStoryX(
                                storyTitle:
                                (snapshot.data! as dynamic).docs[index]['description'].toString(),
                                profileImage:
                                (snapshot.data! as dynamic).docs[index]['profImage'].toString(),
                                storyBody: (snapshot.data! as dynamic).docs[index]['story'],
                                ImageURL: (snapshot.data! as dynamic).docs[index]['photos'],
                                scaleH: 1,
                                scaleW: 0.35,
                                Uid: (snapshot.data! as dynamic).docs[index]['uid'],
                              ),
                            )
                          ),
                        );
                        },
                      child: _dropDownValue == 'Stories'?
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['profImage'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['description'],
                        ),
                        subtitle: Text(
                            "${(snapshot.data! as dynamic).docs[index]['photos'].length}"
                        ),
                        trailing: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['postUrl'],
                          ),
                          radius: 16,
                        ),
                      ):
                      ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(
                            (snapshot.data! as dynamic).docs[index]['photoUrl'],
                          ),
                          radius: 16,
                        ),
                        title: Text(
                          (snapshot.data! as dynamic).docs[index]['username'],
                        ),
                        subtitle: Text(
                          'Followers: ${(snapshot.data! as dynamic).docs[index]['followers'].length}',
                        ),
                      )
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('posts').where('privacy', isEqualTo: 'public')
                  .orderBy('ranking', descending: true)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
  
                return StaggeredGridView.countBuilder(
                  crossAxisCount: 3,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) =>
                      InkWell(
                    child:
                    CircleAvatar(
                      backgroundImage:NetworkImage(
                          (snapshot.data! as dynamic).docs[index]['postUrl']
                      ) ,
                    ),
                    onTap:() {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(
                              builder: (context) => ResponsiveAddStory(
                                    verticalScreen: AddStoryY(
                                      storyTitle: (snapshot.data! as dynamic).docs[index]['description'],
                                      profileImage: (snapshot.data! as dynamic).docs[index]['profImage'],
                                      storyBody: (snapshot.data! as dynamic).docs[index]['story'],
                                      ImageURL: (snapshot.data! as dynamic).docs[index]['photos'],
                                      scaleW: 0.8,
                                      scaleH: 0.7,
                                      Uid: (snapshot.data! as dynamic).docs[index]['uid'],
                                    ),
                                    horizontalScreen: AddStoryX(
                                      storyTitle: (snapshot.data! as dynamic).docs[index]['description'],
                                      profileImage: (snapshot.data! as dynamic).docs[index]['profImage'],
                                      storyBody: (snapshot.data! as dynamic).docs[index]['story'],
                                      ImageURL: (snapshot.data! as dynamic).docs[index]['photos'],
                                      scaleH: 1,
                                      scaleW: 0.35,
                                      Uid: (snapshot.data! as dynamic).docs[index]['uid'],
                                    ),
                                  )));
                    },
                  ),
                  staggeredTileBuilder: (index) => MediaQuery.of(context)
                              .size
                              .width >
                          webScreenSize
                      ? StaggeredTile.count(
                          (index % 7 == 0) ? 1 : 1, (index % 7 == 0) ? 1 : 1)
                      : StaggeredTile.count(
                          (index % 7 == 0) ? 2 : 1, (index % 7 == 0) ? 2 : 1),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
    );
  }
}
