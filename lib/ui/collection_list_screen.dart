import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/app_bars/selection_app_bar.dart';
import 'package:aperture/view_models/collection_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class CollectionListScreen extends StatelessWidget {
  final bool isAddToCollection;
  final int postId;

  const CollectionListScreen({
    @required this.isAddToCollection,
    this.postId,
  }) : assert(isAddToCollection == false ||
            (isAddToCollection == true && postId != null));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierBaseView<CollectionListModel>(
        onModelReady: (model) => model.init(isAddToCollection, postId),
        builder: (context, model, _) {
          return WillPopScope(
            onWillPop: model.onWillPop,
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: model.state == CollectionListViewState.DeleteMode
                  ? SelectionAppBar(
                      selectedAll: model.selectedAll,
                      selected: model.selected,
                      onTap: model.toggleSelectAll,
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.trash),
                          onPressed: model.selected == 0
                              ? null
                              : () => model.deleteItems(context),
                        )
                      ],
                    )
                  : AppBar(
                      title: Text(model.isAddToCollection
                          ? 'Add to collection'
                          : 'Collections'),
                      actions: <Widget>[
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () =>
                              model.showNewCollectionDialog(context),
                        ),
                      ],
                    ),
              body: Consumer<User>(
                builder: (context, currentUser, __) {
                  final collectionList = currentUser.collections;

                  return collectionList.isEmpty
                      ? Center(
                          child: Text(
                            'You have no collections',
                            style: TextStyle(
                              fontSize: 21.0,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : _buildCollectionList(model, collectionList);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionList(
    CollectionListModel model,
    List<CompactCollection> collectionList,
  ) {
    return ListView.builder(
      itemCount: collectionList.length,
      itemBuilder: (context, index) {
        return Material(
          type: !model.isAddToCollection && model.isItemSelected(index)
              ? MaterialType.canvas
              : MaterialType.transparency,
          color: Colors.red.withOpacity(0.1),
          child: InkWell(
            onTap: model.state == CollectionListViewState.Busy
                ? null
                : () => model.onItemTap(context, index),
            onLongPress: !model.isAddToCollection &&
                    model.state == CollectionListViewState.Idle
                ? () => model.triggerDeleteMode(index)
                : null,
            child: Padding(
              padding: model.state == CollectionListViewState.DeleteMode
                  ? const EdgeInsets.only(right: 16.0, top: 16.0, bottom: 16.0)
                  : const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 60.0,
                child: Row(
                  children: <Widget>[
                    if (model.state == CollectionListViewState.DeleteMode)
                      IgnorePointer(
                        child: Checkbox(
                          value: model.isItemSelected(index),
                          onChanged: (_) {},
                        ),
                      ),
                    Container(
                      width: 80.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        image: collectionList[index].cover == null
                            ? null
                            : DecorationImage(
                                image: NetworkImage(
                                  collectionList[index].cover,
                                ),
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                    ),
                    const SizedBox(width: 20.0),
                    Text(
                      collectionList[index].name,
                      style: model.isAddToCollection &&
                              model.existsInCollection(index)
                          ? Theme.of(context)
                              .textTheme
                              .title
                              .copyWith(color: Colors.grey)
                          : Theme.of(context).textTheme.title,
                    ),
                    const Expanded(
                      child: const SizedBox(),
                    ),
                    Text(
                      (collectionList[index].length == 1
                          ? '1 photo'
                          : '${collectionList[index].length} photos'),
                      style: Theme.of(context)
                          .textTheme
                          .subtitle
                          .copyWith(color: Colors.grey[600]),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
