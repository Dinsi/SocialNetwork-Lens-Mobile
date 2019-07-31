import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:flutter/widgets.dart';

class ScrollLoadingListView<T> extends LoadingListView<T> {
  ScrollLoadingListView(
      {@required BaseFeedMixin<T> model,
      @required WidgetAdapter<T> widgetAdapter})
      : super(model: model, widgetAdapter: widgetAdapter);

  @override
  _ScrollLoadingListViewState<T> createState() =>
      _ScrollLoadingListViewState<T>();
}

class _ScrollLoadingListViewState<T>
    extends LoadingListViewState<T, ScrollLoadingListView<T>> {}
