import 'package:flutter/material.dart';
import 'package:moi/new_chat/widgets/loading.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  final String url;

  const VideoApp({Key? key, required this.url}) : super(key: key);
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  VideoPlayerController? _controller;
  String text = '00:00:00';
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url)
      ..initialize().then((_) {
        _controller?.addListener(() {
          _controller?.position.then((value) {
            setState(() {
              text = value.toString();
            });
          });
        });
        // _controller.value.
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _controller!.value!.isInitialized
          ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: VideoPlayer(_controller!)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('${text} Sec'),
                    )
                  ],
                ),
              ),
            )
          : Loading(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller!.value.isPlaying
                ? _controller!.pause()
                : _controller!.play();
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }
}
