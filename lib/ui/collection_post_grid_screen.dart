import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/app_bars/selection_app_bar.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/collection_post_grid.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CollectionPostGridScreen extends StatelessWidget {
  final int collectionId;
  final String collectionName;

  const CollectionPostGridScreen(
      {@required this.collectionId, @required this.collectionName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierBaseView<CollectionPostGridModel>(
        onModelReady: (model) => model.init(collectionId, collectionName),
        builder: (context, model, _) {
          return WillPopScope(
            onWillPop: model.onWillPop,
            child: Scaffold(
              key: model.scaffoldKey,
              appBar: model.state == CollectionPostGridViewState.DeleteMode
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
                      title: Text(model.collectionName),
                    ),
              body: model.state == CollectionPostGridViewState.Loading
                  ? Center(
                      child: defaultCircularIndicator(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                        ),
                        itemCount: model.collectionLength,
                        itemBuilder: (context, index) {
                          switch (model.state) {
                            case CollectionPostGridViewState.Idle:
                              return GestureDetector(
                                onTap: () => model.onItemTap(context, index),
                                onLongPress: () =>
                                    model.triggerDeleteMode(index),
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        model.collectionPosts[index].image,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );

                            case CollectionPostGridViewState.Busy:
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      model.collectionPosts[index].image,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );

                            case CollectionPostGridViewState.DeleteMode:
                              return DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      model.collectionPosts[index].image,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () =>
                                          model.onItemTap(context, index),
                                    ),
                                    Positioned(
                                      top: 10.0,
                                      left: 10.0,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                        ),
                                        child: SizedBox(
                                          height: 25.0,
                                          width: 25.0,
                                          child: IgnorePointer(
                                            child: Checkbox(
                                              value:
                                                  model.isItemSelected(index),
                                              onChanged: (_) {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                            default:
                              return Container();
                          }
                        },
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
