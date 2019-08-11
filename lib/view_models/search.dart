import 'dart:async';

import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/material.dart'
    show BuildContext, FocusNode, Navigator, TextEditingController;
import 'package:rxdart/subjects.dart';

class SearchModel extends BaseModel {
  final _repository = locator<Repository>();
  final _searchResultsController = BehaviorSubject<List<SearchResult>>();

  ///////////////////////////

  final searchTextController = TextEditingController();

  ///////////////////////////

  Future _searchRequest;

  /////////////////////////////////////////////////////////////
  // * Init
  void init() {
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
    _searchResultsController.close();

    searchTextController.dispose();
  }

  /////////////////////////////////////////////////////////////
  // * Public Functions
  void navigateToTopicOrUserScreen(BuildContext context, int index) {
    final targetSearchResult = _searchResultsController.value[index];

    targetSearchResult.type == 0
        ? Navigator.of(context).pushNamed(
            RouteName.topicFeed,
            arguments: targetSearchResult.name,
          )
        : Navigator.of(context).pushNamed(
            RouteName.userProfile,
            arguments: targetSearchResult.userId,
          );
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
