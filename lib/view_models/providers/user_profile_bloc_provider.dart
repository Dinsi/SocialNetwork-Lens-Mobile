import 'package:flutter/material.dart';

import '../user_profile_bloc.dart';
export '../user_profile_bloc.dart';

class UserProfileBlocProvider extends StatefulWidget {
  final Widget child;
  final UserProfileBloc bloc;

  UserProfileBlocProvider(this.bloc, {Key key, @required this.child})
      : super(key: key);

  @override
  _UserProfileBlocProviderState createState() =>
      _UserProfileBlocProviderState();

  static UserProfileBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(_UserProfileBlocProvider)
            as _UserProfileBlocProvider)
        .bloc;
  }
}

class _UserProfileBlocProviderState extends State<UserProfileBlocProvider> {
  @override
  Widget build(BuildContext context) {
    return _UserProfileBlocProvider(bloc: widget.bloc, child: widget.child);
  }
}

class _UserProfileBlocProvider extends InheritedWidget {
  final UserProfileBloc bloc;

  _UserProfileBlocProvider(
      {Key key, @required this.bloc, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_UserProfileBlocProvider old) => false;
}
