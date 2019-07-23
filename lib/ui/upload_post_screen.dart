import 'dart:async';
import 'dart:io';

import 'package:aperture/ui/utils/post_shared_functions.dart';
import 'package:aperture/view_models/upload_post_bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

const int maxLengthTitle = 128;
const int maxLengthDescription = 1024;

class UploadPostScreen extends StatefulWidget {
  @override
  _UploadPostScreenState createState() => _UploadPostScreenState();
}

class _UploadPostScreenState extends State<UploadPostScreen> {
  String _title = '';
  String _description = '';
  File _image;
  bool _enabledBackButton = true;

  Future<void> _uploadPost() async {
    _enabledBackButton = false;
    uploadPostBloc.changeButton('indicator');

    int code = await uploadPostBloc.uploadPost(_image, _title, _description);
    Navigator.of(context).pop(code);
    //TODO check out the compute function
  }

  @override
  void initState() {
    super.initState();
    uploadPostBloc.init();
  }

  @override
  void dispose() {
    uploadPostBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (!_enabledBackButton) {
          return Future.value(false);
        }

        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('New Post'),
          leading: BackButton(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              GestureDetector(
                onTap: _loadImage,
                child: StreamBuilder<String>(
                  stream: uploadPostBloc.image,
                  initialData: 'initialContainer',
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.data) {
                      case 'initialContainer':
                        return Container(
                          height: 250.0,
                          color: Colors.black26,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ClipOval(
                                  child: Container(
                                    color: Colors.blue,
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 65.0,
                                    ),
                                  ),
                                ),
                              ),
                              const Text(
                                'Click here to\nupload an image',
                                style: TextStyle(fontSize: 20.0),
                              ),
                            ],
                          ),
                        );
                        break;

                      case 'image':
                        return Image.file(
                          _image,
                          fit: BoxFit.fitWidth,
                        );
                    }
                  },
                ),
              ),
              const Divider(
                height: 10.0,
                color: Colors.transparent,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  maxLength: maxLengthTitle,
                  onChanged: (v) => _checkConditions("title", v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Description",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  maxLength: maxLengthDescription,
                  onChanged: (v) => _checkConditions("description", v),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 25.0),
                child: StreamBuilder<String>(
                    stream: uploadPostBloc.buttonWidget,
                    initialData: 'textInactive',
                    builder: (BuildContext context,
                        AsyncSnapshot<String> snapshot) {
                      switch (snapshot.data) {
                        case 'text':
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: MaterialButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 42.0),
                                child: Text(
                                  'Upload Post',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(
                                          color: Colors.white,
                                          fontSize: 23.0),
                                ),
                              ),
                              onPressed: () => _uploadPost(),
                              //showInSnackBar("Login button pressed")),
                            ),
                          );

                        case 'textInactive':
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: MaterialButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 42.0),
                                child: Text(
                                  'Upload Post',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline
                                      .copyWith(
                                          color: Colors.white,
                                          fontSize: 23.0),
                                ),
                              ),
                              onPressed: null,
                              //showInSnackBar("Login button pressed")),
                            ),
                          );
                        case 'indicator':
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(9.0),
                            ),
                            child: MaterialButton(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.blueGrey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 42.0),
                                child: getWhiteCircularIndicator(),
                              ),
                              onPressed: null,
                              //showInSnackBar("Login button pressed")),
                            ),
                          );
                      }
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _loadImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    _checkConditions("image", image);
  }

  void _checkConditions(String field, var value) {
    switch (field) {
      case "image":
        _image = value;
        uploadPostBloc.changeImage('image');

        if (_title.isNotEmpty && _description.isNotEmpty) {
          uploadPostBloc.changeButton('text');
        }
        break;

      case "title":
        _title = value;

        if (_title.isEmpty) {
          uploadPostBloc.changeButton('textInactive');
          return;
        }

        if (_title.isNotEmpty && _description.isNotEmpty && _image != null) {
          uploadPostBloc.changeButton('text');
        }
        break;

      case "description":
        _description = value;

        if (_description.isEmpty) {
          uploadPostBloc.changeButton('textInactive');
          return;
        }

        if (_description.isNotEmpty && _title.isNotEmpty && _image != null) {
          uploadPostBloc.changeButton('text');
        }
        break;

      default:
    }
  }
}
