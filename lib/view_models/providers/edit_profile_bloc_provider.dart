import 'package:flutter/material.dart';

import '../edit_profile_bloc.dart';
export '../edit_profile_bloc.dart';

class EditProfileBlocProvider extends InheritedWidget {
  EditProfileBlocProvider(this.bloc, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final EditProfileBloc bloc;

  static EditProfileBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(EditProfileBlocProvider)
            as EditProfileBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(EditProfileBlocProvider oldWidget) => false;
}
