import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:babmbino/screens/feed_screen.dart';
import 'package:babmbino/screens/profile_screen.dart';
import 'package:babmbino/screens/search_screen.dart';
import '../screens/add_post_test.dart';
import '../screens/saved_stories.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  const FeedScreen(),
  const SearchScreen(),
  const SavedStories(),
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
