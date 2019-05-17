import 'package:flutter/material.dart';
import '../post_details_bloc.dart';

class PostDetailsBlocProvider extends InheritedWidget {
  PostDetailsBlocProvider(this.bloc, {Key key, this.child})
      : super(key: key, child: child);

  final Widget child;
  final PostDetailsBloc bloc;

  static PostDetailsBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PostDetailsBlocProvider)
            as PostDetailsBlocProvider)
        .bloc;
  }

  @override
  bool updateShouldNotify(PostDetailsBlocProvider oldWidget) => false;
}
