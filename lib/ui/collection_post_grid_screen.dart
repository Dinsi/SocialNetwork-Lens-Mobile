import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/collection_post_grid.dart';
import 'package:flutter/material.dart';

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
          return Scaffold(
            appBar: AppBar(
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
                        crossAxisCount: 4,
                        crossAxisSpacing: 3.0,
                        mainAxisSpacing: 3.0,
                      ),
                      itemCount: model.collectionLength,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              model.navigateToDetailPostScreen(context, index),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              image: DecorationImage(
                                image: NetworkImage(
                                  model.collectionPosts[index].image,
                                ),
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          );
        },
      ),
    );
  }
}
