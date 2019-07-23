import 'package:aperture/view_models/collection_list_bloc.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:flutter/material.dart';

class CollectionListScreen extends StatefulWidget {
  final CollectionListBloc bloc;
  final bool addToCollection;
  final int postId;

  const CollectionListScreen({
    Key key,
    @required this.bloc,
    @required this.addToCollection,
    this.postId,
  })  : assert(addToCollection == false ||
            (addToCollection == true && postId != null)),
        super(key: key);

  @override
  _CollectionListScreenState createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.addToCollection ? 'Add to collection' : 'Collections'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final CompactCollection newCollection =
                  await Navigator.of(context)
                      .pushNamed('/newCollection', arguments: {
                'addToCollection': widget.addToCollection,
                'postId': widget.postId,
              });

              if (newCollection != null) {
                if (widget.addToCollection) {
                  Navigator.of(context).pop(newCollection.name);
                } else {
                  widget.bloc.addToCollections(newCollection);
                  setState(() {});
                }
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (ctx) => (widget.bloc.collections.isEmpty
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
                itemCount: widget.bloc.collections.length,
                itemBuilder: (context, index) {
                  return Material(
                    child: InkWell(
                      onTap: widget.addToCollection
                          ? (!widget.bloc
                                  .existsInCollection(index, widget.postId)
                              ? () async {
                                  Collection result = await widget.bloc
                                      .updateCollection(index, widget.postId);
                                  if (result != null) {
                                    //TODO only covers valid response
                                    Navigator.of(context).pop(
                                        widget.bloc.collections[index].name);
                                  }
                                }
                              : () => _showToast(
                                  ctx, widget.bloc.collections[index].name))
                          : () {
                              Navigator.of(context).pushNamed(
                                '/collectionPosts',
                                arguments: {
                                  'collId': widget.bloc.collections[index].id,
                                  'collName':
                                      widget.bloc.collections[index].name,
                                },
                              );
                            },
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
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: (widget.bloc.collections[index].cover ==
                                        null
                                    ? null
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Image.network(
                                          widget.bloc.collections[index].cover,
                                          fit: BoxFit.fitWidth,
                                        ),
                                      )),
                              ),
                              const SizedBox(width: 20.0),
                              Text(
                                widget.bloc.collections[index].name,
                                style: widget.addToCollection &&
                                        widget.bloc.existsInCollection(
                                            index, widget.postId)
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
                                (widget.bloc.collections[index].length == 1
                                    ? '1 photo'
                                    : '${widget.bloc.collections[index].length.toString()} photos'),
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
              )),
      ),
    );
  }

  void _showToast(BuildContext context, String collName) {
    final scaffold = Scaffold.of(context);
    scaffold.hideCurrentSnackBar();
    scaffold.showSnackBar(
      SnackBar(
        content: Text('$collName already contains current post'),
      ),
    );
  }
}
