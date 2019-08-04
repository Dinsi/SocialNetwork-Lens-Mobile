import 'dart:async';

import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter/widgets.dart';

class EditProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<EditProfileModel>(
      onModelReady: (model) => model.init(),
      builder: (context, model, __) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(model.state == EditProfileViewState.Idle);
          },
          child: SafeArea(
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: AppBar(
                title: Text('Edit Profile'),
                leading: BackButton(),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: model.state == EditProfileViewState.Idle
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    label: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: model.state == EditProfileViewState.Idle
                                ? Colors.blue
                                : Colors.grey,
                          ),
                    ),
                    onPressed: model.state == EditProfileViewState.Idle
                        ? () => model.saveProfile(context)
                        : null,
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      StreamBuilder<ImageType>(
                        stream: model.imageStream,
                        initialData: model.getInitialData(),
                        builder: (_, snapshot) =>
                            _buildImageStack(model, snapshot.data),
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'First Name (required)',
                        currentField: 'first_name',
                        nextField: 'last_name',
                        characterLimit: 30,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Last Name (required)',
                        currentField: 'last_name',
                        nextField: 'headline',
                        characterLimit: 150,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Headline',
                        currentField: 'headline',
                        nextField: 'location',
                        characterLimit: 128,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Location',
                        currentField: 'location',
                        nextField: 'bio',
                        characterLimit: 128,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Bio',
                        currentField: 'bio',
                        nextField: 'public_email',
                        characterLimit: 512,
                        multiline: true,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Public Email',
                        currentField: 'public_email',
                        nextField: 'website',
                        characterLimit: 64,
                      ),
                      const SizedBox(height: 10.0),
                      _buildTextField(
                        context,
                        model,
                        labelText: 'Website',
                        currentField: 'website',
                        characterLimit: 64,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageStack(EditProfileModel model, ImageType imageType) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageType == ImageType.Asset
              ? AssetImage(
                  'assets/img/user_placeholder.png',
                )
              : imageType == ImageType.Network
                  ? NetworkImage(model.imageUrl)
                  : FileImage(model.imageFile),
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
            onPressed: () => model.selectNewImage(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    BuildContext context,
    EditProfileModel model, {
    @required String labelText,
    @required String currentField,
    @required int characterLimit,
    bool multiline = false,
    String nextField,
  }) {
    return TextFormField(
      controller: model.textControllers[currentField],
      focusNode: model.focusNodes[currentField],
      textInputAction:
          nextField != null ? TextInputAction.next : TextInputAction.done,
      keyboardType: multiline ? TextInputType.multiline : TextInputType.text,
      inputFormatters: [
        LengthLimitingTextInputFormatter(characterLimit),
      ],
      onFieldSubmitted: (term) {
        model.focusNodes[currentField].unfocus();
        nextField != null
            ? FocusScope.of(context).requestFocus(model.focusNodes[nextField])
            : model.saveProfile(context);
      },
      style: Theme.of(context).textTheme.headline,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(12.0),
        labelText: labelText,
        labelStyle: Theme.of(context)
            .textTheme
            .headline
            .copyWith(color: Colors.black45),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
      ),
    );
  }
}
