import 'dart:async';
import 'dart:io';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/utils/utils.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rxdart/rxdart.dart';

enum EditProfileViewState { Idle, Updating }

enum ImageType { Asset, Network, File }

// TODO Update pfp in entire app ???

class EditProfileModel extends StateModel<EditProfileViewState> {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  PublishSubject<ImageType> _imageSubject = PublishSubject();

  File _imageFile;

  ///////////////////////////////////////////////////////////////////////
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  final Map<String, FocusNode> focusNodes = {
    'first_name': FocusNode(),
    'last_name': FocusNode(),
    'headline': FocusNode(),
    'location': FocusNode(),
    'bio': FocusNode(),
    'public_email': FocusNode(),
    'website': FocusNode(),
  };

  final Map<String, TextEditingController> textControllers = {};

  //////////////////////////////////////////////////////////////////////

  EditProfileModel() : super(EditProfileViewState.Idle);

  //////////////////////////////////////////////////////////////////////
  // * Init
  void init() {
    User user = _appInfo.currentUser;

    textControllers['first_name'] = TextEditingController(text: user.firstName);
    textControllers['last_name'] = TextEditingController(text: user.lastName);
    textControllers['headline'] =
        TextEditingController(text: user.headline ?? '');
    textControllers['location'] =
        TextEditingController(text: user.location ?? '');
    textControllers['bio'] = TextEditingController(text: user.bio ?? '');
    textControllers['public_email'] =
        TextEditingController(text: user.publicEmail ?? '');
    textControllers['website'] =
        TextEditingController(text: user.website ?? '');
  }

  //////////////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    super.dispose();
    _imageSubject.close();

    textControllers.forEach((_, controller) => controller.dispose());
    focusNodes.forEach((_, node) => node.dispose());
  }

  Future<void> selectNewImage() async {
    File newImageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (newImageFile == null) {
      return;
    }

    _imageFile = newImageFile;
    _imageSubject.sink.add(ImageType.File);
  }

  //////////////////////////////////////////////////////////////////////

  Future<void> saveProfile(BuildContext context) async {
    setState(EditProfileViewState.Updating);

    Map<String, String> newFields = Map<String, String>();
    User user = _appInfo.currentUser;
    // select new fields
    textControllers.forEach((key, controller) {
      final trimmedField = controller.text.trimRight();

      switch (key) {
        case 'first_name':
          if (trimmedField != user.firstName) {
            newFields['first_name'] = trimmedField;
          }
          break;

        case 'last_name':
          if (trimmedField != user.lastName) {
            newFields['last_name'] = trimmedField;
          }
          break;

        case 'headline':
          if (trimmedField != user.headline) {
            newFields['headline'] = trimmedField;
          }
          break;

        case 'location':
          if (trimmedField != user.location) {
            newFields['location'] = trimmedField;
          }
          break;

        case 'bio':
          if (trimmedField != user.bio) {
            newFields['bio'] = trimmedField;
          }
          break;

        case 'public_email':
          if (trimmedField != user.publicEmail) {
            newFields['public_email'] = trimmedField;
          }
          break;

        case 'website':
          if (trimmedField != user.website) {
            newFields['website'] = trimmedField;
          }
      }
    });

    // do validations
    if (newFields.isNotEmpty) {
      // Check if first and last name are not blank
      if ((newFields.containsKey('first_name') &&
              newFields['first_name'].isEmpty) ||
          (newFields.containsKey('last_name') &&
              newFields['last_name'].isEmpty)) {
        showInSnackBar(
          context,
          scaffoldKey,
          'All required fields must be filled',
        );
        setState(EditProfileViewState.Idle);
        return;
      }

      // Check if public email has been filled, and if so, if it's an email
      if (newFields.containsKey('public_email') &&
          newFields['public_email'].isNotEmpty &&
          !isEmail(newFields['public_email'])) {
        showInSnackBar(
          context,
          scaffoldKey,
          'Invalid public email address',
        );
        setState(EditProfileViewState.Idle);
        return;
      }

      // Check if website has been filled, and if so, if it's a URL
      if (newFields.containsKey('website') &&
          newFields['website'].isNotEmpty &&
          !isUrl(newFields['website'])) {
        showInSnackBar(
          context,
          scaffoldKey,
          'Invalid website URL',
        );
        setState(EditProfileViewState.Idle);
        return;
      }
    }

    int result;
    if (_imageFile != null) {
      // function to update both image and fields
      result = await _repository.patchUserMultiPart(
          _imageFile, newFields.isEmpty ? null : newFields);
    } else {
      if (newFields.isEmpty) {
        Navigator.of(context).pop(0);
        return;
      }

      // function to only update fields
      result = await _repository.patchUser(newFields);
    }

    // TODO implement other errors
    if (result == 0) {
      Navigator.of(context).pop(result);
      return;
    }
  }

  ImageType getInitialData() {
    return _appInfo.currentUser.avatar.isEmpty
        ? ImageType.Asset
        : ImageType.Network;
  }

  String get imageUrl => _appInfo.currentUser.avatar;
  File get imageFile => _imageFile;
  Observable<ImageType> get imageStream => _imageSubject.stream;
}
