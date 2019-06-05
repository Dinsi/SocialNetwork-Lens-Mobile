import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../blocs/change_email_bloc.dart';

class ChangeEmailScreen extends StatefulWidget {
  final ChangeEmailBloc bloc;

  const ChangeEmailScreen({Key key, @required this.bloc}) : super(key: key);

  @override
  _ChangeEmailScreenState createState() => _ChangeEmailScreenState(this.bloc);
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _newEmailController;
  TextEditingController _passwordController;

  FocusNode _newEmailFocusNode;
  FocusNode _passwordFocusNode;

  ChangeEmailBloc bloc;

  _ChangeEmailScreenState(this.bloc);

  @override
  void initState() {
    super.initState();
    _newEmailController = TextEditingController();
    _newEmailFocusNode = FocusNode();

    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _newEmailController?.dispose();
    _newEmailFocusNode?.dispose();

    _passwordController?.dispose();
    _passwordFocusNode?.dispose();
    bloc.dispose();
    super.dispose();
  }

  Future<void> _changeUserEmail() async {
    int result = await bloc.changeUserEmail({
      'email': _newEmailController.text,
      'password': _passwordController.text,
    });

    switch (result) {
      case 0:
        Navigator.of(context).pop(result);
        break;
      case -1:
        _showInSnackBar('All fields must be filled');
        break;
      case -2:
        _showInSnackBar('Invalid email address');
        break;
      case -3:
        _showInSnackBar('New email cannot be the same as the current email');
        break;
      case 1:
        _showInSnackBar(
            'The password provided does not match the current password');
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
          title: Text('Change Email'),
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
                          _changeUserEmail();
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
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Text(
                      'Current email: ${bloc.email}',
                      style: Theme.of(context).textTheme.title,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                TextFormField(
                  controller: _newEmailController,
                  focusNode: _newEmailFocusNode,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (term) {
                    _newEmailFocusNode.unfocus();
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(128),
                  ],
                  style: Theme.of(context).textTheme.headline,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(12.0),
                    labelText: "New Email",
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
                const SizedBox(
                  height: 10.0,
                ),
                StreamBuilder(
                  stream: bloc.obscureText,
                  initialData: true,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      obscureText: snapshot.data,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(128),
                      ],
                      onFieldSubmitted: (term) {
                        _passwordFocusNode.unfocus();
                        _changeUserEmail();
                      },
                      style: Theme.of(context).textTheme.headline,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(12.0),
                        labelText: "Password",
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
                            bloc.shiftObscureText(!snapshot.data);
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
