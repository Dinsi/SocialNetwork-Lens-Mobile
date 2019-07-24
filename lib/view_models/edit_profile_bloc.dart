import 'dart:async';
import 'dart:io';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/utils/post_shared_functions.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileBloc {
  final Repository _repository = locator<Repository>();
  final User _userInfo = locator<AppInfo>().user;
  StreamController<bool> _buttonController = StreamController.broadcast();
  StreamController<String> _imageController = StreamController.broadcast();

  void dispose() {
    _buttonController.close();
    _imageController.close();
  }

  Future<File> selectNewImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }

    return image;
  }

  void notifyImageStream() => _imageController.sink.add('image');

  Future<int> saveProfile(dynamic image, Map<String, String> fields) async {
    _buttonController.sink.add(false);

    Map<String, String> newFields = Map<String, String>();

    // select new fields
    fields.forEach((key, field) {
      final trimmedField = field.trimRight();

      switch (key) {
        case 'first_name':
          if (trimmedField != firstName) {
            newFields['first_name'] = trimmedField;
          }
          break;

        case 'last_name':
          if (trimmedField != lastName) {
            newFields['last_name'] = trimmedField;
          }
          break;

        case 'headline':
          if (trimmedField != headline) {
            newFields['headline'] = trimmedField;
          }
          break;

        case 'location':
          if (trimmedField != location) {
            newFields['location'] = trimmedField;
          }
          break;

        case 'bio':
          if (trimmedField != bio) {
            newFields['bio'] = trimmedField;
          }
          break;

        case 'public_email':
          if (trimmedField != publicEmail) {
            newFields['public_email'] = trimmedField;
          }
          break;

        case 'website':
          if (field != website) {
            newFields['website'] = trimmedField;
          }
      }
    });

    // do validations
    if ((newFields.containsKey('first_name') &&
            newFields['first_name'].isEmpty) ||
        (newFields.containsKey('last_name') &&
            newFields['last_name'].isEmpty)) {
      _buttonController.sink.add(true);
      return -1;
    }

    if (newFields.containsKey('public_email')) {
      if (newFields['public_email'].isNotEmpty &&
          !isEmail(newFields['public_email'])) {
        _buttonController.sink.add(true);
        return -2;
      }
    }

    if (newFields.containsKey('website')) {
      if (newFields['website'].isNotEmpty && !isUrl(newFields['website'])) {
        _buttonController.sink.add(true);
        return -3;
      }
    }

    if (image is File) {
      // function to update both image and fields
      return await _repository.patchUserMultiPart(
          image, newFields.isEmpty ? null : newFields);
    } else {
      if (newFields.isEmpty) {
        return 0;
      }
      // function to only update fields

      return await _repository.patchUser(newFields);
    }
  }

  Stream<bool> get saveButton => _buttonController.stream;
  Stream<String> get image => _imageController.stream;
  String get avatar => _userInfo.avatar ?? '';
  String get firstName => _userInfo.firstName;
  String get lastName => _userInfo.lastName;
  String get headline => _userInfo.headline ?? '';
  String get location => _userInfo.location ?? '';
  String get bio => _userInfo.bio ?? '';
  String get publicEmail => _userInfo.publicEmail ?? '';
  String get website => _userInfo.website ?? '';
}
