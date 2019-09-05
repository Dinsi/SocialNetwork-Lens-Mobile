import 'dart:async';

import 'package:aperture/locator.dart';
import 'package:aperture/models/users/user.dart';
import 'package:aperture/resources/app_info.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/router.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/models/collections/collection.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/view_models/core/deletable_list_items.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;

enum CollectionListViewState { Idle, Busy, DeleteMode }

class CollectionListModel extends StateModel<CollectionListViewState>
    with DeletableListItems {
  final _repository = locator<Repository>();
  final _appInfo = locator<AppInfo>();

  int _postId;
  bool _isAddToCollection;

  //////////////////////////////////////////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _newCollectionController;

  //////////////////////////////////////////////////////////////////////

  CollectionListModel() : super(CollectionListViewState.Idle);

  //////////////////////////////////////////////////////////////////////
  // * Init
  void init(bool isAddToCollection, int postId) {
    _isAddToCollection = isAddToCollection;
    _postId = postId;

    if (!_isAddToCollection) {
      final collections = _appInfo.currentUser.collections;

      checkBoxStates = Map.fromIterables(
        Iterable.generate(collections.length, (index) => collections[index].id),
        Iterable.generate(collections.length, (_) => false),
      );

      checkBoxStates[0] = false;
    }
  }

  //////////////////////////////////////////////////////////////////////
  // * Dispose
  @override
  void dispose() {
    super.dispose();
    _newCollectionController?.dispose();
  }

  //////////////////////////////////////////////////////////////////////
  // * Public Functions
  Future<void> showNewCollectionDialog(BuildContext context) async {
    if (_newCollectionController == null) {
      _newCollectionController = TextEditingController();
    }

    final theme = Theme.of(context);

    final dialogResult = await showDialog<bool>(
      context: context,
      builder: (context) => Theme(
        data: theme.copyWith(primaryColor: Colors.red),
        child: AlertDialog(
          title: Text('Create new collection'),
          content: TextField(
            autofocus: true,
            controller: _newCollectionController,
            textCapitalization: TextCapitalization.sentences,
            inputFormatters: [LengthLimitingTextInputFormatter(64)],
            decoration: InputDecoration(labelText: 'Collection name'),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop<bool>(false),
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop<bool>(true),
            )
          ],
        ),
      ),
    );

    if (dialogResult != true) {
      return;
    }

    // Prevent user from using the back button
    setState(CollectionListViewState.Busy);

    // Validations
    final newCollectionName = _newCollectionController.text.trim();
    _newCollectionController.clear();

    if (newCollectionName.isEmpty) {
      showInSnackBar(context, scaffoldKey, 'A collection must have a name');
      return;
    }

    // Send new collection name to the server
    final newCollection = await _createCollection(newCollectionName);
    if (newCollection != null) {
      User user = _appInfo.currentUser;

      final newCompactCollection =
          CompactCollection.fromCollection(newCollection);

      await _appInfo.addCollectionToUser(newCompactCollection);

      // If the objective is to add a post to a collection, add it to the newly created collection
      if (_isAddToCollection) {
        final updatedCollection =
            await _updateCollection(user.collections.length - 1);

        if (updatedCollection != null) {
          Navigator.of(context).pop(newCollectionName);
        } else {
          showInSnackBar(context, scaffoldKey,
              'Server error: could not add post to collection');
        }
      } else {
        // Add entry for delete checkbox
        checkBoxStates[newCompactCollection.id] = false;

        // Grant access to back button
        setState(CollectionListViewState.Idle);
        showInSnackBar(
            context, scaffoldKey, 'Collection ($newCollectionName) created');
      }
    } else {
      showInSnackBar(context, scaffoldKey,
          'Server error: could not create new collection');
    }
  }

  bool existsInCollection(int index) {
    return _appInfo.currentUser.collections[index].posts.contains(_postId);
  }

  //////////////////////////////////////////////////////////////////////
  //// * DeletableListItems overrides
  @override
  void onItemTap(BuildContext context, int index) {
    if (state == CollectionListViewState.Idle) {
      _onIdleCollectionTap(context, index);
    } else {
      // state == CollectionListViewState.DeleteMode
      _onDeleteModeCollectionTap(context, index);
    }
  }

  ///////////////////////////////////
  @override
  void triggerDeleteMode(int index) {
    checkBoxStates[_appInfo.currentUser.collections[index].id] = true;
    selected++;
    setState(CollectionListViewState.DeleteMode);
  }

  ///////////////////////////////////
  @override
  void toggleSelectAll() {
    final collectionLength = _appInfo.currentUser.collections.length;
    if (selected == collectionLength) {
      selected = 0;
      checkBoxStates.forEach((key, _) {
        if (checkBoxStates[key] == true) {
          checkBoxStates[key] = false;
        }
      });
    } else {
      selected = collectionLength;
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
  bool isItemSelected(int index) {
    return checkBoxStates[_appInfo.currentUser.collections[index].id] == true;
  }

  ///////////////////////////////////
  @override
  void deleteItems(BuildContext context) async {
    setState(CollectionListViewState.Busy);

    List<int> collectionIdList;

    if (selectedAll) {
      collectionIdList = _appInfo.currentUser.collections
          .map((collection) => collection.id)
          .toList();
    } else {
      collectionIdList = List(selected);
      int listIndex = 0;

      for (final collectionId in checkBoxStates.keys) {
        if (checkBoxStates[collectionId] == false) {
          continue;
        }

        collectionIdList[listIndex++] = collectionId;
        if (selected == listIndex) {
          break;
        }
      }
    }

    final result = await _repository.deleteCollections(collectionIdList);

    if (result == 0) {
      await _appInfo.bulkRemoveCollectionsFromUser(collectionIdList);

      // Reset variables
      selected = 0;

      final collectionIdKeyList = checkBoxStates.keys.toList();
      for (final collectionId in collectionIdKeyList) {
        if (collectionIdList.contains(collectionId)) {
          checkBoxStates.remove(collectionId);
          continue;
        }

        checkBoxStates[collectionId] = false;
      }

      setState(CollectionListViewState.Idle);
      showInSnackBar(
          context,
          scaffoldKey,
          collectionIdList.length == 1
              ? '1 collection deleted'
              : '${collectionIdList.length} collections deleted');
    }
  }

  //////////////////////////////////////////////////////////////////////
  // * on__ Functions
  Future<bool> onWillPop() {
    switch (state) {
      case CollectionListViewState.Idle:
        return Future.value(true);

      case CollectionListViewState.Busy:
        return Future.value(false);

      case CollectionListViewState.DeleteMode:
        // Reset checkbox and selected
        checkBoxStates.forEach((key, _) => checkBoxStates[key] = false);
        selected = 0;
        setState(CollectionListViewState.Idle);
        return Future.value(false);

      default:
        return Future.value(false);
    }
  }

  //////////////////////////////////////////////////////////////////////
  //* Private Functions
  Future<Collection> _updateCollection(int index) async {
    CompactCollection targetCollection =
        _appInfo.currentUser.collections[index];

    Collection result =
        await _repository.appendPostToCollection(targetCollection.id, _postId);

    if (result != null) {
      await _appInfo.appendPostToUserCollection(index, _postId, result);
    }

    return result;
  }

  Future<void> _onIdleCollectionTap(BuildContext context, int index) async {
    CompactCollection targetCollection =
        _appInfo.currentUser.collections[index];
    if (_isAddToCollection) {
      if (!existsInCollection(index)) {
        Collection result = await _updateCollection(index);
        if (result != null) {
          Navigator.of(context).pop(targetCollection.name);
        }
      } else {
        showInSnackBar(
          context,
          scaffoldKey,
          '${targetCollection.name} already contains current post',
        );
      }

      return;
    }

    Navigator.of(context).pushNamed(
      RouteName.collectionPosts,
      arguments: {
        'collId': targetCollection.id,
        'collName': targetCollection.name,
      },
    );
  }

  void _onDeleteModeCollectionTap(BuildContext context, int index) {
    final newValue = !isItemSelected(index);
    checkBoxStates[_appInfo.currentUser.collections[index].id] = newValue;
    newValue == true ? selected++ : selected--;

    if (selected == _appInfo.currentUser.collections.length) {
      checkBoxStates[0] = true;
    } else {
      if (checkBoxStates[0] == true) {
        checkBoxStates[0] = false;
      }
    }

    notifyListeners();
  }

  Future<Collection> _createCollection(String newCollectionName) =>
      _repository.postNewCollection(newCollectionName);

  //////////////////////////////////////////////////////////////////////
  // * Getters
  bool get isAddToCollection => _isAddToCollection;
  int get postId => _postId;

  @override
  bool get selectedAll => checkBoxStates[0];
}
