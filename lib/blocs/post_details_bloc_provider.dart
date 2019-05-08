import 'package:flutter/material.dart';
import 'post_details_bloc.dart';
export 'post_details_bloc.dart';

class PostDetailsBlocProvider extends InheritedWidget {
  final PostDetailsBloc bloc;

  PostDetailsBlocProvider({Key key, @required int postId, @required Widget child})
      : bloc = PostDetailsBloc(postId),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_) {
    return true;
  }

  static PostDetailsBloc of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(PostDetailsBlocProvider)
            as PostDetailsBlocProvider)
        .bloc;
  }
}