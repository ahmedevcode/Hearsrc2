import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

var kBaseWhiteColor = Colors.white;
var kBlackColor2 = Colors.black;

class Utils {
  static Future<Future> showImageSourceIOS(BuildContext context) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoButton(
            child:
                Text('Open Gallery', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          CupertinoButton(
            child:
                Text('Open Camera', style: TextStyle(color: kBaseWhiteColor)),
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ],
        cancelButton: CupertinoButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  static Future<Future> showImageSourceAndroid(BuildContext context) async {
    final size = MediaQuery.of(context).size;
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        //  backgroundColor: kBlackColor2,
        title: Text('Choose '),
        content: Container(
          height: size.height * 0.22,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => pickImage(context, false),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text('Images Camera'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => pickVideo(context, false),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        Icon(
                          Icons.video_collection,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text('Videos Camera'),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () => pickImage(context, true),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text('Images Gallery'),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => pickVideo(context, true),
                    child: Wrap(
                      direction: Axis.vertical,
                      children: [
                        Icon(
                          Icons.video_collection,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text('Videos Gallery'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget popMenu(BuildContext context) {
    return Container(
      //height: size.height * 0.22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => pickImage(context, false),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Icon(
                      Icons.image_rounded,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text('Images Camera'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => pickVideo(context, false),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Icon(
                      Icons.video_collection,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text('Videos Camera'),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              GestureDetector(
                onTap: () => pickImage(context, true),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Icon(
                      Icons.image_rounded,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text('Images Gallery'),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => pickVideo(context, true),
                child: Wrap(
                  direction: Axis.vertical,
                  children: [
                    Icon(
                      Icons.video_collection,
                      size: 40,
                    ),
                    SizedBox(height: 10),
                    Text('Videos Gallery'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<Future> showPickerDialog(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final res = isIOS
        ? await showImageSourceIOS(context)
        : await showImageSourceAndroid(context);
    return res;
  }

  static Future<ImagePicker> pickImage(BuildContext context, bool res) async {
    // final res = await showPickerDialog(context);

    // if (res == null) return null;
    ImageSource src = res ? ImageSource.gallery : ImageSource.camera;
    ImagePicker imagePicker = ImagePicker();
    return await imagePicker;
  }

  static Future<ImagePicker> pickVideo(BuildContext context, bool res) async {
    //  final res = await showPickerDialog(context);
    // if (res == null) return null;
    ImageSource src = res ? ImageSource.gallery : ImageSource.camera;
    ImagePicker videoPicker = ImagePicker();
    return await videoPicker;
  }
}
