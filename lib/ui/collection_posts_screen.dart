import 'package:aperture/router.dart';
import 'package:aperture/view_models/collection_posts_bloc.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:flutter/material.dart';

class CollectionPostsScreen extends StatelessWidget {
  final CollectionPostsBloc bloc;
  final String collName;

  const CollectionPostsScreen(
      {Key key, @required this.bloc, @required this.collName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(collName),
        ),
        body: FutureBuilder<Collection>(
          future: bloc.fetchCollection(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(3.0),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 3.0,
                    mainAxisSpacing: 3.0,
                  ),
                  itemCount: snapshot.data.length,
                  itemBuilder: (ctx, idx) {
                    return GestureDetector(
                      onTap: () => // TODO create basicPostModel and pass it on
                          Navigator.of(context).pushNamed(
                        RouteName.detailedPost,
                        arguments: {
                          'postId': snapshot.data.posts[idx].id,
                          'post': snapshot.data.posts[idx],
                          'toComments': false,
                        },
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
                        child: Image.network(
                          snapshot.data.posts[idx].image,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return const Center(
                child: const CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
