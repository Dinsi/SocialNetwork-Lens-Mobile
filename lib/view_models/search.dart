import 'dart:async';

import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/material.dart'
    show BuildContext, Navigator, TextEditingController;
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:rxdart/subjects.dart';

// TODO needs tweaking

class SearchModel extends BaseModel {
  final _repository = locator<Repository>();
  final _searchResultsController = BehaviorSubject<List<SearchResult>>();
  final _keyboardNotif = KeyboardVisibilityNotification();
  int _notifId;

  ///////////////////////////

  final searchTextController = TextEditingController();
  final searchFocusNode = FocusNode();

  ///////////////////////////

  Future _searchRequest;

  /////////////////////////////////////////////////////////////
  // * Init
  void init(BuildContext context) {
    _notifId = _keyboardNotif.addNewListener(onHide: Navigator.of(context).pop);

    searchTextController.addListener(() {
      final queryText = searchTextController.text;
      if (queryText.length == 0 && _searchResultsController.value != null) {
        _searchResultsController.sink.add(null);
        return;
      }

      if (queryText.length >= 3) {
        _searchRequest?.timeout(const Duration());

        _searchRequest = _fetchSearchResults(queryText).whenComplete(() {
          _searchRequest = null;
        });
      }
    });
  }

  /////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    _keyboardNotif.removeListener(_notifId);
    _keyboardNotif.dispose();

    _searchResultsController.close();

    searchTextController.dispose();
  }

  /////////////////////////////////////////////////////////////
  // * Public Functions
  void navigateToTopicOrUserScreen(BuildContext context, int index) async {
    _keyboardNotif.removeListener(_notifId);

    final targetSearchResult = _searchResultsController.value[index];

    targetSearchResult.type == 0
        ? await Navigator.of(context).pushNamed(
            RouteName.topicFeed,
            arguments: targetSearchResult.name,
          )
        : await Navigator.of(context).pushNamed(
            RouteName.userProfile,
            arguments: targetSearchResult.userId,
          );

    FocusScope.of(context).requestFocus(searchFocusNode);
    _notifId = _keyboardNotif.addNewListener(onHide: Navigator.of(context).pop);
  }

  /////////////////////////////////////////////////////////////
  // * Private Functions
  Future<void> _fetchSearchResults(String queryText) async {
    List<SearchResult> searchResults =
        await _repository.fetchSearchResults(queryText);

    if (!_searchResultsController.isClosed &&
        queryText == searchTextController.text) {
      _searchResultsController.add(searchResults);
    }
  }

  /////////////////////////////////////////////////////////////
  // * Getters
  Stream<List<SearchResult>> get searchResultsStream =>
      _searchResultsController.stream;
}
