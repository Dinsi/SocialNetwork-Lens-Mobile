import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/change_email.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChangeEmailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    label: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.button.copyWith(
                            color: model.state == ChangeEmailViewState.Idle
                                ? Colors.blue
                                : Colors.grey,
                          ),
                    ),
                    onPressed: model.state == ChangeEmailViewState.Idle
                        ? () => model.updateUserEmail(context)
                        : null,
                  ),
                ],
              ),
              body: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Current email: ${model.email}',
                      style: Theme.of(context).textTheme.title,
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    TextFormField(
                      controller: model.emailController,
                      focusNode: model.emailFocusNode,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      onFieldSubmitted: (term) {
                        model.emailFocusNode.unfocus();
                        FocusScope.of(context)
                            .requestFocus(model.passwordFocusNode);
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
                      stream: model.obscureText,
                      initialData: true,
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        return TextFormField(
                          controller: model.passwordController,
                          focusNode: model.passwordFocusNode,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          obscureText: snapshot.data,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(128),
                          ],
                          onFieldSubmitted: (term) {
                            model.passwordFocusNode.unfocus();
                            model.updateUserEmail(context);
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
        );
      },
    );
  }
}
