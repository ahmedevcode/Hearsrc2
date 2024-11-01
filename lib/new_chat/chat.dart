import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show Uint8List;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/rendering.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:moi/common/firebase_services.dart';
import 'package:moi/const.dart';
import 'package:moi/helper/helper_functions.dart';
import 'package:moi/new_chat/playvideo.dart';
import 'package:moi/new_chat/widgets/sound.dart';
import 'package:moi/new_chat/widgets/videoimage.dart';
import 'package:moi/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/full_photo.dart';
import 'widgets/loading.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:moi/models/theme_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/sound.dart';
import 'widgets/speach_toText.dart';

const int SAMPLE_RATE = 8000;
const int BLOCK_SIZE = 4096;

enum Media {
  file,
  buffer,
  asset,
  stream,
  remoteExampleFile,
}

enum AudioState {
  isPlaying,
  isPaused,
  isStopped,
  isRecording,
  isRecordingPaused,
}

//////////////////////////////
class Chat extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String nickName;
  final ThemeModel model;
  final bool active;

  Chat(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.nickName,
      required this.active,
      required this.model})
      : super(key: key);
  @override
  State createState() => MainScreenState();
}

class MainScreenState extends State<Chat> {
  var active = false, isfav = false;
  String groupChatId = '';
  late SharedPreferences prefs;
  List<String> fav = [];
  bool delete = false, showsearch = false;
  List<PopupMenuItem> popUpMenuItems = [
    PopupMenuItem(
      value: 1,
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: Colors.blue,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'search',
            style: TextStyle(color: Colors.white, fontSize: 10),
          )
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: [
          Icon(
            Icons.cleaning_services,
            color: Colors.blue,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'clean chat',
            style: TextStyle(color: Colors.white, fontSize: 10),
          )
        ],
      ),
    ),
    PopupMenuItem(
      value: 3,
      child: Row(
        children: [
          Icon(
            Icons.notifications_off_outlined,
            color: Colors.blue,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Mute notification',
            style: TextStyle(color: Colors.white, fontSize: 10),
          )
        ],
      ),
    ),
    PopupMenuItem(
      value: 4,
      child: Row(
        children: [
          Icon(
            Icons.delete,
            color: Colors.blue,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Delete chat',
            style: TextStyle(color: Colors.white, fontSize: 10),
          )
        ],
      ),
    ),
  ];
  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('id') ?? '';
    if (id.hashCode <= widget.peerId.hashCode) {
      groupChatId = '$id-${widget.peerId}';
    } else {
      groupChatId = '${widget.peerId}-$id';
    }

    /*FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .update({'chattingWith': peerId, 'active': true});*/

    setState(() {});
  }

  Future<dynamic> getStatus() async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.peerId)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    var temp = documents.length != 0 ? documents[0].data : false;
    setState(() {
      //  active = temp;
    });
    // //print(' status $temp');
  }

  @override
  void initState() {
    readLocal();
    HelperFunctions.getUserfromFav().then((value) {
      if (value != null) {
        setState(() {
          fav = value;
          isfav = fav.contains(widget.peerId) ? true : false;
        });
      }
    });
    super.initState();
    getStatus();
  }

  @override
  Widget build(BuildContext context) {
    getStatus();
    return ChangeNotifierProvider.value(
        value: widget.model,
        child: Consumer<ThemeModel>(
            builder: (_, model, __) => Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  elevation: 1,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  flexibleSpace: SafeArea(
                    child: Container(
                      padding: EdgeInsets.only(right: 16),
                      child: Row(
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, bottom: 5),
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
                          SizedBox(
                            width: 8,
                          ),
                          Material(
                            child: widget.peerAvatar != ''
                                ? CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.0,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                themeColor),
                                      ),
                                      width: 40.0,
                                      height: 40.0,
                                      padding: EdgeInsets.all(15.0),
                                    ),
                                    imageUrl: widget.peerAvatar,
                                    width: 40.0,
                                    height: 40.0,
                                    errorWidget: (context, url, error) =>
                                        Material(
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
                                    fit: BoxFit.cover,
                                  )
                                : Material(
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
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  widget.nickName ?? '',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 3,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 25),
                                  child: Text(
                                    active != null
                                        ? active
                                            ? 'online'
                                            : 'offline'
                                        : '',
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                if (fav!.contains(widget.peerId)) {
                                  fav.remove(widget.peerId);
                                  HelperFunctions.saveUsertoFav(fav)
                                      .then((value) {
                                    if (value)
                                      setState(() {
                                        isfav = false;
                                      });
                                  });
                                } else {
                                  fav.add(widget.peerId);
                                  HelperFunctions.saveUsertoFav(fav)
                                      .then((value) {
                                    if (value)
                                      setState(() {
                                        isfav = true;
                                      });
                                  });
                                }
                                ;
                              },
                              child: Icon(
                                Icons.star,
                                size: 30,
                                color: isfav ? Colors.orange : Colors.grey,
                              )),
                          PopupMenuButton(
                            color: Colors.black.withBlue(50),
                            itemBuilder: (context) => popUpMenuItems,
                            elevation: 2,
                            onSelected: (value) {
                              // //print('searchs $value');
                              if (value == popUpMenuItems[0].value) {
                                setState(() {
                                  showsearch = true;
                                });
                              } else if (value == popUpMenuItems[1].value) {
                                cleanChat();
                              } else if (value == popUpMenuItems[2]) {
                              } else if (value == popUpMenuItems[3].value) {
                                setState(() {
                                  delete = true;
                                });
                              }
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                body: Container(
                  color: Colors.amber,
                ))));
    //    ChatScreen(
    //     showsearch: showsearch,
    //     delete: delete,
    //     onClick: onClick,
    //     peerId: widget.peerId,
    //     peerAvatar: widget.peerAvatar,
    //     model: widget.model, peerName: null,
    //   ),
    // )));
  }

  Future<Null> cleanChat() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Theme.of(context).primaryColor,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.clear,
                        size: 30.0,
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Clear Chat',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to clear Chat?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.cancel,
                            color: primaryColor,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'CANCEL',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Icon(
                            Icons.check_circle,
                            color: primaryColor,
                          ),
                          margin: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          'YES',
                          style: TextStyle(
                              color: primaryColor, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        await FirebaseServices()
            .firestore
            .collection('messages')
            .doc(groupChatId)
            .collection(groupChatId)
            .get()
            .then((value) {
          //print('lll ${value.docs.length}');
          value.docs.forEach((element) {
            element.reference.delete();
          });
        });

        break;
    }
  }

  onClick() {
    setState(() {
      //print('yyy');
      showsearch = false;
    });
  }
}

// class ChatScreen extends StatefulWidget {
//   final String peerId;
//   final String peerAvatar;
//   final bool delete;
//   final Function onClick;
//   final bool showsearch;
//   final ThemeModel model;

//   ChatScreen(
//       {Key? key,
//       required this.peerId,
//       required this.peerAvatar,
//       required this.model,
//       this.delete = false,
//       this.showsearch = false,
//      required this.onClick,
//       required peerName})
//       : super(key: key);

//   @override
//   State createState() =>
//      // ChatScreenState(peerId: peerId, peerAvatar: peerAvatar);
// }

//  class ChatScreenState extends State<ChatScreen> {
//   ChatScreenState({Key ?key, required this.peerId, required this.peerAvatar});

//   String peerId;
//   String peerAvatar;
//   String id;
//   TextEditingController searchEditingController = new TextEditingController();
//   List<DocumentSnapshot> listMessage = new List.from([]);
//   int _limit = 20;
//   final int _limitIncrement = 20;
//   String groupChatId;
//   SharedPreferences prefs;

//   File imageFile;
//   bool isLoading;
//   bool isShowSticker;
//   String imageUrl;

//   final TextEditingController textEditingController = TextEditingController();
//   final ScrollController listScrollController = ScrollController();
//   final FocusNode focusNode = FocusNode();

//   _scrollListener() {
//     if (listScrollController.offset >=
//             listScrollController.position.maxScrollExtent &&
//         !listScrollController.position.outOfRange) {
//       //print("reach the bottom");
//       setState(() {
//         //print("reach the bottom");
//         _limit += _limitIncrement;
//       });
//     }
//     if (listScrollController.offset <=
//             listScrollController.position.minScrollExtent &&
//         !listScrollController.position.outOfRange) {
//       //print("reach the top");
//       setState(() {
//         //print("reach the top");
//       });
//     }
//   }

//   int playstatus = 0;
// ///////////////////sound from here//////////////
//   bool _isRecording = false;
//   List<String> _path = [

//   ];
//   StreamSubscription _recorderSubscription;
//   StreamSubscription _playerSubscription;
//   StreamSubscription _recordingDataSubscription;

//   FlutterSoundPlayer playerModule = FlutterSoundPlayer();
//   FlutterSoundRecorder recorderModule = FlutterSoundRecorder();

//   String _recorderTxt = ''; //'00:00:00';
//   String _playerTxt = '00:00:00';
//   double _dbLevel;

//   double sliderCurrentPosition = 0.0;
//   double maxDuration = 1.0;
//   Media _media = Media.remoteExampleFile;
//   Codec _codec = Codec.aacADTS;

//   bool _encoderSupported = true; // Optimist
//   bool _decoderSupported = true; // Optimist

//   // Whether the user wants to use the audio player features
//   bool _isAudioPlayer = false;
//   int selectedIndex;
//   double ?_duration = null;
//   StreamController<Food> recordingDataController;
//   IOSink sink;

//   void setCodec(Codec codec) async {
//     _encoderSupported = await recorderModule.isEncoderSupported(codec);
//     _decoderSupported = await playerModule.isDecoderSupported(codec);

//     setState(() {
//       _codec = codec;
//     });
//   }

//   Future<void> init() async {
//     selectedIndex = 0;
//     await recorderModule.openAudioSession(
//         focus: AudioFocus.requestFocusAndStopOthers,
//         category: SessionCategory.playAndRecord,
//         mode: SessionMode.modeDefault,
//         device: AudioDevice.speaker);
//     // await _initializeExample(false);

//     if (Platform.isAndroid) {
//       await copyAssets();
//     }
//   }

//   Future<void> copyAssets() async {
//     Uint8List dataBuffer =
//         (await rootBundle.load("images/logo_only.png")).buffer.asUint8List();
//     String path = await playerModule.getResourcePath() + "/images";
//     if (!await Directory(path).exists()) {
//       await Directory(path).create(recursive: true);
//     }
//     await File(path + '/logo_only.png').writeAsBytes(dataBuffer);
//   }

//   void cancelRecorderSubscriptions() {
//     if (_recorderSubscription != null) {
//       _recorderSubscription.cancel();
//       _recorderSubscription = null;
//     }
//   }

//   void cancelPlayerSubscriptions() {
//     if (_playerSubscription != null) {
//       _playerSubscription.cancel();
//       _playerSubscription = null;
//     }
//   }

//   void cancelRecordingDataSubscription() {
//     if (_recordingDataSubscription != null) {
//       _recordingDataSubscription.cancel();
//       _recordingDataSubscription = null;
//     }
//     recordingDataController = null;
//     if (sink != null) {
//       sink.close();
//       sink = null;
//     }
//   }

//   Future<void> releaseFlauto() async {
//     try {
//       await playerModule.closeAudioSession();
//       await recorderModule.closeAudioSession();
//     } catch (e) {
//       //print('Released unsuccessful');
//       //print(e);
//     }
//   }

//   void startRecorder() async {
//     try {
//       // Request Microphone permission if needed
//       PermissionStatus status = await Permission.microphone.request();
//       if (status != PermissionStatus.granted) {
//         throw RecordingPermissionException("Microphone permission not granted");
//       }

//       Directory tempDir = await getTemporaryDirectory();
//       String path = '${tempDir.path}/flutter_sound${ext[_codec.index]}';

//       if (_media == Media.stream) {
//         //  //print('here');

//         assert(_codec == Codec.pcm16);
//         File outputFile = File(path);
//         if (outputFile.existsSync()) await outputFile.delete();
//         sink = outputFile.openWrite();
//         recordingDataController = StreamController<Food>();
//         _recordingDataSubscription =
//             recordingDataController.stream.listen((Food buffer) {
//           if (buffer is FoodData) sink.add(buffer.data);
//         });
//         await recorderModule.startRecorder(
//           toStream: recordingDataController.sink,
//           codec: _codec,
//           numChannels: 1,
//           sampleRate: SAMPLE_RATE,
//         );
//       } else {
//         // //print('nohere');
//         await recorderModule.startRecorder(
//           toFile: path,
//           codec: _codec,
//           bitRate: 8000,
//           numChannels: 1,
//           sampleRate: SAMPLE_RATE,
//         );
//       }
//       //print('startRecorder');

//       _recorderSubscription = recorderModule.onProgress.listen((e) {
//         if (e != null && e.duration != null) {
//           DateTime date = new DateTime.fromMillisecondsSinceEpoch(
//               e.duration.inMilliseconds,
//               isUtc: true);
//           String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);

//           this.setState(() {
//             _recorderTxt = txt.substring(0, 8);
//             _dbLevel = e.decibels;
//           });
//         }
//       });

//       this.setState(() {
//         this._isRecording = true;
//         this._path[_codec.index] = path;
//       });
//     } catch (err) {
//       //print('startRecorder error: $err');
//       setState(() {
//         stopRecorder();
//         this._isRecording = false;
//         cancelRecordingDataSubscription();
//         cancelRecorderSubscriptions();
//       });
//     }
//   }

//   Future<void> getDuration() async {
//     switch (_media) {
//       case Media.file:
//         break;
//       case Media.buffer:
//         Duration d =
//             await flutterSoundHelper.duration(this._path[_codec.index]);
//         _duration = d != null ? d.inMilliseconds / 1000.0 : null;
//         //  //print('doning');
//         break;
//       case Media.asset:
//         _duration = null;
//         break;
//       case Media.remoteExampleFile:
//         _duration = null;
//         break;
//       default:
//         break;
//     }
//     setState(() {});
//   }

//   void stopRecorder() async {
//     try {
//       await recorderModule.stopRecorder();

//       //print('stopRecorder');
//       cancelRecorderSubscriptions();
//       cancelRecordingDataSubscription();
//       getDuration();
//     } catch (err) {
//       //print('stopRecorder error: $err');
//     }
//     this.setState(() {
//       this._isRecording = false;
//     });
//     uploadFiles(this._path[_codec.index]);
//   }

//   void cancelRecorder() async {
//     if (recorderModule == null || !_encoderSupported) return null;
//     if (_media == Media.stream && _codec != Codec.pcm16) return null;
//     if (recorderModule.isRecording || recorderModule.isPaused)
//       try {
//         await recorderModule.stopRecorder();

//         //print('stopRecorder');
//         cancelRecorderSubscriptions();
//         cancelRecordingDataSubscription();
//         //  getDuration();
//       } catch (err) {
//         //print('stopRecorder error: $err');
//       }
//     this.setState(() {
//       this._isRecording = false;
//     });
//     //   uploadFiles(this._path[_codec.index]);
//   }

//   Future<bool> fileExists(String path) async {
//     return await File(path).exists();
//   }

//   // In this simple example, we just load a file in memory.This is stupid but just for demonstration  of startPlayerFromBuffer()
//   Future<Uint8List> makeBuffer(String path) async {
//     try {
//       if (!await fileExists(path)) return null;
//       File file = File(path);
//       file.openRead();
//       var contents = await file.readAsBytes();
//       //   //print('The file is ${contents.length} bytes long.');
//       return contents;
//     } catch (e) {
//       //print(e);
//       return null;
//     }
//   }

//   Future<Uint8List> _readFileByte(String filePath) async {
//     Uri myUri = Uri.parse(filePath);
//     File audioFile = new File.fromUri(myUri);
//     Uint8List bytes;
//     await audioFile.readAsBytes().then((value) {
//       bytes = Uint8List.fromList(value);
//       //print('reading of bytes is completed');
//     });
//     return bytes;
//   }

//   Future<void> feedHim(String path) async {
//     Uint8List data = await _readFileByte(path);
//     return playerModule.feedFromStream(data);
//   }

//   void pauseResumeRecorder() async {
//     if (recorderModule.isPaused) {
//       await recorderModule.resumeRecorder();
//     } else {
//       await recorderModule.pauseRecorder();
//       assert(recorderModule.isPaused);
//     }
//     setState(() {});
//   }

//   void seekToPlayer(int milliSecs) async {
//     //print('-->seekToPlayer');
//     if (playerModule.isPlaying)
//       await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
//     //print('<--seekToPlayer');
//   }

//   void Function() onPauseResumeRecorderPressed() {
//     if (recorderModule == null) return null;
//     if (recorderModule.isPaused || recorderModule.isRecording) {
//       return pauseResumeRecorder;
//     }
//     return null;
//   }

//   void startStopRecorder() {
//     //print('start stop recorder');
//     if (recorderModule.isRecording || recorderModule.isPaused)
//       stopRecorder();
//     else
//       startRecorder();
//   }

//   void Function() onStartRecorderPressed() {
//     // Disable the button if the selected codec is not supported
//     if (recorderModule == null || !_encoderSupported) return null;
//     if (_media == Media.stream && _codec != Codec.pcm16) return null;
//     return startStopRecorder;
//   }

//   AssetImage recorderAssetImage() {
//     if (onStartRecorderPressed() == null)
//       return AssetImage('assets/ic_mic_disabled.png');
//     return (recorderModule.isStopped)
//         ? AssetImage('assets/ic_mic.png')
//         : AssetImage('assets/ic_stop.png');
//   }

//   ///////////////////////to here///////////////////////
//   @override
//   void initState() {
//     super.initState();
//     init();

//     focusNode.addListener(onFocusChange);
//     /* searchEditingController.addListener(() {
//       listScrollController.
//     });*/
//     listScrollController.addListener(_scrollListener);
//     groupChatId = '';
//     isLoading = false;
//     isShowSticker = false;
//     imageUrl = '';

//     readLocal();
//     Future.microtask(() {
//       //_prepare();
//     });
//   }

//   void onFocusChange() {
//     if (focusNode.hasFocus) {
//       // Hide sticker when keyboard appear
//       setState(() {
//         isShowSticker = false;
//       });
//     }
//   }

//   readLocal() async {
//     prefs = await SharedPreferences.getInstance();
//     id = prefs.getString('id') ?? '';
//     if (id.hashCode <= peerId.hashCode) {
//       groupChatId = '$id-$peerId';
//     } else {
//       groupChatId = '$peerId-$id';
//     }

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(id)
//         .update({'chattingWith': peerId, 'active': true});

//     setState(() {});
//   }

//   void getSticker() {
//     // Hide keyboard when sticker appear
//     focusNode.unfocus();
//     setState(() {
//       isShowSticker = !isShowSticker;
//     });
//   }

//   Future uploadFile() async {
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference reference = FirebaseStorage.instance.ref().child(fileName);

//     (await reference.putFile(imageFile)).ref.getDownloadURL().then((value) {
//       if (value != null && value.isNotEmpty) {
//         setState(() {
//           isLoading = false;
//           onSendMessage(value, 1);
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         EdgeAlert.show(context,
//             title: 'Uh oh!',
//             description: 'This file is not an image.',
//             gravity: EdgeAlert.BOTTOM,
//             icon: Icons.error,
//             backgroundColor: Colors.deepPurple[900]);
//       }
//     });
//   }

//   Future uploadFiles(String path) async {
//     setState(() {
//       isLoading = true;
//     });
//     //print('lara1 $path');
//     imageFile = File(path);
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//     Reference reference = FirebaseStorage.instance.ref().child(fileName);
//     (await reference.putFile(imageFile)).ref.getDownloadURL().then((value) {
//       if (value != null && value.isNotEmpty) {
//         setState(() {
//           isLoading = false;
//           onSendMessage(value, 2);
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         EdgeAlert.show(context,
//             title: 'Uh oh!',
//             description: 'This file is not an audio.',
//             gravity: EdgeAlert.BOTTOM,
//             icon: Icons.error,
//             backgroundColor: Colors.deepPurple[900]);
//       }
//     });
//   }

//   void onSendMessage(String content, int type) {
//     // type: 0 = text, 1 = image, 2 = sticker

//     if (content.trim() != '') {
//       textEditingController.clear();
//       String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
//       /*var recents = FirebaseFirestore.instance
//           .collection('messages')
//           .doc(groupChatId);*/

//       var documentReference = FirebaseFirestore.instance
//           .collection('messages')
//           .doc(groupChatId)
//           .collection(groupChatId)
//           .doc(timestamp)
//           .set(
//         {
//           'idFrom': id,
//           'idTo': peerId,
//           'timestamp': timestamp,
//           'content': content,
//           'type': type,
//           'seen': false,
//         },
//       );

//       listScrollController.animateTo(0.0,
//           duration: Duration(milliseconds: 300), curve: Curves.easeOut);
//     } else {
//       /*EdgeAlert.show(context,
//           title: 'Uh oh!',
//           description: 'Nothing to send.',
//           gravity: EdgeAlert.BOTTOM,
//           icon: Icons.error,
//           backgroundColor: Colors.red[900]);*/
//     }
//   }

//   List<bool> _isChecked = [];
//   Widget buildItem(int index, DocumentSnapshot document) {
//     if (document.data()['idFrom'] == id) {
//       // Right (my message)
//       //print( _isChecked[index]);
//       return Row(
//         children: <Widget>[
//           if (widget.delete)
//             /* Checkbox(value:!_isChecked[index] , onChanged: ( val){
//              setState(
//                    () {
//                  _isChecked[index] = val;
//                },
//              );
//            }),*/
//             GestureDetector(
//               onTap: () {
//                 deleteMsg(document.reference);
//               },
//               child: Icon(
//                 Icons.remove_circle_outlined,
//                 color: Colors.redAccent,
//               ),
//             ),
//           if (document.data()['type'] == 0)
//             Container(
//               child: Text(
//                 document.data()['content'],
//                 style: TextStyle(fontSize: 13, color: Colors.white),
//               ),
//               padding: EdgeInsets.all(16),
//               width: 200.0,
//               decoration: BoxDecoration(
//                   color: Colors.blue,
//                   borderRadius: BorderRadius.circular(10.0)),
//               margin: EdgeInsets.only(
//                   bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//             )
//           else if (document.data()['type'] == 1)

//             // Image
//             Container(
//               child: FlatButton(
//                 child: Material(
//                   child: CachedNetworkImage(
//                     placeholder: (context, url) => Container(
//                       child: CircularProgressIndicator(
//                         valueColor: AlwaysStoppedAnimation<Color>(themeColor),
//                       ),
//                       width: 200.0,
//                       height: 200.0,
//                       padding: EdgeInsets.all(70.0),
//                       decoration: BoxDecoration(
//                         color: greyColor2,
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(8.0),
//                         ),
//                       ),
//                     ),
//                     errorWidget: (context, url, error) => Material(
//                       child: Image.asset(
//                         'assets/profile.png',
//                         width: 200.0,
//                         height: 200.0,
//                         fit: BoxFit.cover,
//                       ),
//                       borderRadius: BorderRadius.all(
//                         Radius.circular(8.0),
//                       ),
//                       clipBehavior: Clip.hardEdge,
//                     ),
//                     imageUrl: document.data()['content'],
//                     width: 200.0,
//                     height: 200.0,
//                     fit: BoxFit.cover,
//                   ),
//                   borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                   clipBehavior: Clip.hardEdge,
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) =>
//                               FullPhoto(url: document.data()['content'])));
//                 },
//                 padding: EdgeInsets.all(0),
//               ),
//               margin: EdgeInsets.only(
//                   bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//             )
//           else if (document.data()['type'] == 2)

//             // Sticker
//             Container(
//               child: Sound(
//                 filePath: document.data()['content'],
//               ),
//             )
//           else if (document.data()['type'] == 3)
//             Container(
//               child: Image.asset(
//                 'images${document.data()['content']}.png',
//                 width: 100.0,
//                 height: 100.0,
//                 fit: BoxFit.contain,
//               ),
//               margin: EdgeInsets.only(
//                   bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
//             )
//           else if (document.data()['type'] == 4)
//             InkWell(
//                 onTap: () {
//                   Navigator.of(context).push(MaterialPageRoute(
//                       builder: (context) => VideoApp(
//                             url: document.data()['content'],
//                           )));
//                 },
//                 child: //Text('${document.data()['content']}')
//                     VideoImage(
//                   filePath: '${document.data()['content']}',
//                 ))
//         ],
//         mainAxisAlignment: MainAxisAlignment.end,
//       );
//     } else {
//       if (!document.data()['seen']) {
//         FirebaseFirestore.instance
//             .collection('messages')
//             .doc(groupChatId)
//             .collection(groupChatId)
//             .doc(document.id)
//             .update({
//           'seen': true,
//         });
//         // updateLast(document.data()['timestamp']);
//       }
//       // Left (peer message)
//       return Container(
//         child: Column(
//           children: <Widget>[
//             Row(
//               children: <Widget>[
//                 if (widget.delete)
//                   GestureDetector(
//                     onTap: () {
//                       deleteMsg(document.reference);
//                     },
//                     child: Icon(
//                       Icons.remove_circle_outlined,
//                       color: Colors.redAccent,
//                     ),
//                   ),
//                 isLastMessageLeft(index)
//                     ? Material(
//                         child: peerAvatar != ''
//                             ? CachedNetworkImage(
//                                 placeholder: (context, url) => Container(
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 1.0,
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         themeColor),
//                                   ),
//                                   width: 35.0,
//                                   height: 35.0,
//                                   padding: EdgeInsets.all(10.0),
//                                 ),
//                                 imageUrl: peerAvatar,
//                                 errorWidget: (context, url, error) => Material(
//                                   child: Image.asset(
//                                     'assets/profile.png',
//                                     width: 35.0,
//                                     height: 35.0,
//                                     fit: BoxFit.cover,
//                                   ),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(20.0),
//                                   ),
//                                   clipBehavior: Clip.hardEdge,
//                                 ),
//                                 width: 35.0,
//                                 height: 35.0,
//                                 fit: BoxFit.cover,
//                               )
//                             : Container(
//                                 padding: EdgeInsets.all(10.0),
//                                 child: Material(
//                                   child: Image.asset(
//                                     'assets/profile.png',
//                                     width: 35.0,
//                                     height: 35.0,
//                                     fit: BoxFit.cover,
//                                   ),
//                                   borderRadius: BorderRadius.all(
//                                     Radius.circular(20.0),
//                                   ),
//                                   clipBehavior: Clip.hardEdge,
//                                 ),
//                               ),
//                         borderRadius: BorderRadius.all(
//                           Radius.circular(18.0),
//                         ),
//                         clipBehavior: Clip.hardEdge,
//                       )
//                     : Container(width: 35.0),
//                 if (document.data()['type'] == 0)
//                   Container(
//                     child: Text(
//                       document.data()['content'],
//                       style: TextStyle(fontSize: 13, color: Colors.white),
//                     ),
//                     padding: EdgeInsets.all(16),
//                     width: 200.0,
//                     decoration: BoxDecoration(
//                         color: Colors.black.withBlue(50),
//                         borderRadius: BorderRadius.circular(10)),
//                     margin: EdgeInsets.only(left: 10.0),
//                   )
//                 else if (document.data()['type'] == 1)
//                   Container(
//                     child: FlatButton(
//                       child: Hero(
//                         tag: 'zoom',
//                         child: Material(
//                           child: CachedNetworkImage(
//                             placeholder: (context, url) => Container(
//                               child: CircularProgressIndicator(
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(themeColor),
//                               ),
//                               width: 200.0,
//                               height: 200.0,
//                               padding: EdgeInsets.all(70.0),
//                               decoration: BoxDecoration(
//                                 color: greyColor2,
//                                 borderRadius: BorderRadius.all(
//                                   Radius.circular(8.0),
//                                 ),
//                               ),
//                             ),
//                             errorWidget: (context, url, error) => Material(
//                               child: Image.asset(
//                                 'assets/profile.png',
//                                 width: 200.0,
//                                 height: 200.0,
//                                 fit: BoxFit.cover,
//                               ),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(8.0),
//                               ),
//                               clipBehavior: Clip.hardEdge,
//                             ),
//                             imageUrl: document.data()['content'],
//                             width: 200.0,
//                             height: 200.0,
//                             fit: BoxFit.cover,
//                           ),
//                           borderRadius: BorderRadius.all(Radius.circular(8.0)),
//                           clipBehavior: Clip.hardEdge,
//                         ),
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => FullPhoto(
//                                     url: document.data()['content'])));
//                       },
//                       padding: EdgeInsets.all(0),
//                     ),
//                     margin: EdgeInsets.only(left: 10.0),
//                   )
//                 else if (document.data()['type'] == 2)
//                   Container(
//                     child: Sound(
//                       filePath: document.data()['content'],
//                     ),
//                   )
//                 else if (document.data()['type'] == 3)
//                   Container(
//                     child: Image.asset(
//                       'images${document.data()['content']}.png',
//                       width: 100.0,
//                       height: 100.0,
//                       fit: BoxFit.contain,
//                     ),
//                     margin: EdgeInsets.only(
//                         bottom: isLastMessageRight(index) ? 20.0 : 10.0,
//                         right: 10.0),
//                   )
//                 else if (document.data()['type'] == 4)
//                   InkWell(
//                       onTap: () {
//                         Navigator.of(context).push(MaterialPageRoute(
//                             builder: (context) => VideoApp()));
//                       },
//                       child: VideoImage(
//                         filePath: '${document.data()['content']}',
//                       ))
//               ],
//             ),

//             // Time
//             isLastMessageLeft(index)
//                 ? Container(
//                     child: Text(
//                       DateFormat('dd MMM kk:mm').format(
//                           DateTime.fromMillisecondsSinceEpoch(
//                               int.parse(document.data()['timestamp']))),
//                       style: TextStyle(
//                           color: greyColor,
//                           fontSize: 12.0,
//                           fontStyle: FontStyle.italic),
//                     ),
//                     margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
//                   )
//                 : Container()
//           ],
//           crossAxisAlignment: CrossAxisAlignment.start,
//         ),
//         margin: EdgeInsets.only(bottom: 10.0),
//       );
//     }
//   }

//   bool isLastMessageLeft(int index) {
//     if ((index > 0 &&
//             listMessage != null &&
//             listMessage[index - 1].data()['idFrom'] == id) ||
//         index == 0) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   bool isLastMessageRight(int index) {
//     if ((index > 0 &&
//             listMessage != null &&
//             listMessage[index - 1].data()['idFrom'] != id) ||
//         index == 0) {
//       return true;
//     } else {
//       return false;
//     }
//   }

//   Future<bool> onBackPress() async {
//     await FirebaseFirestore.instance
//         .collection('users')
//         .doc(id)
//         .update({'chattingWith': null, 'active': false});
//     // Navigator.of(context).pop();

//     return Future.value(false);
//   }

//   @override
//   void dispose() async {
//     onBackPress();
//     super.dispose();
//     cancelPlayerSubscriptions();
//     cancelRecorderSubscriptions();
//     cancelRecordingDataSubscription();
//     releaseFlauto();
//     // Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider.value(
//         value: widget.model,
//         child: Consumer<ThemeModel>(
//             builder: (context, model, __) => WillPopScope(
//                   child: Column(
//                     children: <Widget>[
//                       // List of messages
//                       if (widget.showsearch)
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: 10),
//                           color: Colors.black54,
//                           child: TextField(
//                             controller: searchEditingController,
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                             decoration: InputDecoration(
//                                 suffixIcon: GestureDetector(
//                                   onTap: widget.onClick,
//                                   child: Icon(
//                                     Icons.close,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 hintText: "Search messages...",
//                                 hintStyle: TextStyle(
//                                   color: Colors.white70,
//                                   fontSize: 16,
//                                 ),
//                                 border: InputBorder.none),
//                           ),
//                         ),
//                       buildListMessage(),

//                       // Sticker
//                       // Input content
//                       buildInput(
//                           model.appLocal.languageCode == 'ar'
//                               ? 'أكتب الرسالة هنا'
//                               : 'Type message here...',
//                           model),
//                       (isShowSticker
//                           ? FlutterToggleTab(
//                               // width in percent, to set full width just set to 100
//                               width: 100,
//                               borderRadius: 0,
//                               height: 50,
//                               initialIndex: selectedIndex,
//                               unSelectedBackgroundColors: [
//                                 Colors.black.withBlue(50)
//                               ],
//                               selectedBackgroundColors: [
//                                 Colors.black.withBlue(50)
//                               ],
//                               selectedTextStyle: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.w700),
//                               unSelectedTextStyle: TextStyle(
//                                   color: Colors.grey,
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w500),
//                               labels: ["", "", "", "", "", "", ""],
//                               icons: [
//                                 Icons.favorite_border_sharp,
//                                 Icons.trending_up_sharp,
//                                 CupertinoIcons.hand_raised_slash_fill,
//                                 Icons.theater_comedy,
//                                 Icons.three_mp,
//                                 Icons.dry_cleaning,
//                                 Icons.cleaning_services_sharp
//                               ],
//                               selectedLabelIndex: (index) {
//                                 setState(() {
//                                   selectedIndex = index;
//                                 });
//                               },
//                             )
//                           : Container()),
//                       (isShowSticker
//                           ? buildSticker(selectedIndex)
//                           : Container()),
//                     ],
//                   ),
//                   onWillPop: onBackPress,
//                 )));
//   }

// //////////////////////////////
//   Widget buildSticker(int index) {
//     switch (index) {
//       case 0:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: [
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group292', 3),
//                 child: Image.asset(
//                   'images/Group292.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group295', 3),
//                 child: Image.asset(
//                   'images/Group295.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group296', 3),
//                 child: Image.asset(
//                   'images/Group296.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group297', 3),
//                 child: Image.asset(
//                   'images/Group297.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group298', 3),
//                 child: Image.asset(
//                   'images/Group298.png',
//                   width: 200.0,
//                   height: 100.0,
//                   fit: BoxFit.fill,
//                 ),
//               ),
//             ],
//           ),
//           decoration: BoxDecoration(
//             border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//             color: Colors.black.withBlue(50),
//           ),
//           padding: EdgeInsets.all(5.0),
//           // width: double.infinity,
//           //   height: 180.0,
//         );
//         break;
//       case 1:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group290', 3),
//                 child: Image.asset(
//                   'images/Group290.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group291', 3),
//                 child: Image.asset(
//                   'images/Group291.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group293', 3),
//                 child: Image.asset(
//                   'images/Group293.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ],
//             //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//           //  height: 180.0,
//         );
//         break;
//       case 2:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group285', 3),
//                 child: Image.asset(
//                   'images/Group285.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group286', 3),
//                 child: Image.asset(
//                   'images/Group286.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group312', 3),
//                 child: Image.asset(
//                   'images/Group312.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group313', 3),
//                 child: Image.asset(
//                   'images/Group313.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group314', 3),
//                 child: Image.asset(
//                   'images/Group314.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ],
//             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//         );
//         break;
//       case 3:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group287', 3),
//                 child: Image.asset(
//                   'images/Group287.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group288', 3),
//                 child: Image.asset(
//                   'images/Group288.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group289', 3),
//                 child: Image.asset(
//                   'images/Group289.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group294', 3),
//                 child: Image.asset(
//                   'images/Group294.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ],
//             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//         );
//         break;
//       case 4:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group281', 3),
//                 child: Image.asset(
//                   'images/Group281.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group299', 3),
//                 child: Image.asset(
//                   'images/Group299.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group300', 3),
//                 child: Image.asset(
//                   'images/Group300.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group301', 3),
//                 child: Image.asset(
//                   'images/Group301.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group302', 3),
//                 child: Image.asset(
//                   'images/Group302.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group303', 3),
//                 child: Image.asset(
//                   'images/Group303.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group304', 3),
//                 child: Image.asset(
//                   'images/Group304.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group305', 3),
//                 child: Image.asset(
//                   'images/Group305.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Container(),
//             ],
//             //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//         );
//         break;
//       case 5:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group270', 3),
//                 child: Image.asset(
//                   'images/Group270.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group272', 3),
//                 child: Image.asset(
//                   'images/Group272.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group306', 3),
//                 child: Image.asset(
//                   'images/Group306.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group307', 3),
//                 child: Image.asset(
//                   'images/Group307.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group308', 3),
//                 child: Image.asset(
//                   'images/Group308.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group309', 3),
//                 child: Image.asset(
//                   'images/Group309.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group310', 3),
//                 child: Image.asset(
//                   'images/Group310.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group311', 3),
//                 child: Image.asset(
//                   'images/Group311.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//             ],
//             //  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//         );
//         break;
//       case 6:
//         return Container(
//           child: GridView.count(
//             crossAxisCount: 4,
//             // crossAxisSpacing: 10.0,
//             // mainAxisSpacing: 10.0,
//             shrinkWrap: true,
//             children: <Widget>[
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group273', 3),
//                 child: Image.asset(
//                   'images/Group273.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group274', 3),
//                 child: Image.asset(
//                   'images/Group274.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group275', 3),
//                 child: Image.asset(
//                   'images/Group275.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group276', 3),
//                 child: Image.asset(
//                   'images/Group276.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group277', 3),
//                 child: Image.asset(
//                   'images/Group277.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group278', 3),
//                 child: Image.asset(
//                   'images/Group278.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group279', 3),
//                 child: Image.asset(
//                   'images/Group279.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               FlatButton(
//                 onPressed: () => onSendMessage('/Group280', 3),
//                 child: Image.asset(
//                   'images/Group280.png',
//                   width: 100.0,
//                   height: 100.0,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               Container(),
//             ],
//             // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           ),
//           decoration: BoxDecoration(
//               border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//               color: Colors.black.withBlue(50)),
//           padding: EdgeInsets.all(5.0),
//         );
//         break;
//     }
//   }

// ///////////////////////////////
//   Widget buildInput(String text, ThemeModel model) {
//     return Container(
//       margin: EdgeInsets.all(10),
//       child: Row(
//         children: <Widget>[
//           // Button send image
//           Material(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 1.0),
//               child: IconButton(
//                 icon: Icon(Icons.attach_file),
//                 onPressed: () {
//                   loadFiles();
//                 }, // getImage,
//                 color: Colors.white,
//               ),
//             ),
//             color: Colors.black.withBlue(50),
//           ),
//           Material(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 1.0),
//               child: IconButton(
//                 icon: Icon(
//                   Icons.face,
//                   color: Colors.white,
//                 ),
//                 onPressed: getSticker,
//                 color: primaryColor,
//               ),
//             ),
//             color: Colors.black.withBlue(50),
//           ),
//           Material(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 1.0),
//               child: IconButton(
//                 icon: _isRecording
//                     ? Icon(
//                         Icons.fiber_smart_record,
//                         color: Colors.green,
//                       )
//                     : Icon(Icons.mic),
//                 onPressed: () {
//                   //onStartRecorderPressed(),
//                   Navigator.of(context)
//                       .push(MaterialPageRoute(builder: (context) => SPTOTE()))
//                       .then((res) {
//                     if (res != null && res.toString().isNotEmpty)
//                       onSendMessage('$res', 0);
//                   });
//                 },
//                 color: Colors.blue,
//               ),
//             ),
//             color: Colors.black.withBlue(50),
//           ),
//           // Edit text
//           Flexible(
//             child: Container(
//               child: TextField(
//                 onSubmitted: (value) {
//                   onSendMessage(textEditingController.text, 0);
//                 },
//                 style: TextStyle(color: Colors.white, fontSize: 15.0),
//                 controller: textEditingController,
//                 decoration: InputDecoration.collapsed(
//                   hintText: _isRecording
//                       ? this._recorderTxt
//                       : text == 'ar'
//                           ? 'أكتب الرسالة هنا'
//                           : 'Type Message...',
//                   hintStyle: TextStyle(color: greyColor),
//                 ),
//                 focusNode: focusNode,
//               ),
//             ),
//           ),

//           // Button send message
//           Material(
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 8.0),
//               child: isLoading
//                   ? Loading()
//                   : _isRecording
//                       ? IconButton(
//                           onPressed: cancelRecorder,
//                           icon: Icon(
//                             Icons.cancel,
//                             color: Colors.redAccent,
//                             size: 30,
//                           ))
//                       : IconButton(
//                           icon: Icon(Icons.send),
//                           /*  onPressed:_recording.status==RecordingStatus.Recording?null: () =>
//                           onSendMessage(textEditingController.text, 0),*/
//                           onPressed: () =>
//                               onSendMessage(textEditingController.text, 0),
//                           color: Colors.white,
//                         ),
//             ),
//             color: Colors.black.withBlue(50),
//           ),
//         ],
//       ),
//       width: double.infinity,
//       height: 50.0,
//       decoration: BoxDecoration(
//         border: Border(top: BorderSide(color: greyColor2, width: 0.5)),
//         color: Colors.black.withBlue(50),
//       ),
//     );
//   }

//   Widget buildListMessage() {
//     return Flexible(
//       child: groupChatId == ''
//           ? Center(
//               child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(themeColor)))
//           : StreamBuilder(
//               stream: FirebaseFirestore.instance
//                   .collection('messages')
//                   .doc(groupChatId)
//                   .collection(groupChatId)
//                   .orderBy('timestamp', descending: true)
//                   .limit(_limit)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return /*Center(
//                       child: CircularProgressIndicator(
//                           valueColor:
//                               AlwaysStoppedAnimation<Color>(themeColor)))*/
//                       Container();
//                 } else {
//                   listMessage.addAll(snapshot.data.docs);
//                   _isChecked =
//                       List<bool>.filled(snapshot.data.docs.length, false);

//                   return ListView.builder(
//                     padding: EdgeInsets.all(10.0),
//                     itemBuilder: (context, index) =>
//                         searchEditingController.text.isEmpty
//                             ? buildItem(index, snapshot.data.docs[index])
//                             : snapshot.data.docs[index]
//                                     .data()['content']
//                                     .toString()
//                                     .contains(searchEditingController.text)
//                                 ? buildItem(index, snapshot.data.docs[index])
//                                 : Container(),
//                     itemCount: snapshot.data.docs.length,
//                     reverse: true,
//                     controller: listScrollController,
//                   );
//                 }
//               },
//             ),
//     );
//   }

//   void deleteMsg(DocumentReference reference) {
//     reference.delete();
//   }

//   File _selectedMedia;
//   Future pickImage(bool src) async {
//     var pickedFile = await Utils.pickImage(context, src);
//     if (pickedFile != null) {
//       setState(() {
//         isLoading = true;
//         _selectedMedia = File(pickedFile.path);
//       });
//       // ImagePicker imagePicker = ImagePicker();
//       //PickedFile pickedFile;

//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference reference = FirebaseStorage.instance.ref().child(fileName);

//       (await reference.putFile(_selectedMedia))
//           .ref
//           .getDownloadURL()
//           .then((value) {
//         if (value != null && value.isNotEmpty) {
//           setState(() {
//             isLoading = false;
//             onSendMessage(value, 1);
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           EdgeAlert.show(context,
//               title: 'Uh oh!',
//               description: 'This file is not an image.',
//               gravity: EdgeAlert.BOTTOM,
//               icon: Icons.error,
//               backgroundColor: Colors.deepPurple[900]);
//         }
//       });
//     }
//   }

//   Future pickVideo(bool src) async {
//     var pickedFile = await Utils.pickVideo(context, src);
//     if (pickedFile != null) {
//       setState(() {
//         isLoading = true;
//         _selectedMedia = File(pickedFile.path);
//       });
//       String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//       Reference reference = FirebaseStorage.instance.ref().child(fileName);

//       (await reference.putFile(_selectedMedia))
//           .ref
//           .getDownloadURL()
//           .then((value) {
//         if (value != null && value.isNotEmpty) {
//           setState(() {
//             isLoading = false;
//             onSendMessage(value, 4);
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//           EdgeAlert.show(context,
//               title: 'Uh oh!',
//               description: 'This file is not an image.',
//               gravity: EdgeAlert.BOTTOM,
//               icon: Icons.error,
//               backgroundColor: Colors.deepPurple[900]);
//         }
//       });
//     }
//   }

//   loadFiles() {
//     showCupertinoModalPopup(
//         context: context,
//         builder: (BuildContext context) => CupertinoActionSheet(
//               title: Text(
//                 "Select FIle",
//                 style: TextStyle(
//                     color: Theme.of(context).primaryColor,
//                     fontWeight: FontWeight.normal,
//                     fontSize: 18),
//               ),
//               actions: [
//                 new CupertinoActionSheetAction(
//                     child: Text(
//                       "Image from Gallery",
//                       style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.normal,
//                           fontSize: 18),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       pickImage(true);
//                     }),
//                 new CupertinoActionSheetAction(
//                     child: Text(
//                       "Video from Gallery",
//                       style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.normal,
//                           fontSize: 18),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       pickVideo(true);
//                     }),
//                 new CupertinoActionSheetAction(
//                     //leading: new Icon(CupertinoIcons.directions_car),
//                     child: Text(
//                       "Image from Camera",
//                       style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.normal,
//                           fontSize: 18),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       pickImage(false);
//                     }),
//                 new CupertinoActionSheetAction(
//                     //leading: new Icon(CupertinoIcons.directions_car),
//                     child: Text(
//                       "Video from Camera",
//                       style: TextStyle(
//                           color: Theme.of(context).primaryColor,
//                           fontWeight: FontWeight.normal,
//                           fontSize: 18),
//                     ),
//                     onPressed: () {
//                       Navigator.pop(context);
//                       pickVideo(false);
//                     }),
//               ],
//               //_createListView(context, changeName),
//               cancelButton: CupertinoActionSheetAction(
//                 child: Text("Cancel"),
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ));
//   }
// }
