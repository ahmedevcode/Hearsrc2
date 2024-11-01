import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_sound/flutter_sound.dart';

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

class Sound extends StatefulWidget {
  final String filePath;

  const Sound({Key? key, required this.filePath}) : super(key: key);

  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<Sound> {
  bool _isRecording = false;
  List<String> _path = [];
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  StreamSubscription? _recordingDataSubscription;

  FlutterSoundPlayer playerModule = FlutterSoundPlayer();
  FlutterSoundRecorder recorderModule = FlutterSoundRecorder();

  String _recorderTxt = '00:00:00';
  String _playerTxt = '00:00:00';
  double? _dbLevel;

  double sliderCurrentPosition = 0.0;
  double maxDuration = 1.0;
  Media _media = Media.remoteExampleFile;
  Codec _codec = Codec.aacADTS;

  bool _encoderSupported = true; // Optimist
  bool _decoderSupported = true; // Optimist

  // Whether the user wants to use the audio player features
  bool _isAudioPlayer = false;

  double? _duration = null;
  StreamController<Food>? recordingDataController;
  IOSink? sink;

  Future<void> init() async {
    if (Platform.isAndroid) {
      await copyAssets();
    }
  }

  Future<void> copyAssets() async {
    Uint8List dataBuffer =
        (await rootBundle.load("images/logo_only.png")).buffer.asUint8List();
    String path = (await playerModule.getResourcePath())! + "/images";
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
    await File(path + '/logo_only.png').writeAsBytes(dataBuffer);
  }

  @override
  void initState() {
    super.initState();
    init();
    getDuration();
  }

  void cancelRecorderSubscriptions() {
    if (_recorderSubscription != null) {
      _recorderSubscription?.cancel();
      _recorderSubscription = null;
    }
  }

  void cancelPlayerSubscriptions() {
    if (_playerSubscription != null) {
      _playerSubscription?.cancel();
      _playerSubscription = null;
    }
  }

  void cancelRecordingDataSubscription() {
    if (_recordingDataSubscription != null) {
      _recordingDataSubscription?.cancel();
      _recordingDataSubscription = null;
    }
    recordingDataController = null;
    if (sink != null) {
      sink?.close();
      sink = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    cancelPlayerSubscriptions();
    cancelRecorderSubscriptions();
    cancelRecordingDataSubscription();
    releaseFlauto();
  }

  Future<void> releaseFlauto() async {
    try {} catch (e) {}
  }

  Future<void> getDuration() async {}

  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }

  void _addListeners() {
    cancelPlayerSubscriptions();
    _playerSubscription = playerModule.onProgress!.listen((e) {
      if (e != null) {
        maxDuration = e.duration.inMilliseconds.toDouble();
        if (maxDuration <= 0) maxDuration = 0.0;

        sliderCurrentPosition =
            min(e.position.inMilliseconds.toDouble(), maxDuration);
        if (sliderCurrentPosition < 0.0) {
          sliderCurrentPosition = 0.0;
        }

        DateTime date = new DateTime.fromMillisecondsSinceEpoch(
            e.position.inMilliseconds,
            isUtc: true);
        String txt = DateFormat('mm:ss:SS', 'en_GB').format(date);
        this.setState(() {
          this._playerTxt = txt.substring(0, 8);
        });
      }
    });
  }

  // Future<Uint8List> _readFileByte(String filePath) async {
  //   Uri myUri = Uri.parse(filePath);
  //   File audioFile = new File.fromUri(myUri);
  //   Uint8List bytes;
  //   await audioFile.readAsBytes().then((value) {
  //     bytes = Uint8List.fromList(value);
  //     //print('reading of bytes is completed');
  //   });
  //   return bytes;
  // }

  // Future<void> feedHim(String path) async {
  //  // Uint8List data = await _readFileByte(path);
  //   return playerModule.feedFromStream(data);
  // }

  Future<void> startPlayer() async {
    try {
      Uint8List dataBuffer;
      String audioFilePath;
      Codec codec = _codec;
      if (_media == Media.remoteExampleFile) {
        if (await fileExists(widget.filePath)) audioFilePath = widget.filePath;
        // We have to play an example audio file loaded via a URL
        audioFilePath = widget.filePath;
      }

      // Check whether the user wants to use the audio player features
      if (_isAudioPlayer) {
        String albumArtUrl;
        String albumArtAsset;
        String albumArtFile;

        albumArtFile =
            ((await playerModule.getResourcePath())! + "/images/logo_only.png");
        //  //print(albumArtFile);

//         final track = Track(
// //           trackPath: audioFilePath,
// //           codec: _codec,
// //           dataBuffer: dataBuffer,
// // //          trackTitle: "This is a record",
// // //          trackAuthor: "from flutter_sound",
// //           albumArtUrl: albumArtUrl,
// //           albumArtAsset: albumArtAsset,
//           albumArtFile: albumArtFile,
//         );
        // await playerModule.startPlayerFromTrack(
        //     defaultPauseResume: false,
        //     removeUIWhenStopped: true, whenFinished: () {
        //   //print('I hope you enjoyed listening to this song');
        //   stopPlayer();
        //   setState(() {});
        // }, onSkipBackward: () {
        //   //print('Skip backward');
        //   stopPlayer();
        //   startPlayer();
        // }, onSkipForward: () {
        //   //print('Skip forward');
        //   stopPlayer();
        //   startPlayer();
        // }, onPaused: (bool b) {
        //   if (b)
        //     playerModule.pausePlayer();
        //   else
        //     playerModule.resumePlayer();
        // });
      } else {
        await playerModule.startPlayer(
            //fromURI: !audioFilePath,
            codec: codec,
            sampleRate: SAMPLE_RATE,
            whenFinished: () {
              //print('Play finished');
              stopPlayer();
              setState(() {
                //   stopPlayer();
              });
            });
      }
      _addListeners();
      setState(() {});
      //print('<--- startPlayer');
    } catch (err) {
      //print('error: $err');
    }
  }

  Future<void> stopPlayer() async {
    try {
      await playerModule.stopPlayer();
      //print('stopPlayer');
      if (_playerSubscription != null) {
        _playerSubscription!.cancel();
        _playerSubscription = null;
      }
      sliderCurrentPosition = 0.0;
    } catch (err) {
      //print('error: $err');
    }
    this.setState(() {});
  }

  void pauseResumePlayer() async {
    if (playerModule.isPlaying) {
      await playerModule.pausePlayer();
    } else {
      await playerModule.resumePlayer();
    }
    setState(() {});
  }

  void pauseResumeRecorder() async {
    if (recorderModule.isPaused) {
      await recorderModule.resumeRecorder();
    } else {
      await recorderModule.pauseRecorder();
      assert(recorderModule.isPaused);
    }
    setState(() {});
  }

  void seekToPlayer(int milliSecs) async {
    //print('-->seekToPlayer');
    if (playerModule.isPlaying)
      await playerModule.seekToPlayer(Duration(milliseconds: milliSecs));
    //print('<--seekToPlayer');
  }

  void Function()? onPauseResumePlayerPressed() {
    if (playerModule == null) return null;
    if (playerModule.isPaused || playerModule.isPlaying) {
      return pauseResumePlayer;
    }
    return null;
  }

  void Function()? onPauseResumeRecorderPressed() {
    if (recorderModule == null) return null;
    if (recorderModule.isPaused || recorderModule.isRecording) {
      return pauseResumeRecorder;
    }
    return null;
  }

  Future<void> Function()? onStopPlayerPressed() {
    if (playerModule == null) return null;
    return (playerModule.isPlaying || playerModule.isPaused)
        ? stopPlayer
        : null;
  }

  Future<void> Function()? onStartPlayerPressed() {
    if (playerModule == null) return null;
    if (_media == Media.file ||
        _media == Media.stream ||
        _media == Media.buffer) // A file must be already recorded to play it
    {
      if (_path[_codec.index] == null) return null;
    }
    if (_media == Media.remoteExampleFile &&
        _codec != Codec.mp3) // in this example we use just a remote mp3 file
      return startPlayer;

    if (_media == Media.stream && _codec != Codec.pcm16) return null;

    if (_media == Media.stream && _isAudioPlayer) return null;

    // Disable the button if the selected codec is not supported
    if (!(_decoderSupported || _codec == Codec.pcm16)) return null;

    return (playerModule.isStopped) ? startPlayer : null;
  }

  void setCodec(Codec codec) async {
    _encoderSupported = await recorderModule.isEncoderSupported(codec);
    _decoderSupported = await playerModule.isDecoderSupported(codec);

    setState(() {
      _codec = codec;
    });
  }

  @override
  Widget build(BuildContext context) {
//getDuration();

    Widget playerSection = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            FloatingActionButton(
              onPressed: () {},
              child: playerModule.isPlaying
                  ? IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: () => playerModule.pausePlayer(),
                    )
                  : IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: playerModule.isPaused
                          ? playerModule.resumePlayer
                          : startPlayer,
                    ),
            ),
            Container(
                //  height: 30.0,
                child: Slider(
                    value: min(sliderCurrentPosition, maxDuration),
                    min: 0.0,
                    max: maxDuration,
                    onChanged: (double value) async {
                      //  await seekToPlayer(value.toInt());
                    },
                    divisions: maxDuration == 0.0 ? 1 : maxDuration.toInt())),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ),
        playerModule.isPlaying
            ? Container(
                child: Text(
                  this._playerTxt,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                ),
              )
            : Container(),
        Container(
          height: 30.0,
          child: Text(_duration != null ? "Duration: $_duration sec." : ''),
        ),
      ],
    );

    return Container(
      child: playerSection,
    );
  }
}
