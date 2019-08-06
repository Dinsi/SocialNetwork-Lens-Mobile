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

enum EditProfileField {
  FirstName,
  LastName,
  Headline,
  Location,
  Bio,
  PublicEmail,
  Website,
}

enum ImageType { Asset, Network, File }

enum EditProfileViewState { Idle, Updating }

// TODO Update pfp in entire app ???

class EditProfileModel extends StateModel<EditProfileViewState> {
  final Repository _repository = locator<Repository>();
  final AppInfo _appInfo = locator<AppInfo>();

  PublishSubject<ImageType> _imageSubject = PublishSubject();

  File _imageFile;

  ///////////////////////////////////////////////////////////////////////

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  final Map<EditProfileField, FocusNode> _focusNodes = {
    // First name
    EditProfileField.FirstName: FocusNode(),
    // Last name
    EditProfileField.LastName: FocusNode(),
    // Headline
    EditProfileField.Headline: FocusNode(),
    // Location
    EditProfileField.Location: FocusNode(),
    // Bio
    EditProfileField.Bio: FocusNode(),
    // Public email
    EditProfileField.PublicEmail: FocusNode(),
    // Website
    EditProfileField.Website: FocusNode(),
  };

  final Map<EditProfileField, TextEditingController> _textControllers = {};

  //////////////////////////////////////////////////////////////////////

  EditProfileModel() : super(EditProfileViewState.Idle);

  //////////////////////////////////////////////////////////////////////
  // * Init
  void init() {
    User user = _appInfo.currentUser;

    _textControllers.addAll({
      // First name
      EditProfileField.FirstName: TextEditingController(text: user.firstName),
      // Last name
      EditProfileField.LastName: TextEditingController(text: user.lastName),
      // Headline
      EditProfileField.Headline:
          TextEditingController(text: user.headline ?? ''),
      // Location
      EditProfileField.Location:
          TextEditingController(text: user.location ?? ''),
      // Bio
      EditProfileField.Bio: TextEditingController(text: user.bio ?? ''),
      // Public email
      EditProfileField.PublicEmail:
          TextEditingController(text: user.publicEmail ?? ''),
      // Website
      EditProfileField.Website: TextEditingController(text: user.website ?? '')
    });
  }

  //////////////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    super.dispose();
    _imageSubject.close();

    _textControllers.forEach((_, controller) => controller.dispose());
    _focusNodes.forEach((_, node) => node.dispose());
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

    Map<EditProfileField, String> newFields = Map<EditProfileField, String>();
    User user = _appInfo.currentUser;
    // Select new fields
    _textControllers.forEach((key, controller) {
      final trimmedField = controller.text.trim();

      switch (key) {
        case EditProfileField.FirstName:
          if (trimmedField != user.firstName) {
            newFields[EditProfileField.FirstName] = trimmedField;
          }
          break;

        case EditProfileField.LastName:
          if (trimmedField != user.lastName) {
            newFields[EditProfileField.LastName] = trimmedField;
          }
          break;

        case EditProfileField.Headline:
          if (trimmedField != user.headline) {
            newFields[EditProfileField.Headline] = trimmedField;
          }
          break;

        case EditProfileField.Location:
          if (trimmedField != user.location) {
            newFields[EditProfileField.Location] = trimmedField;
          }
          break;

        case EditProfileField.Bio:
          if (trimmedField != user.bio) {
            newFields[EditProfileField.Bio] = trimmedField;
          }
          break;

        case EditProfileField.PublicEmail:
          if (trimmedField != user.publicEmail) {
            newFields[EditProfileField.PublicEmail] = trimmedField;
          }
          break;

        case EditProfileField.Website:
          if (trimmedField != user.website) {
            newFields[EditProfileField.Website] = trimmedField;
          }
      }
    });

    // do validations
    if (newFields.isNotEmpty) {
      // Check if first and last name are not blank
      if ((newFields.containsKey(EditProfileField.FirstName) &&
              newFields[EditProfileField.FirstName].isEmpty) ||
          (newFields.containsKey(EditProfileField.LastName) &&
              newFields[EditProfileField.LastName].isEmpty)) {
        showInSnackBar(
          context,
          scaffoldKey,
          'All required fields must be filled',
        );
        setState(EditProfileViewState.Idle);
        return;
      }

      // Check if public email has been filled, and if so, if it's an email
      if (newFields.containsKey(EditProfileField.PublicEmail) &&
          newFields[EditProfileField.PublicEmail].isNotEmpty &&
          !isEmail(newFields[EditProfileField.PublicEmail])) {
        showInSnackBar(
          context,
          scaffoldKey,
          'Invalid public email address',
        );
        setState(EditProfileViewState.Idle);
        return;
      }

      // Check if website has been filled, and if so, if it's a URL
      if (newFields.containsKey(EditProfileField.Website) &&
          newFields[EditProfileField.Website].isNotEmpty &&
          !isUrl(newFields[EditProfileField.Website])) {
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
    return imageUrl.isEmpty ? ImageType.Asset : ImageType.Network;
  }

  String get imageUrl => _appInfo.currentUser.avatar;
  File get imageFile => _imageFile;
  Observable<ImageType> get imageStream => _imageSubject.stream;

  //////////////////////////////////////////////////////////////////////

  Map<EditProfileField, TextEditingController> get textControllers =>
      _textControllers;
  Map<EditProfileField, FocusNode> get focusNodes => _focusNodes;
}
