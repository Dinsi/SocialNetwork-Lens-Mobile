import 'package:aperture/models/users/user.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/collection_list.dart';
import 'package:flutter/material.dart';
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
      child: SimpleBaseView<CollectionListModel>(
        onModelReady: (model) => model.init(isAddToCollection, postId),
        builder: (context, model, _) {
          return StreamBuilder<bool>(
              initialData: true,
              stream: model.canPopStream,
              builder: (context, snapshot) {
                final canPop = snapshot.data;

                return WillPopScope(
                  onWillPop: () => Future.value(canPop),
                  child: Scaffold(
                    key: model.scaffoldKey,
                    appBar: AppBar(
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
                            : ListView.builder(
                                itemCount: collectionList.length,
                                itemBuilder: (context, index) {
                                  return Material(
                                    child: InkWell(
                                      onTap: () =>
                                          model.onCollectionTap(context, index),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                          height: 60.0,
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                width: 80.0,
                                                height: 60.0,
                                                decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: (collectionList[index]
                                                            .cover ==
                                                        null
                                                    ? null
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child: Image.network(
                                                          collectionList[index]
                                                              .cover,
                                                          fit: BoxFit.fitWidth,
                                                        ),
                                                      )),
                                              ),
                                              const SizedBox(width: 20.0),
                                              Text(
                                                collectionList[index].name,
                                                style: model.isAddToCollection &&
                                                        model
                                                            .existsInCollection(
                                                                index)
                                                    ? Theme.of(context)
                                                        .textTheme
                                                        .title
                                                        .copyWith(
                                                            color: Colors.grey)
                                                    : Theme.of(context)
                                                        .textTheme
                                                        .title,
                                              ),
                                              const Expanded(
                                                child: const SizedBox(),
                                              ),
                                              Text(
                                                (collectionList.length == 1
                                                    ? '1 photo'
                                                    : '${collectionList[index].length.toString()} photos'),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .subtitle
                                                    .copyWith(
                                                        color:
                                                            Colors.grey[600]),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      },
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
