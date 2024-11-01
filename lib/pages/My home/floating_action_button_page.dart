import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:moi/models/theme_model.dart';
import 'package:moi/new_chat/chat.dart';
import 'package:provider/provider.dart';

import '../../const.dart';

class FloatingActionPage extends StatefulWidget {
  final String? currentUserId;
  late ThemeModel? model;
  final BuildContext? context;

  FloatingActionPage(
      {Key? key,
      this.currentUserId,
      required this.model,
      required this.context})
      : super(key: key);
  @override
  _FloatingActionPageState createState() =>
      _FloatingActionPageState(currentUserId: currentUserId!);
}

class _FloatingActionPageState extends State<FloatingActionPage> {
  _FloatingActionPageState({required this.currentUserId});
  final String currentUserId;
  late ThemeModel mymodel;
  void init() {
    ThemeModel mymodel = Provider.of<ThemeModel>(context, listen: false);
  }

  TextEditingController textEditingController = new TextEditingController();
  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: TextField(
          controller: textEditingController,
          style: TextStyle(color: Colors.black),
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Select Contact',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              suffixIcon: Icon(
                Icons.search,
                color: Colors.black,
              )),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 5),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                  size: 10,
                ),
                Text(
                  'Back',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
                child: Column(
              children: [
                Icon(
                  Icons.filter_drama,
                  size: 50,
                  color: Colors.grey,
                ),
                Text(
                  mymodel.appLocal.languageCode == 'ar'
                      ? 'جهات الاتصال فارغة'
                      : 'Empty contacts',
                  style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontSize: 18),
                ),
              ],
            ));
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>

                  //print('metadata$index ${metadata.data} ');
                  snapshot.data!.docs[index]
                          .data()['nickname']
                          .toString()
                          .contains(textEditingController.text)
                      ? buildItem(context, snapshot.data!.docs[index], mymodel)
                      : Container(),
              itemCount: snapshot.data!.docs.length,
            );
          }
        },
      ),
    );
  }

  Widget buildItem(
      BuildContext context, DocumentSnapshot document, ThemeModel model) {
    String lastmsg;
    if (document.id == currentUserId) {
      return Container();
    } else {
      //unReadMsg(document.data()['id']);

      return Container(
        child: ElevatedButton(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: mymodel.appLocal == Locale('ar')
                ? TextDirection.rtl
                : TextDirection.ltr,
            children: <Widget>[
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0.0),
                    child: Material(
                      child: (document.id.isNotEmpty)
                          ? CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.0,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(themeColor),
                                ),
                                width: 50.0,
                                height: 50.0,
                                padding: EdgeInsets.all(15.0),
                              ),
                              imageUrl: document.id,
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'assets/profile.png',
                                  width: 40.0,
                                  height: 40.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              ),
                              width: 50.0,
                              height: 50.0,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 55.0,
                              color: greyColor,
                            ),
                      borderRadius: BorderRadius.all(Radius.circular(25.0)),
                      clipBehavior: Clip.hardEdge,
                    ),
                  ),
                ],
              ),
              Flexible(
                  child: Container(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                '${document.data}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Divider(
                        thickness: 1.50,
                      ),
                    )
                  ],
                ),
                margin: EdgeInsets.only(left: 5.0),
              )),
            ],
          ),
          onPressed: () {
            //clearNotify();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Chat(
                          peerId: document.id,
                          // peerAvatar: document.data['photoUrl'],
                          peerAvatar: document.id,
                          nickName: document.id.characters.string,
                          active: document.exists,
                          model: model,
                        )));
          },
          // color: greyColor2,
          // padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          // shape:
          // RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
//        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
      );
    }
  }
}
