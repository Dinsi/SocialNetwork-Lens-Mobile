import 'package:aperture/ui/shared/loading_lists/loading_list_view.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:flutter/widgets.dart';

class NoScrollLoadingListView<T> extends LoadingListView<T> {
  NoScrollLoadingListView(
      {@required BaseFeedMixin<T> model,
      @required WidgetAdapter<T> widgetAdapter})
      : super(model: model, widgetAdapter: widgetAdapter);

  @override
  _NoScrollLoadingListViewState<T> createState() =>
      _NoScrollLoadingListViewState<T>();
}

class _NoScrollLoadingListViewState<T>
    extends LoadingListViewState<T, NoScrollLoadingListView<T>> {}
