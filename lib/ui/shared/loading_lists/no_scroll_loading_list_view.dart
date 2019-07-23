import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/base_feed_bloc.dart';
import 'package:flutter/widgets.dart';

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
