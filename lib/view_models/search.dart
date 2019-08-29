import 'dart:async';
import 'dart:collection';

import 'package:aperture/router.dart';
import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/resources/repository.dart';
import 'package:aperture/view_models/core/mixins/base_feed.dart';
import 'package:flutter/material.dart'
    show BuildContext, Navigator, TextEditingController;
import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';

const _backendListSize = 20;

// TODO implement either switches or '@'/'#' specific searches
class SearchModel extends BaseModel with BaseFeedMixin<SearchResult> {
  final _repository = locator<Repository>();
  final _isFetchingController = BehaviorSubject<bool>.seeded(false);

  ///////////////////////////

  final searchTextController = TextEditingController();
  final searchFocusNode = FocusNode();

  /////////////////////////////////////////////////////////////
  // * Init
  void init(BuildContext context) {
    searchTextController.addListener(() {
      final queryText = searchTextController.text;
      if (queryText.length < 3) {
        if (_isFetchingController.value == true) {
          _isFetchingController.sink.add(false);
          // Clear the list
          listSubject.sink.add(null);
        }

        return;
      }

      if (_isFetchingController.value == false) {
        _isFetchingController.sink.add(true);
      }

      onRefresh();
    });
  }

  /////////////////////////////////////////////////////////////
  // * Dispose
  void dispose() {
    super.dispose();
    _isFetchingController.close();

    searchTextController.dispose();
  }

  /////////////////////////////////////////////////////////////
  // * Override Functions
  @override
  Future<void> fetch(bool refresh) async {
    final queryText = searchTextController.text;
    List<SearchResult> fetchedList;
    int fetchedListSize;

    if (refresh || !listSubject.hasValue) {
      fetchedList = await _repository.fetchSearchResults(queryText, null);

      fetchedListSize = fetchedList.length;
    } else {
      fetchedList = await _repository.fetchSearchResults(
          queryText, listSubject.value.last.id);

      fetchedListSize = fetchedList.length;

      fetchedList = List<SearchResult>.from(listSubject.value)
        ..addAll(fetchedList);
    }

    if (fetchedListSize != _backendListSize) {
      existsNext = false;
    }

    if (!_isFetchingController.isClosed &&
        queryText == searchTextController.text) {
      listSubject.sink.add(UnmodifiableListView<SearchResult>(fetchedList));
    }
  }

  /////////////////////////////////////////////////////////////
  // * Public Functions
  void navigateToTopicOrUserScreen(BuildContext context, SearchResult result) {
    result.type == SearchResultType.user
        ? Navigator.of(context).pushReplacementNamed(
            RouteName.userProfile,
            arguments: result.userId,
          )
        : Navigator.of(context).pushReplacementNamed(
            RouteName.topicFeed,
            arguments: result.name,
          );
  }

  /////////////////////////////////////////////////////////////
  // * Getters
  Stream<bool> get isFetchingStream => _isFetchingController.stream;
}
