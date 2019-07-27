import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/mixins/base_feed_model.dart';
import 'package:flutter/widgets.dart';

class NoScrollLoadingListView<T> extends LoadingListView<T> {
  NoScrollLoadingListView(
      {@required BaseFeedMixin<T> model,
      @required WidgetAdapter<T> widgetAdapter})
      : super(model: model, widgetAdapter: widgetAdapter);

  @override
  _NoScrollLoadingListViewState<T> createState() =>
      _NoScrollLoadingListViewState<T>(this.model, this.widgetAdapter);
}

class _NoScrollLoadingListViewState<T>
    extends LoadingListViewState<NoScrollLoadingListView, T> {
  _NoScrollLoadingListViewState(
      BaseFeedMixin<T> model, WidgetAdapter<T> widgetAdapter)
      : super(model, widgetAdapter);
}
