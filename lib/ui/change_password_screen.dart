import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/change_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangePasswordScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<ChangePasswordModel>(
      builder: (context, model, _) {
        return WillPopScope(
          onWillPop: () =>
              Future<bool>.value(model.state == ChangePasswordViewState.Idle),
          child: SafeArea(
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: AppBar(
                title: Text('Change Password'),
                leading: BackButton(),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: model.state == ChangePasswordViewState.Idle
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.button.merge(
                            TextStyle(
                              color: model.state == ChangePasswordViewState.Idle
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                    ),
                    onPressed: model.state == ChangePasswordViewState.Idle
                        ? () => model.updateUserPassword(context)
                        : null,
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    _buildTextField(model,
                        label: 'Old Password',
                        currentField: PasswordField.Old,
                        nextField: PasswordField.New),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _buildTextField(model,
                        label: 'New Password',
                        currentField: PasswordField.New,
                        nextField: PasswordField.Confirmed),
                    const SizedBox(
                      height: 10.0,
                    ),
                    _buildTextField(model,
                        label: 'Confirm new Password',
                        currentField: PasswordField.Confirmed),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    ChangePasswordModel model, {
    String label,
    @required PasswordField currentField,
    PasswordField nextField,
  }) {
    Stream<bool> obscureTextStream;
    TextInputAction inputAction;

    switch (currentField) {
      case PasswordField.Old:
        obscureTextStream = model.oldPwdObscureText;
        inputAction = TextInputAction.next;
        break;
      case PasswordField.New:
        obscureTextStream = model.newPwdObscureText;
        inputAction = TextInputAction.next;
        break;
      case PasswordField.Confirmed:
        obscureTextStream = model.confirmedPwdObscureText;
        inputAction = TextInputAction.done;
        break;
    }

    return StreamBuilder(
      stream: obscureTextStream,
      initialData: true,
      builder: (context, snapshot) {
        return TextFormField(
          controller: model.textControllers[currentField],
          focusNode: model.focusNodes[currentField],
          textInputAction: inputAction,
          keyboardType: TextInputType.text,
          obscureText: snapshot.data,
          inputFormatters: [
            LengthLimitingTextInputFormatter(128),
          ],
          onFieldSubmitted: nextField != null
              ? (term) {
                  model.focusNodes[currentField].unfocus();
                  FocusScope.of(context)
                      .requestFocus(model.focusNodes[nextField]);
                }
              : (term) {
                  model.focusNodes[currentField].unfocus();
                  model.updateUserPassword(context);
                },
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(FontAwesomeIcons.eye),
              iconSize: 20.0,
              color: Colors.black,
              onPressed: () =>
                  model.toggleObscureText(currentField, !snapshot.data),
            ),
          ),
        );
      },
    );
  }
}
