import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/feed/base_feed_model.dart';
import 'package:flutter/widgets.dart';

class ScrollLoadingListView extends LoadingListView {
  ScrollLoadingListView(
      {@required WidgetAdapter widgetAdapter, @required BaseFeedModel model})
      : super(widgetAdapter: widgetAdapter, model: model);

  @override
  _ScrollLoadingListViewState createState() => _ScrollLoadingListViewState();
}

class _ScrollLoadingListViewState
    extends LoadingListViewState<ScrollLoadingListView> {}
