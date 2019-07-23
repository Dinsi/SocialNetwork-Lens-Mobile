import 'package:aperture/ui/shared/basic_post.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/enums/subscribe_button.dart';
import 'package:aperture/view_models/providers/topic_feed_bloc_provider.dart';
import 'package:aperture/view_models/topic_feed_bloc.dart';
import 'package:flutter/material.dart';

class TopicFeedScreen extends StatefulWidget {
  const TopicFeedScreen({Key key}) : super(key: key);

  @override
  _TopicFeedScreenState createState() => _TopicFeedScreenState();
}

class _TopicFeedScreenState extends State<TopicFeedScreen> {
  TopicFeedBloc bloc;
  bool _isInit;

  @override
  void initState() {
    super.initState();
    _isInit = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_isInit) {
      bloc = TopicFeedBlocProvider.of(context);
      /*WidgetsBinding.instance
          .addPostFrameCallback((_) => bloc.initSubscribeButton());*/
      _isInit = false;
    }
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${bloc.topic}'),
        leading: BackButton(),
        actions: <Widget>[
          StreamBuilder<SubscribeButton>(
            stream: bloc.subscriptionButton,
            initialData: bloc.initSubscribeButton(),
            builder: (BuildContext context,
                AsyncSnapshot<SubscribeButton> snapshot) {
              if (snapshot.hasData) {
                switch (snapshot.data) {
                  case SubscribeButton.subscribe:
                    return MaterialButton(
                      child: Text(
                        'SUBSCRIBE',
                        style: Theme.of(context).textTheme.button.merge(
                              TextStyle(color: Colors.blue),
                            ),
                      ),
                      onPressed: () => bloc.toggleSubscribe('subscribe'),
                    );

                  case SubscribeButton.subscribeInactive:
                    return MaterialButton(
                      child: Text(
                        'SUBSCRIBE',
                        style: Theme.of(context).textTheme.button.merge(
                              TextStyle(color: Colors.grey),
                            ),
                      ),
                      onPressed: null,
                    );

                  case SubscribeButton.unsubscribe:
                    return FlatButton.icon(
                      icon: Icon(
                        Icons.check,
                        color: Colors.blue,
                      ),
                      label: Text(
                        'SUBSCRIBED',
                        style: Theme.of(context).textTheme.button.merge(
                              TextStyle(color: Colors.blue),
                            ),
                      ),
                      onPressed: () => bloc.toggleSubscribe('unsubscribe'),
                    );

                  case SubscribeButton.unsubscribeInactive:
                    return FlatButton.icon(
                      icon: Icon(
                        Icons.check,
                        color: Colors.grey,
                      ),
                      label: Text(
                        'SUBSCRIBED',
                        style: Theme.of(context).textTheme.button.merge(
                              TextStyle(color: Colors.grey),
                            ),
                      ),
                      onPressed: null,
                    );
                }
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: ScrollLoadingListView(
        widgetAdapter: (dynamic post) => BasicPost(post: post, bloc: bloc),
        bloc: bloc,
      ),
    );
  }
}
