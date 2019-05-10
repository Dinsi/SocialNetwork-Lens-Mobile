import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../blocs/upload_post_bloc.dart';

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
  Function _onPressedFunction;

  Future<void> _getOnPressed(context) async {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Uploading post...'),
          content: SizedBox(
            height: 75.0,
            child: Center(
              child: const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    int code = await uploadPostBloc.uploadPost(_image, _title, _description);
    Navigator.of(context)..pop()..pop(code);
    //TODO fix
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        leading: BackButton(),
      ),
      body: ListView(
        children: <Widget>[
          GestureDetector(
            onTap: _loadImage,
            child: (_image == null
                ? Container(
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
                  )
                : Image.file(
                    _image,
                    fit: BoxFit.fitWidth,
                  )),
          ),
          const Divider(
            height: 10.0,
            color: Colors.transparent,
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 60.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                child: ButtonTheme(
                  buttonColor: Colors.blue[600],
                  splashColor: Colors.blueGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9.0),
                  ),
                  child: RaisedButton(
                    elevation: 5.0,
                    onPressed: _onPressedFunction,
                    child: Text(
                      'Upload Post',
                      style: Theme.of(context)
                          .textTheme
                          .headline
                          .copyWith(color: Colors.white, fontSize: 23.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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
        setState(() {
          _image = value;
        });

        if (_onPressedFunction != null) {
          return;
        }

        if (_title.isNotEmpty && _description.isNotEmpty) {
          setState(() {
            _onPressedFunction = () => _getOnPressed(context);
          });
        }
        break;

      case "title":
        _title = value;

        if (_onPressedFunction != null) {
          if (_title.isEmpty) {
            setState(() {
              _onPressedFunction = null;
            });
          }
          return;
        }

        if (_title.isNotEmpty && _description.isNotEmpty && _image != null) {
          setState(() {
            _onPressedFunction = () => _getOnPressed(context);
          });
        }
        break;

      case "description":
        _description = value;

        if (_onPressedFunction != null) {
          if (_description.isEmpty) {
            setState(() {
              _onPressedFunction = null;
            });
          }
          return;
        }

        if (_description.isNotEmpty && _title.isNotEmpty && _image != null) {
          setState(() {
            _onPressedFunction = () => _getOnPressed(context);
          });
        }
        break;

      default:
    }
  }
}
