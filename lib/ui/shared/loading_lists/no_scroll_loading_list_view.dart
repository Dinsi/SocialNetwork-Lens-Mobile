import 'package:flutter/widgets.dart';

import 'loading_list_view.dart';

class NoScrollLoadingListView extends LoadingListView {
  NoScrollLoadingListView(
      {@required WidgetAdapter widgetAdapter, @required BaseFeedBloc bloc})
      : super(widgetAdapter: widgetAdapter, bloc: bloc);

  @override
  _NoScrollLoadingListViewState createState() =>
      _NoScrollLoadingListViewState();
}

class _NoScrollLoadingListViewState
    extends LoadingListViewState<NoScrollLoadingListView> {}
