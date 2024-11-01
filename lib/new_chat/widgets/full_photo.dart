import 'package:flutter/material.dart';
import 'package:moi/const.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FullPhoto extends StatelessWidget {
  final String url;

  FullPhoto({required Key key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ////print('photo ${url}');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FULL PHOTO',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(
        url: url,
        key: null,
      ),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final String url;

  FullPhotoScreen({required Key? key, required this.url}) : super(key: key);

  @override
  State createState() => FullPhotoScreenState(url: url);
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  final String url;

  FullPhotoScreenState({Key? key, required this.url});

  @override
  void initState() {
    super.initState();
    //print('pfp $url');
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
        tag: 'zoom',
        child: Container(
          child: PhotoView(
            imageProvider: NetworkImage(url, scale: 1),
            loadingBuilder: (context, event) {
              if (event == null) {
                return const Center(
                  child: Text("Loading"),
                );
              }
              final value =
                  event.cumulativeBytesLoaded / event.cumulativeBytesLoaded;

              final percentage = (100 * value).floor();
              return Center(
                child: Text("$percentage%"),
              );
            },
          ),
        ));
  }
}
