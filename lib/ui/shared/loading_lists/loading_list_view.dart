import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:flutter/material.dart';

typedef WidgetAdapter<T> = Widget Function(ObjectKey key, T t);

const _circularIndicatorHeight = 100.0;

abstract class LoadingListView<T> extends StatefulWidget {
  final BaseFeedMixin<T> model;
  final WidgetAdapter<T> widgetAdapter;

  LoadingListView({this.model, this.widgetAdapter});
}

abstract class LoadingListViewState<T, LListViewT extends LoadingListView<T>>
    extends State<LListViewT> {
  @override
  void initState() {
    super.initState();
    widget.model
        .fetch(false)
        .then((_) => widget.model.afterInitialFetch(_circularIndicatorHeight));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<T>>(
      stream: widget.model.listStream,
      builder: (BuildContext context, AsyncSnapshot<List<T>> snapshot) {
        if (snapshot.hasData) {
          return _buildList(snapshot.data);
        } else {
          return const Center(
            child: const SizedBox(
              height: 70.0,
              child: const Center(
                child: const CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildList(List<T> list) {
    return ListView.builder(
      itemCount: widget.model.existsNext ? list.length + 1 : list.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == list.length && widget.model.existsNext) {
          return const SizedBox(
            height: _circularIndicatorHeight,
            child: const Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
              child: const Center(
                child: const CircularProgressIndicator(
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                ),
              ),
            ),
          );
        }

        return widget.widgetAdapter(ObjectKey(list[index]), list[index]);
      },
      physics: (widget is ScrollLoadingListView
          ? const AlwaysScrollableScrollPhysics()
          : null),
      primary: widget is ScrollLoadingListView,
      shrinkWrap: !(widget is ScrollLoadingListView),
    );
  }
}
