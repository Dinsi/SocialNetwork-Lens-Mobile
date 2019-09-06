import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/change_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ChangeNotifierBaseView<ChangeEmailModel>(
      builder: (context, model, _) {
        return WillPopScope(
          onWillPop: () =>
              Future<bool>.value(model.state == ChangeEmailViewState.Idle),
          child: SafeArea(
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: AppBar(
                title: const Text('Change Email'),
                leading: BackButton(),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: model.state == ChangeEmailViewState.Idle
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: model.state == ChangeEmailViewState.Idle
                                ? Colors.red
                                : Colors.grey,
                          ),
                    ),
                    onPressed: model.state == ChangeEmailViewState.Idle
                        ? () => model.updateUserEmail(context)
                        : null,
                  ),
                ],
              ),
              body: Theme(
                data: theme.copyWith(primaryColor: Colors.red),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Current email: ${model.email}',
                        style: Theme.of(context).textTheme.title,
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        controller: model.emailController,
                        focusNode: model.emailFocusNode,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        onSubmitted: (term) {
                          FocusScope.of(context)
                              .requestFocus(model.passwordFocusNode);
                        },
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(128),
                        ],
                        decoration: InputDecoration(labelText: "New Email"),
                      ),
                      const SizedBox(height: 10.0),
                      StreamBuilder(
                        stream: model.obscureText,
                        initialData: true,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          return TextField(
                            controller: model.passwordController,
                            focusNode: model.passwordFocusNode,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            obscureText: snapshot.data,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(128),
                            ],
                            decoration: InputDecoration(
                              labelText: "Password",
                              suffixIcon: IconButton(
                                splashColor: Colors.transparent,
                                icon: Icon(FontAwesomeIcons.eye),
                                iconSize: 20.0,
                                color: Colors.black,
                                onPressed: () =>
                                    model.toggleObscureText(!snapshot.data),
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
          ),
        );
      },
    );
  }
}
