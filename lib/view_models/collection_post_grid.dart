import 'package:aperture/locator.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/models/post.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/deletable_list_items.dart';
import 'package:aperture/view_models/shared/basic_post.dart';
import 'package:flutter/material.dart';

enum CollectionPostGridViewState { Idle, Loading, DeleteMode, Busy }

class CollectionPostGridModel extends StateModel<CollectionPostGridViewState>
    with DeletableListItems {
  final _repository = locator<Repository>();
  final _appInfo = locator<AppInfo>();

  //////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();

  //////////////////////////////////
  String _collectionName;
  Collection _collection;

  //////////////////////////////////

  CollectionPostGridModel() : super(CollectionPostGridViewState.Loading);

  //////////////////////////////////////////////////////////////////////
  // * Init
  Future<void> init(int collectionId, String collectionName) async {
    _collectionName = collectionName;
    _collection = await _repository.fetchCollection(collectionId);

    final posts = _collection.posts;

    checkBoxStates = Map.fromIterables(
      Iterable.generate(posts.length, (index) => posts[index].id),
      Iterable.generate(posts.length, (_) => false),
    );
    checkBoxStates[0] = false;

    setState(CollectionPostGridViewState.Idle);
  }

  //////////////////////////////////////////////////////////////////////
  // * Dispose
  @override
  void dispose() => super.dispose();

  //////////////////////////////////////////////////////////////////////
  // * Public Functions
  //// * on__ Functions
  Future<bool> onWillPop() {
    switch (state) {
      case CollectionPostGridViewState.DeleteMode:
        checkBoxStates.forEach((key, _) => checkBoxStates[key] = false);
        selected = 0;
        setState(CollectionPostGridViewState.Idle);
        return Future.value(false);

      case CollectionPostGridViewState.Busy:
        return Future.value(false);

      default:
        return Future.value(true);
    }
  }

  ///////////////////////////////////
  //// * DeletableListItems overrides
  @override
  void triggerDeleteMode(int index) {
    checkBoxStates[_collection.posts[index].id] = true;
    selected++;
    setState(CollectionPostGridViewState.DeleteMode);
  }

  ///////////////////////////////////
  @override
  void onItemTap(BuildContext context, int index) {
    if (state == CollectionPostGridViewState.Idle) {
      _navigateToDetailPostScreen(context, index);
    } else {
      // state == CollectionListViewState.DeleteMode
      _onDeleteModeTap(context, index);
    }
  }

  ///////////////////////////////////
  @override
  bool isItemSelected(int index) {
    return checkBoxStates[_collection.posts[index].id] == true;
  }

  ///////////////////////////////////
  @override
  void toggleSelectAll() {
    if (selected == _collection.posts.length) {
      selected = 0;
      checkBoxStates.forEach((key, _) {
        if (checkBoxStates[key] == true) {
          checkBoxStates[key] = false;
        }
      });
    } else {
      selected = _collection.posts.length;
      checkBoxStates.forEach((key, _) {
        if (checkBoxStates[key] == false) {
          checkBoxStates[key] = true;
        }
      });
    }

    notifyListeners();
  }

  ///////////////////////////////////
  @override
  void deleteItems(BuildContext context) async {
    setState(CollectionPostGridViewState.Busy);
    List<int> postIdList;

    if (selectedAll) {
      postIdList = _collection.posts.map((post) => post.id).toList();
    } else {
      postIdList = List(selected);
      int listIndex = 0;

      for (final postId in checkBoxStates.keys) {
        if (checkBoxStates[postId] == false) {
          continue;
        }

        postIdList[listIndex++] = postId;
        if (selected == listIndex) {
          break;
        }
      }
    }

    final result =
        await _repository.removePostsFromCollection(_collection.id, postIdList);

    if (result == 0) {
      _collection.posts.removeWhere((post) => postIdList.contains(post.id));
      _collection.length = _collection.posts.length;

      await _appInfo.updateUserCollection(
        CompactCollection.fromCollection(_collection),
      );

      // Reset variables
      selected = 0;

      final postIdKeyList = checkBoxStates.keys.toList();
      for (final postId in postIdKeyList) {
        if (postIdList.contains(postId)) {
          checkBoxStates.remove(postId);
          continue;
        }

        checkBoxStates[postId] = false;
      }

      setState(CollectionPostGridViewState.Idle);
      showInSnackBar(
          context,
          scaffoldKey,
          postIdList.length == 1
              ? '1 post removed'
              : '${postIdList.length} posts deleted');
    }
  }

  //////////////////////////////////////////////////////////////////////
  // * Private Functions
  void _onDeleteModeTap(BuildContext context, int index) {
    final newValue = !isItemSelected(index);
    checkBoxStates[_collection.posts[index].id] = newValue;
    newValue == true ? selected++ : selected--;

    if (selected == _collection.posts.length) {
      checkBoxStates[0] = true;
    } else {
      if (checkBoxStates[0] == true) {
        checkBoxStates[0] = false;
      }
    }

    notifyListeners();
  }

  /////////////
  //// * Navigation
  void _navigateToDetailPostScreen(BuildContext context, int index) {
    BasicPostModel subModel = locator<BasicPostModel>()
      ..init(_collection.posts[index]);

    Navigator.of(context).pushNamed(
      RouteName.detailedPost,
      arguments: subModel,
    );
  }

  //////////////////////////////////////////////////////////////////////
  // * Getters
  String get collectionName => _collectionName;
  int get collectionLength => _collection.length;
  List<Post> get collectionPosts => _collection.posts;

  @override
  bool get selectedAll => checkBoxStates[0];
}
