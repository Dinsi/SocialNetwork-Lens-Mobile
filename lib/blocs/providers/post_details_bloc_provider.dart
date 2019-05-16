import 'package:flutter/material.dart';
import '../post_details_bloc.dart';

class PostDetailsBlocProvider extends InheritedWidget {
  final PostDetailsBloc bloc;

  PostDetailsBlocProvider(this.bloc,
      {Key key, @required Widget child})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(PostDetailsBlocProvider oldWidget) {
    return true;
  }

  static PostDetailsBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PostDetailsBlocProvider)
            as PostDetailsBlocProvider)
        .bloc;
  }
}
