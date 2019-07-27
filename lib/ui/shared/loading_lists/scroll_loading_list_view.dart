import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/mixins/base_feed_model.dart';
import 'package:flutter/widgets.dart';

class ScrollLoadingListView<T> extends LoadingListView<T> {
  ScrollLoadingListView(
      {@required BaseFeedMixin<T> model,
      @required WidgetAdapter<T> widgetAdapter})
      : super(model: model, widgetAdapter: widgetAdapter);

  @override
  _ScrollLoadingListViewState<T> createState() =>
      _ScrollLoadingListViewState<T>(this.model, this.widgetAdapter);
}

class _ScrollLoadingListViewState<T>
    extends LoadingListViewState<ScrollLoadingListView, T> {
  _ScrollLoadingListViewState(
      BaseFeedMixin<T> model, WidgetAdapter<T> widgetAdapter)
      : super(model, widgetAdapter);
}
