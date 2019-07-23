import 'dart:async';

import 'package:aperture/view_models/edit_profile_bloc.dart';
import 'package:aperture/view_models/providers/edit_profile_bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _headlineController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  TextEditingController _publicEmailController = TextEditingController();
  TextEditingController _websiteController = TextEditingController();

  FocusNode _firstNameFocusNode = FocusNode();
  FocusNode _lastNameFocusNode = FocusNode();
  FocusNode _headlineFocusNode = FocusNode();
  FocusNode _locationFocusNode = FocusNode();
  FocusNode _bioFocusNode = FocusNode();
  FocusNode _publicEmailFocusNode = FocusNode();
  FocusNode _websiteFocusNode = FocusNode();

  var _image;

  EditProfileBloc bloc;

  bool _isInit = true;
  bool _enabledBackButton = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      bloc = EditProfileBlocProvider.of(context);

      _firstNameController.text = bloc.firstName;
      _lastNameController.text = bloc.lastName;
      _headlineController.text = bloc.headline;
      _locationController.text = bloc.location;
      _bioController.text = bloc.bio;
      _publicEmailController.text = bloc.publicEmail;
      _websiteController.text = bloc.website;

      _image = bloc.avatar;

      _isInit = false;
    }
  }

  @override
  void dispose() {
    _firstNameController?.dispose();
    _lastNameController?.dispose();
    _headlineController?.dispose();
    _locationController?.dispose();
    _bioController?.dispose();
    _publicEmailController?.dispose();
    _websiteController?.dispose();

    _firstNameFocusNode?.dispose();
    _lastNameFocusNode?.dispose();
    _headlineFocusNode?.dispose();
    _locationFocusNode?.dispose();
    _bioFocusNode?.dispose();
    _publicEmailFocusNode?.dispose();
    _websiteFocusNode?.dispose();

    bloc.dispose();
    super.dispose();
  }

  void _showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

  Future<void> _saveProfile() async {
    _enabledBackButton = false;

    int resultCode = await bloc.saveProfile(_image, {
      'first_name': _firstNameController.text.trimRight(),
      'last_name': _lastNameController.text.trimRight(),
      'headline': _headlineController.text.trimRight(),
      'location': _locationController.text.trimRight(),
      'bio': _bioController.text.trimRight(),
      'public_email': _publicEmailController.text.trimRight(),
      'website': _websiteController.text.trimRight(),
    });

    switch (resultCode) {
      case 0:
        Navigator.of(context).pop(resultCode);
        break;

      case -1:
        _showInSnackBar('All required fields must be filled');
        _enabledBackButton = true;
        break;

      case -2:
        _showInSnackBar('Invalid public email address');
        _enabledBackButton = true;
        break;

      case -3:
        _showInSnackBar('Invalid website URL');
        _enabledBackButton = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_enabledBackButton) {
          return Future<bool>.value(true);
        }

        return Future<bool>.value(false);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Edit Profile'),
          leading: BackButton(),
          actions: <Widget>[
            StreamBuilder<bool>(
              stream: bloc.saveButton,
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                return FlatButton.icon(
                  icon: Icon(
                    Icons.check,
                    color: snapshot.data ? Colors.blue : Colors.grey,
                  ),
                  label: Text(
                    'SAVE',
                    style: Theme.of(context).textTheme.button.merge(
                          TextStyle(
                            color: snapshot.data ? Colors.blue : Colors.grey,
                          ),
                        ),
                  ),
                  onPressed: snapshot.data ? () => _saveProfile() : null,
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Container(
                  color: Colors.transparent,
                  height: 100.0,
                  width: 100.0,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipOval(
                        child: StreamBuilder<String>(
                          stream: bloc.image,
                          initialData:
                              (_image as String).isEmpty ? 'asset' : 'network',
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            switch (snapshot.data) {
                              case 'asset':
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/img/user_placeholder.png',
                                      ),
                                    ),
                                  ),
                                );
                              case 'network':
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _image,
                                      ),
                                    ),
                                  ),
                                );
                              case 'image':
                                return Image.file(
                                  _image,
                                  fit: BoxFit.contain,
                                );
                            }
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        right: 0.0,
                        child: FloatingActionButton(
                          mini: true,
                          elevation: 5.0,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.edit,
                            color: Colors.blue,
                          ),
                          onPressed: () =>
                              bloc.selectNewImage().then((imageFile) {
                                if (imageFile != null) {
                                  _image = imageFile;
                                  bloc.notifyImageStream();
                                }
                              }),
                        ),
                      )
                    ],
                  ),
                ),
                StreamBuilder(
                  stream: bloc.image,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData || snapshot.data != 'image') {
                      return Container();
                    }

                    return Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Text(
                            '(image will be properly clipped on the server)'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20.0),
                TextFormField(
                  controller: _firstNameController,
                  focusNode: _firstNameFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(30),
                  ],
                  onFieldSubmitted: (term) {
                    _firstNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_lastNameFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "First Name (required)",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _lastNameController,
                  focusNode: _lastNameFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(150),
                  ],
                  onFieldSubmitted: (term) {
                    _lastNameFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_headlineFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Last Name (required)",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _headlineController,
                  focusNode: _headlineFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(128),
                  ],
                  onFieldSubmitted: (term) {
                    _headlineFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_locationFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Headline",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _locationController,
                  focusNode: _locationFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(128),
                  ],
                  onFieldSubmitted: (term) {
                    _locationFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_bioFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Location",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _bioController,
                  focusNode: _bioFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(512),
                  ],
                  onFieldSubmitted: (term) {
                    _bioFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_publicEmailFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Bio",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _publicEmailController,
                  focusNode: _publicEmailFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64),
                  ],
                  onFieldSubmitted: (term) {
                    _publicEmailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_websiteFocusNode);
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Public Email",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                TextFormField(
                  controller: _websiteController,
                  focusNode: _websiteFocusNode,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(64),
                  ],
                  onFieldSubmitted: (term) {
                    _websiteFocusNode.unfocus();
                    _saveProfile();
                  },
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "Website",
                    labelStyle: Theme.of(context)
                        .textTheme
                        .headline
                        .copyWith(color: Colors.black45),
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
