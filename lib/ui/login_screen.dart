import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const _buttonBorderColor = Color(0xFFF66839);

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.vertical;

    return SafeArea(
      child: SimpleBaseView<LoginModel>(
        builder: (context, model, _) {
          return Scaffold(
            key: model.scaffoldKey,
            body: NotificationListener<OverscrollIndicatorNotification>(
              // * Disable overscroll glow
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: SizedBox(
                height: screenHeight,
                child: PageView(
                  controller: model.pageController,
                  children: <Widget>[
                    _buildSignIn(context, model),
                    _buildSignUp(context, model),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, LoginModel model) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              "Sign In",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 25.0),
          _buildTextField(
            context,
            model,
            currentField: LoginField.SignInUsername,
            nextField: LoginField.SignInPassword,
            labelText: 'Username',
          ),
          StreamBuilder<bool>(
              initialData: true,
              stream: model.getObscureStream(LoginField.SignInPassword),
              builder: (context, snapshot) {
                final isObscure = snapshot.data;

                return _buildTextField(
                  context,
                  model,
                  currentField: LoginField.SignInPassword,
                  labelText: 'Password',
                  obscureText: isObscure,
                );
              }),
          Container(
            padding: const EdgeInsets.only(right: 16.0),
            alignment: Alignment.centerRight,
            child: Text("Forgot your password?"),
          ),
          const SizedBox(height: 30.0),
          _buildButton(
            model,
            'SIGN IN',
          ),
          const SizedBox(height: 288.5),
          Align(
            alignment: Alignment.centerRight,
            child: RaisedButton(
              padding: const EdgeInsets.fromLTRB(40.0, 16.0, 30.0, 16.0),
              color: Colors.yellow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.0),
                      bottomLeft: Radius.circular(30.0))),
              onPressed: model.togglePage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "SIGN UP",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                  const SizedBox(width: 40.0),
                  Icon(
                    FontAwesomeIcons.arrowRight,
                    size: 18.0,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUp(BuildContext context, LoginModel model) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 25.0),
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Text(
              "Sign Up",
              style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10.0),
          _buildTextField(
            context,
            model,
            currentField: LoginField.SignUpUsername,
            nextField: LoginField.SignUpFirstName,
            labelText: 'Username',
            characterLimit: 150,
          ),
          _buildTextField(
            context,
            model,
            currentField: LoginField.SignUpFirstName,
            nextField: LoginField.SignUpLastName,
            labelText: 'First name',
            characterLimit: 30,
          ),
          _buildTextField(
            context,
            model,
            currentField: LoginField.SignUpLastName,
            nextField: LoginField.SignUpEmail,
            labelText: 'Last Name',
            characterLimit: 150,
          ),
          _buildTextField(
            context,
            model,
            currentField: LoginField.SignUpEmail,
            nextField: LoginField.SignUpPassword,
            labelText: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          StreamBuilder<bool>(
            stream: model.getObscureStream(LoginField.SignUpPassword),
            initialData: true,
            builder: (context, snapshot) {
              final isObscure = snapshot.data;

              return _buildTextField(
                context,
                model,
                currentField: LoginField.SignUpPassword,
                nextField: LoginField.SignUpConfirmPassword,
                labelText: 'Password (min: 6 / max: 16)',
                characterLimit: 16,
                obscureText: isObscure,
              );
            },
          ),
          StreamBuilder<bool>(
            stream: model.getObscureStream(LoginField.SignUpConfirmPassword),
            initialData: true,
            builder: (context, snapshot) {
              final isObscure = snapshot.data;

              return _buildTextField(
                context,
                model,
                currentField: LoginField.SignUpConfirmPassword,
                labelText: 'Confirm password',
                characterLimit: 16,
                obscureText: isObscure,
              );
            },
          ),
          const SizedBox(height: 20.0),
          _buildButton(
            model,
            'SIGN UP',
          ),
          const SizedBox(height: 30.0),
          Align(
            alignment: Alignment.centerLeft,
            child: RaisedButton(
              padding: const EdgeInsets.fromLTRB(30.0, 16.0, 40.0, 16.0),
              color: Colors.yellow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30.0),
                      bottomRight: Radius.circular(30.0))),
              onPressed: model.togglePage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.arrowLeft,
                    size: 18.0,
                  ),
                  const SizedBox(width: 40.0),
                  Text(
                    "SIGN IN",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(LoginModel model, String title) {
    return StreamBuilder<bool>(
      stream: model.buttonsStream,
      initialData: true,
      builder: (context, snapshot) {
        final isEnabled = snapshot.data;

        return Center(
          child: RaisedButton(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 30.0,
            ),
            shape: StadiumBorder(
              side: BorderSide(color: _buttonBorderColor, width: 3.0),
            ),
            onPressed: isEnabled ? () => model.signInOrSignUp(context) : null,
            child: Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    LoginModel model, {
    @required String labelText,
    @required LoginField currentField,
    LoginField nextField,
    int characterLimit,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText,
  }) {
    final existsNextField = nextField != null;
    final isPassword = obscureText != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 6.0),
      child: TextField(
        controller: model.textControllers[currentField],
        focusNode: model.focusNodes[currentField],
        textInputAction:
            existsNextField ? TextInputAction.next : TextInputAction.done,
        keyboardType: keyboardType,
        inputFormatters: characterLimit != null
            ? [LengthLimitingTextInputFormatter(characterLimit)]
            : null,
        obscureText: isPassword ? obscureText : false,
        onSubmitted: (_) {
          model.focusNodes[currentField].unfocus();
          existsNextField
              ? FocusScope.of(context).requestFocus(model.focusNodes[nextField])
              : model.signInOrSignUp(context);
        },
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(12.0),
          labelText: labelText,
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: () => model.toggleObscureText(currentField),
                  child: Icon(
                    FontAwesomeIcons.eye,
                    size: 20.0,
                    color: Colors.black,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
