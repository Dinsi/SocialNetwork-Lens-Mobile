import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/feed/base_feed_model.dart';
import 'package:flutter/widgets.dart';

class NoScrollLoadingListView extends LoadingListView {
  NoScrollLoadingListView(
      {@required WidgetAdapter widgetAdapter, @required BaseFeedModel model})
      : super(widgetAdapter: widgetAdapter, model: model);

  @override
  _NoScrollLoadingListViewState createState() =>
      _NoScrollLoadingListViewState();
}

class _NoScrollLoadingListViewState
    extends LoadingListViewState<NoScrollLoadingListView> {}
