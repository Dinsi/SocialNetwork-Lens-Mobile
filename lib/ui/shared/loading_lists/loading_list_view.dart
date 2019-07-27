import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/mixins/base_feed_model.dart';
import 'package:flutter/material.dart';

typedef WidgetAdapter<T> = Widget Function(T t);

const _circularIndicatorHeight = 100.0;

abstract class LoadingListView<T> extends StatefulWidget {
  final BaseFeedMixin<T> model;
  final WidgetAdapter<T> widgetAdapter;

  LoadingListView({this.model, this.widgetAdapter});
}

abstract class LoadingListViewState<T extends LoadingListView, TT>
    extends State<T> {
  LoadingListViewState(this.model, this.widgetAdapter);

  BaseFeedMixin<TT> model;

  /// Used for building Widgets out of
  /// the fetched data
  WidgetAdapter<TT> widgetAdapter;

  @override
  void initState() {
    super.initState();
    model.fetch(false).then((_) => model.afterInitialFetch(_circularIndicatorHeight));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TT>>(
      stream: model.listStream,
      builder: (BuildContext context, AsyncSnapshot<List<TT>> snapshot) {
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

  Widget _buildList(List<TT> list) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        if (model.existsNext && index == list.length - 1) {
          return Column(
            children: <Widget>[
              widgetAdapter(list[index]),
              const SizedBox(
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
              ),
            ],
          );
        }

        return widgetAdapter(list[index]);
      },
      physics: (widget is ScrollLoadingListView
          ? const AlwaysScrollableScrollPhysics()
          : null),
      primary: widget is ScrollLoadingListView,
      shrinkWrap: !(widget is ScrollLoadingListView),
    );
  }
}
