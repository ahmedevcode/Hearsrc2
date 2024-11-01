import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePageCheck extends StatefulWidget {
  String name;
  final currentUserId;
  WelcomePageCheck({required this.name, required this.currentUserId});

  @override
  _WelcomePageCheckState createState() => _WelcomePageCheckState();
}

class _WelcomePageCheckState extends State<WelcomePageCheck> {
  bool isLoading = false;
  void initState() {
//createUser();
    Timer(Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    });
    super.initState();
  }

  void createUser() async {
    setState(() {
      isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.currentUserId)
        .get();
    // .getDocuments();
//50ZYBhGNeIQWtnHEpM6KRG2obQg1
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.length == 0) {
      // Update data to server if new user
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .set({
        'nickname': prefs.getString('username'),
        'photoUrl': '',
        'groups': [],
        'id': widget.currentUserId,
        'active': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'chattingWith': null
      });

      // Write data to local
      await prefs.setString('id', widget.currentUserId);
      await prefs.setString('nickname', prefs.getString('username') ?? '');
      await prefs.setString('photoUrl', '');
      setState(() {
        isLoading = false;
      });
    } else {
      // Write data to local
      // await prefs.setString('id', documents.data.name);
      // await prefs.setString('nickname', documents[0].data()['nickname'] ?? '');
      // await prefs.setString('photoUrl', documents[0].data()['photoUrl']);
      // await prefs.setString('aboutMe', documents[0].data()['aboutMe']);
      setState(() {
        isLoading = false;
      });
    }
    Timer(Duration(seconds: 1), () {
      Navigator.pushNamedAndRemoveUntil(context, 'home', (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 250,
            ),
            Image.asset(
              'assets/checkmark.png',
              width: 250,
              height: 150,
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              'Welcome ${widget.name} ',
              style: TextStyle(color: Colors.black, fontSize: 18),
            )
          ],
        ),
      ),
    );
  }
}
