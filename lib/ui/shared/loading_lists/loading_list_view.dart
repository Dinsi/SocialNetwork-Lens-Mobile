import 'package:aperture/models/post.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:flutter/material.dart';

typedef WidgetAdapter<T> = Widget Function(ObjectKey key, T t);

const _circularIndicatorHeight = 100.0;

abstract class LoadingListView<T> extends StatefulWidget {
  final BaseFeedMixin<T> model;
  final WidgetAdapter<T> widgetAdapter;
  final bool sliver;

  LoadingListView({this.model, this.widgetAdapter, this.sliver = false});
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
          if (snapshot.data.isEmpty &&
              (snapshot.data is List<Post> ||
                  snapshot.data is List<SearchResult>)) {
            Widget noPostWidget = Center(
              child: Text(
                snapshot.data is List<Post>
                    ? 'There are no posts here!'
                    : 'No results',
                style: Theme.of(context)
                    .textTheme
                    .subhead
                    .copyWith(color: Colors.grey),
              ),
            );

            return widget.sliver
                ? SliverFillRemaining(
                    child: noPostWidget,
                  )
                : noPostWidget;
          }

          return _buildList(snapshot.data);
        } else {
          Widget circularIndicator = Center(
            child: SizedBox(
              height: 70.0,
              child: Center(
                child: defaultCircularIndicator(),
              ),
            ),
          );

          return widget.sliver
              ? SliverFillRemaining(
                  child: circularIndicator,
                )
              : circularIndicator;
        }
      },
    );
  }

  Widget _buildList(List<T> list) {
    final isScrollList = widget is ScrollLoadingListView;

    Function(BuildContext, int) itemBuilder = (context, index) {
      final tWidget = widget.widgetAdapter(ObjectKey(list[index]), list[index]);
      if (index == list.length - 1) {
        return Column(
          children: <Widget>[
            const SizedBox(height: 8.0),
            tWidget,
            !widget.model.existsNext
                ? const SizedBox(height: 8.0)
                : SizedBox(
                    height: _circularIndicatorHeight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
                      child: Center(
                        child: defaultCircularIndicator(),
                      ),
                    ),
                  ),
          ],
        );
      }

      return Column(
        children: <Widget>[
          const SizedBox(height: 8.0),
          tWidget,
        ],
      );
    };

    return widget.sliver
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: list.length,
            ),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: itemBuilder,
            physics:
                isScrollList ? const AlwaysScrollableScrollPhysics() : null,
            primary: isScrollList,
            shrinkWrap: !isScrollList,
          );
  }
}
