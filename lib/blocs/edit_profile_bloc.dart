import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../ui/utils/post_shared_functions.dart';
import '../models/user.dart';
import '../resources/globals.dart';
import '../resources/repository.dart';

class EditProfileBloc {
  final Repository _repository = Repository();
  final User _userInfo = Globals.getInstance().user;
  StreamController<String> _buttonController = StreamController.broadcast();
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
    _buttonController.sink.add('saveInactive');

    Map<String, String> newFields = Map<String, String>();

    // select new fields
    fields.forEach((key, field) {
      switch (key) {
        case 'first_name':
          if (field != firstName) {
            newFields['first_name'] = field;
          }
          break;

        case 'last_name':
          if (field != lastName) {
            newFields['last_name'] = field;
          }
          break;

        case 'headline':
          if (field != headline) {
            newFields['headline'] = field;
          }
          break;

        case 'location':
          if (field != location) {
            newFields['location'] = field;
          }
          break;

        case 'bio':
          if (field != bio) {
            newFields['bio'] = field;
          }
          break;

        case 'public_email':
          if (field != publicEmail) {
            newFields['public_email'] = field;
          }
          break;

        case 'website':
          if (field != website) {
            newFields['website'] = field;
          }
      }
    });

    // do validations
    if ((newFields.containsKey('first_name') &&
            newFields['first_name'].isEmpty) ||
        (newFields.containsKey('last_name') &&
            newFields['last_name'].isEmpty)) {
      _buttonController.sink.add('save');
      return -1;
    }

    if (newFields.containsKey('public_email')) {
      if (newFields['public_email'].isNotEmpty &&
          !isEmail(newFields['public_email'])) {
        _buttonController.sink.add('save');
        return -2;
      }
    }

    if (newFields.containsKey('website')) {
      if (newFields['website'].isNotEmpty && !isUrl(newFields['website'])) {
        _buttonController.sink.add('save');
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

  Stream<String> get saveButton => _buttonController.stream;
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
