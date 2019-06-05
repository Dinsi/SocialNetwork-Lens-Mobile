import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../blocs/change_password_bloc.dart';

class ChangePasswordScreen extends StatefulWidget {
  final ChangePasswordBloc bloc;

  const ChangePasswordScreen({Key key, this.bloc}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() =>
      _ChangePasswordScreenState(this.bloc);
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _oldPasswordController;
  TextEditingController _newPasswordController;
  TextEditingController _confirmedPasswordController;

  FocusNode _oldPasswordFocusNode;
  FocusNode _newPasswordFocusNode;
  FocusNode _confirmedPasswordFocusNode;

  ChangePasswordBloc bloc;

  _ChangePasswordScreenState(this.bloc);

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _oldPasswordFocusNode = FocusNode();

    _newPasswordController = TextEditingController();
    _newPasswordFocusNode = FocusNode();

    _confirmedPasswordController = TextEditingController();
    _confirmedPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _oldPasswordController?.dispose();
    _oldPasswordFocusNode?.dispose();

    _newPasswordController?.dispose();
    _newPasswordFocusNode?.dispose();

    _confirmedPasswordController?.dispose();
    _confirmedPasswordFocusNode?.dispose();

    bloc.dispose();
    super.dispose();
  }

  Future<void> _changeUserPassword() async {
    int result = await bloc.changeUserPassword({
      'password': _oldPasswordController.text,
      'new_password': _newPasswordController.text,
      'new_password_confirm': _confirmedPasswordController.text,
    });

    switch (result) {
      case 0:
        Navigator.of(context).pop(result);
        break;
      case -1:
        _showInSnackBar('All fields must be filled');
        break;
      case -2:
        _showInSnackBar('Passwords don\'t match');
        break;
      case 1:
        _showInSnackBar('The old password provided is invalid');
    }
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future<bool>.value(bloc.willPop);
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Change Password'),
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
                  onPressed: snapshot.data
                      ? () {
                          _changeUserPassword();
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                StreamBuilder(
                  stream: bloc.oldPwdObscureText,
                  initialData: true,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return TextFormField(
                      controller: _oldPasswordController,
                      focusNode: _oldPasswordFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      obscureText: snapshot.data,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(128),
                      ],
                      onFieldSubmitted: (term) {
                        _oldPasswordFocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_newPasswordFocusNode);
                      },
                      style: Theme.of(context).textTheme.headline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        labelText: "Old Password",
                        labelStyle: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black45),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          icon: Icon(FontAwesomeIcons.eye),
                          iconSize: 20.0,
                          color: Colors.black,
                          onPressed: () {
                            bloc.shiftObscureText('old', !snapshot.data);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                  stream: bloc.newPwdObscureText,
                  initialData: true,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return TextFormField(
                      controller: _newPasswordController,
                      focusNode: _newPasswordFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      obscureText: snapshot.data,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(128),
                      ],
                      onFieldSubmitted: (term) {
                        _newPasswordFocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(_confirmedPasswordFocusNode);
                      },
                      style: Theme.of(context).textTheme.headline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        labelText: "New Password",
                        labelStyle: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black45),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          icon: Icon(FontAwesomeIcons.eye),
                          iconSize: 20.0,
                          color: Colors.black,
                          onPressed: () {
                            bloc.shiftObscureText('new', !snapshot.data);
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                  stream: bloc.confirmedPwdObscureText,
                  initialData: true,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return TextFormField(
                      controller: _confirmedPasswordController,
                      focusNode: _confirmedPasswordFocusNode,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      obscureText: snapshot.data,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(128),
                      ],
                      onFieldSubmitted: (term) {
                        _confirmedPasswordFocusNode.unfocus();
                        _changeUserPassword();
                      },
                      style: Theme.of(context).textTheme.headline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        labelText: "Confirm new Password",
                        labelStyle: Theme.of(context)
                            .textTheme
                            .headline
                            .copyWith(color: Colors.black45),
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        suffixIcon: IconButton(
                          splashColor: Colors.transparent,
                          icon: Icon(FontAwesomeIcons.eye),
                          iconSize: 20.0,
                          color: Colors.black,
                          onPressed: () {
                            bloc.shiftObscureText('confirmed', !snapshot.data);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
