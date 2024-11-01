import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:moi/const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moi/settings/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_model.dart';

/*class ChatSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PROFILE',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SettingsScreen(),
    );
  }
}*/

class SettingsScreen extends StatefulWidget {
  final ThemeModel model;
  final BuildContext context;
  const SettingsScreen({Key? key, required this.model, required this.context})
      : super(key: key);
  @override
  State createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  TextEditingController? controllerNickname;
  TextEditingController? controllerAboutMe;

  SharedPreferences? prefs;

  String id = '';
  String nickname = '';
  String aboutMe = '';
  String photoUrl = '';

  bool isLoading = false;
  File? avatarImageFile;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    id = prefs?.getString('id') ?? '';
    nickname = prefs?.getString('nickname') ?? '';
    aboutMe = prefs?.getString('aboutMe') ?? '';
    photoUrl = prefs?.getString('photoUrl') ?? '';

    controllerNickname = TextEditingController(text: nickname);
    controllerAboutMe = TextEditingController(text: aboutMe);

    // Force refresh input
    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile;

    pickedFile = (await imagePicker.pickImage(source: ImageSource.gallery))
        as PickedFile;

    File image = File(pickedFile.path);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id;
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(avatarImageFile!);
    uploadTask.then((value) {
      if (value.ref != null) {
        value.ref.getDownloadURL().then((downloadUrl) {
          photoUrl = downloadUrl;
          FirebaseFirestore.instance.collection('users').doc(id).update({
            'nickname': nickname,
            'aboutMe': aboutMe,
            'photoUrl': photoUrl
          }).then((data) async {
            await prefs?.setString('photoUrl', photoUrl);
            setState(() {
              isLoading = false;
            });
            // EdgeAlert.show(context,
            //     title: 'SUCCESS',
            //     description: 'Upload success',
            //     gravity: EdgeAlert.BOTTOM,
            //     icon: Icons.done,
            //     backgroundColor: Colors.blue);
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            // EdgeAlert.show(context,
            //     title: 'ERROR',
            //     description: err.toString(),
            //     gravity: EdgeAlert.BOTTOM,
            //     icon: Icons.error,
            //     backgroundColor: Colors.blue);
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          // EdgeAlert.show(context,
          //     title: 'ERROR',
          //     description: 'This file is not an image',
          //     gravity: EdgeAlert.BOTTOM,
          //     icon: Icons.error,
          //     backgroundColor: Colors.blue);
        });
      } else {
        setState(() {
          isLoading = false;
        });
        // EdgeAlert.show(context,
        //     title: 'ERROR',
        //     description: 'This file is not an image',
        //     gravity: EdgeAlert.BOTTOM,
        //     icon: Icons.error,
        //     backgroundColor: Colors.blue);
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      // EdgeAlert.show(context,
      //     title: 'ERROR',
      //     description: err.toString(),
      //     gravity: EdgeAlert.BOTTOM,
      //     icon: Icons.error,
      //     backgroundColor: Colors.blue);
    });
  }

  void handleUpdateData() {
    focusNodeNickname.unfocus();
    focusNodeAboutMe.unfocus();

    setState(() {
      isLoading = true;
    });

    FirebaseFirestore.instance.collection('users').doc(id).update({
      'nickname': nickname,
      'aboutMe': aboutMe,
      'photoUrl': photoUrl
    }).then((data) async {
      await prefs?.setString('nickname', nickname);
      await prefs?.setString('aboutMe', aboutMe);
      await prefs?.setString('photoUrl', photoUrl);

      setState(() {
        isLoading = false;
      });

      //   EdgeAlert.show(context,
      //       title: 'DONE',
      //       description: 'Upload success',
      //       gravity: EdgeAlert.BOTTOM,
      //       icon: Icons.done,
      //       backgroundColor: Colors.blue);
      // }).catchError((err) {
      //   setState(() {
      //     isLoading = false;
      //   });

      // EdgeAlert.show(context,
      //     title: 'ERROR',
      //     description: err.toString(),
      //     gravity: EdgeAlert.BOTTOM,
      //     icon: Icons.error,
      //     backgroundColor: Colors.blue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: widget.model,
        child: Consumer<ThemeModel>(builder: (context, model, __) {
          return Scaffold(
//            appBar: AppBar(
//              backgroundColor: Colors.blue,
//              title: Text(
//                widget.model.appLocal.languageCode == 'ar'
//                    ? 'حسابى'
//                    : 'PROFILE',
//                style: TextStyle(fontWeight: FontWeight.bold),
//              ),
//              centerTitle: true,
//            ),
            body: Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      // Avatar
                      Container(
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              (avatarImageFile == null)
                                  ? (photoUrl != ''
                                      ? Material(
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                Container(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(themeColor),
                                              ),
                                              width: 90.0,
                                              height: 90.0,
                                              padding: EdgeInsets.all(20.0),
                                            ),
                                            imageUrl: photoUrl,
                                            width: 90.0,
                                            height: 90.0,
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(45.0)),
                                          clipBehavior: Clip.hardEdge,
                                        )
                                      : Icon(
                                          Icons.account_circle_outlined,
                                          size: 90.0,
                                          color: Colors.blue.shade400,
                                        ))
                                  : Material(
                                      child: Image.file(
                                        avatarImageFile!,
                                        width: 90.0,
                                        height: 90.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(45.0)),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                              Positioned(
                                left: 57,
                                bottom: 5,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Colors.black,
                                  ),
                                  onPressed: getImage,
                                  //padding: EdgeInsets.symmetric(vertical:30.0),
                                  splashColor: Colors.transparent,
                                  highlightColor: greyColor,
                                  iconSize: 20.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        margin: EdgeInsets.all(20.0),
                      ),
                      SizedBox(
                        height: 100,
                      ),

                      // Input
                      Column(
                        children: <Widget>[
                          Text(
                            'name',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),

                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: TextFormField(
                              controller: controllerNickname,
                              style: TextStyle(color: Colors.black),
                              onChanged: (value) {
                                nickname = value;
                              },
                              focusNode: focusNodeNickname,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  border: new UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.red))),
                            ),
                          ),
                          // Username
//                      Container(
//                        child: Text(
//                          'name',
//                          style: TextStyle(
//                              fontStyle: FontStyle.italic,
//                              fontWeight: FontWeight.bold,
//                              color: primaryColor),
//                        ),
//                        margin: EdgeInsets.only(
//                            left: 10.0, bottom: 5.0, top: 10.0),
//                      ),
//                      Container(
//                        child: Theme(
//                          data: Theme.of(context)
//                              .copyWith(primaryColor: primaryColor),
//                          child: TextField(
//                            decoration: InputDecoration(
//                              hintText: '',
//                              contentPadding: EdgeInsets.all(5.0),
//                              hintStyle: TextStyle(color: greyColor),
//                            ),
//                            controller: controllerNickname,
//                            onChanged: (value) {
//                              nickname = value;
//                            },
//                            focusNode: focusNodeNickname,
//                          ),
//                        ),
//                        margin: EdgeInsets.only(left: 30.0, right: 30.0),
//                      ),

                          // About me
                          Text(
                            'Bio',
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            child: TextFormField(
                              controller: controllerAboutMe,
                              style: TextStyle(color: Colors.black),
                              onChanged: (value) {
                                aboutMe = value;
                              },
                              focusNode: focusNodeAboutMe,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  fillColor: Colors.grey.shade200,
                                  filled: true,
                                  border: new UnderlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.blue))),
                            ),
                          ),

//                          Container(
//                            child: Text(
//                              'Bio',
//                              style: TextStyle(
//                                  fontStyle: FontStyle.italic,
//                                  fontWeight: FontWeight.bold,
//                                  color: primaryColor),
//                            ),
//                            margin: EdgeInsets.only(
//                                left: 10.0, top: 30.0, bottom: 5.0),
//                          ),
//                          Container(
//                            child: Theme(
//                              data: Theme.of(context)
//                                  .copyWith(primaryColor: primaryColor),
//                              child: TextField(
//                                decoration: InputDecoration(
//                                  hintText: '',
//                                  contentPadding: EdgeInsets.all(5.0),
//                                  hintStyle: TextStyle(color: greyColor),
//                                ),
//                                controller: controllerAboutMe,
//                                onChanged: (value) {
//                                  aboutMe = value;
//                                },
//                                focusNode: focusNodeAboutMe,
//                              ),
//                            ),
//                            margin: EdgeInsets.only(left: 30.0, right: 30.0),
//                          ),
                        ],
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),

                      // Button
                    ],
                  ),
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                ),

                // Loading
                Positioned(
                  child: isLoading
                      ? Container(
                          child: Center(
                            child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(themeColor)),
                          ),
                          color: Colors.white.withOpacity(0.8),
                        )
                      : Container(),
                ),
              ],
            ),
            floatingActionButton: Container(
              child: ElevatedButton(
                onPressed: () {
                  handleUpdateData();
                  Navigator.pop(context);
                },
                child: Text(
                  model.appLocal.languageCode == 'ar' ? 'تعديل' : 'Done',
                  style: TextStyle(fontSize: 16.0),
                ),
                // color: model.primaryMainColor,
                // highlightColor: Color(0xff8d93a0),
                // splashColor: Colors.transparent,
                // textColor: Colors.white,
                // padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
              ),
              margin: EdgeInsets.only(top: 50.0, bottom: 50.0),
            ),
          );
        }));
  }
}

class EdgeAlert {}
