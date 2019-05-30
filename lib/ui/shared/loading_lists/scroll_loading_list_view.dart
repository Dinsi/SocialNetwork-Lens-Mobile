import 'package:flutter/widgets.dart';

import 'loading_list_view.dart';

class ScrollLoadingListView extends LoadingListView {
  ScrollLoadingListView(
      {@required WidgetAdapter widgetAdapter, @required BaseFeedBloc bloc})
      : super(widgetAdapter: widgetAdapter, bloc: bloc);

  @override
  _ScrollLoadingListViewState createState() => _ScrollLoadingListViewState();
}

class _ScrollLoadingListViewState
    extends LoadingListViewState<ScrollLoadingListView> {}
