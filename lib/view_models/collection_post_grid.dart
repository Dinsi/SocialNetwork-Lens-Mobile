import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart' show BuildContext, Navigator;

enum CollectionPostGridViewState { Idle, Loading }

class CollectionPostGridModel extends StateModel<CollectionPostGridViewState> {
  final _repository = locator<Repository>();

  String _collectionName;
  Collection _collection;

  CollectionPostGridModel() : super(CollectionPostGridViewState.Loading);

  Future<void> init(int collectionId, String collectionName) async {
    _collectionName = collectionName;
    _collection = await _repository.fetchCollection(collectionId);
    setState(CollectionPostGridViewState.Idle);
  }

  void navigateToDetailPostScreen(BuildContext context, int index) {
    BasicPostModel subModel = locator<BasicPostModel>()
      ..init(_collection.posts[index]);

    Navigator.of(context).pushNamed(
      RouteName.detailedPost,
      arguments: subModel,
    );
  }

  String get collectionName => _collectionName;
  int get collectionLength => _collection.length;
  List<Post> get collectionPosts => _collection.posts;
}
