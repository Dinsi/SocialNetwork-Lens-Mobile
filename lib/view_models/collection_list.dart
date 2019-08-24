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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:rxdart/subjects.dart';

class CollectionListModel extends BaseModel {
  final _repository = locator<Repository>();
  final _appInfo = locator<AppInfo>();

  final _canPopController = PublishSubject<bool>();
  int _postId;
  bool _isAddToCollection;

  //////////////////////////////////////////////////////////////////////

  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _newCollectionController;

  //////////////////////////////////////////////////////////////////////
  // * Init
  void init(bool isAddToCollection, int postId) {
    _isAddToCollection = isAddToCollection;
    _postId = postId;
  }

  //////////////////////////////////////////////////////////////////////
  // * Dispose
  @override
  void dispose() {
    _canPopController.close();

    _newCollectionController?.dispose();
  }

  //////////////////////////////////////////////////////////////////////
  // * Public Functions
  bool existsInCollection(int index) {
    return _appInfo.currentUser.collections[index].posts.contains(_postId);
  }

  //////////////////////////////////////////////////////////////////////

  Future<void> onCollectionTap(BuildContext context, int index) async {
    CompactCollection targetCollection =
        _appInfo.currentUser.collections[index];

    if (_isAddToCollection) {
      if (!existsInCollection(index)) {
        Collection result = await _updateCollection(index);
        if (result != null) {
          //TODO only covers valid response
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

  //////////////////////////////////////////////////////////////////////

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

    if (dialogResult == null || dialogResult == false) {
      return;
    }

    // Prevent user from using the back button
    _toggleCanPop(false);

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
          CompactCollection.fromJson(newCollection.toJson());

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
        // Grant access to back button
        _toggleCanPop(true);
        showInSnackBar(
            context, scaffoldKey, 'Collection ($newCollectionName) created');
      }
    } else {
      showInSnackBar(context, scaffoldKey,
          'Server error: could not create new collection');
    }
  }

  //////////////////////////////////////////////////////////////////////
  //* Private Functions
  void _toggleCanPop(bool event) {
    if (!_canPopController.isClosed) {
      _canPopController.sink.add(event);
    }
  }

  Future<Collection> _updateCollection(int index) async {
    CompactCollection targetCollection =
        _appInfo.currentUser.collections[index];

    Collection result =
        await _repository.appendPostToCollection(targetCollection.id, _postId);

    if (result != null) {
      await _appInfo.updateUserCollection(index, _postId, result);
    }

    return result;
  }

  Future<Collection> _createCollection(String newCollectionName) =>
      _repository.postNewCollection(newCollectionName);

  //////////////////////////////////////////////////////////////////////
  // * Getters
  bool get isAddToCollection => _isAddToCollection;
  int get postId => _postId;

  Stream<bool> get canPopStream => _canPopController.stream;
}
