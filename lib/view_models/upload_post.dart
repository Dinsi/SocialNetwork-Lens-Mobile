import 'dart:async';
import 'dart:io' show File;

import 'package:aperture/locator.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

enum UploadPostField { Title, Description }

enum UploadPostViewState { Idle, Uploading }

class UploadPostModel extends StateModel<UploadPostViewState> {
  final _repository = locator<Repository>();

  ///////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final titleTextController = TextEditingController();
  final descriptionTextController = TextEditingController();
  final descriptionFocusNode = FocusNode();
  File _image;

  ///////////////////////////////

  UploadPostModel() : super(UploadPostViewState.Idle);

  ////////////////////////////////////////////////////////////////////////////
  // * Init
  void init(File file) {
    _image = file;
  }

  ////////////////////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    super.dispose();
    titleTextController.dispose();
    descriptionTextController.dispose();
    descriptionFocusNode.dispose();
  }

  ////////////////////////////////////////////////////////////////////////////
  // * Public Functions
  Future loadImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return;
    }

    _image = image;
    notifyListeners();
  }

  Future<void> uploadPost(BuildContext context) async {
    setState(UploadPostViewState.Uploading);

    final title = titleTextController.text.trim();
    final description = descriptionTextController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      showInSnackBar(context, scaffoldKey, 'All fields must be filled');
      setState(UploadPostViewState.Idle);
      return;
    }

    int code = await _repository.uploadPost(_image, title, description);
    Navigator.of(context).pop(code);
  }

  ////////////////////////////////////////////////////////////////////////////
  // * Getters
  File get image => _image;
}
