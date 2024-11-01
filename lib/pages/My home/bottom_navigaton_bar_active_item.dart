import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moi/models/theme_model.dart';
import 'package:moi/new_chat/activeusers.dart';
//import 'package:moi/pages/home/home/Drawer.dart';

class ActiveItem extends StatefulWidget {
  final String currentUsrid;
  final ThemeModel model;

  const ActiveItem({Key? key, required this.currentUsrid, required this.model})
      : super(key: key);
  @override
  _ActiveitemState createState() => _ActiveitemState();
}

class _ActiveitemState extends State<ActiveItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // body: ActiveUsers(
      //   model: widget.model,
      //   currentUserId: widget.currentUsrid,
      //   context: context,
      //   key: null,
      // ),
    );
  }
}
