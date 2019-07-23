import 'dart:async';

import 'package:aperture/blocs/enums/search_state.dart';
import 'package:aperture/locator.dart';
import 'package:aperture/models/search_result.dart';
import 'package:aperture/resources/repository.dart';
import 'package:flutter/material.dart' show TextEditingController;

class SearchBloc {
  Repository _repository;
  StreamController<SearchState> _searchController;

  List<SearchResult> _results;

  int dsa = 0;

  SearchBloc()
      : _repository = locator<Repository>(),
        _searchController = StreamController<SearchState>.broadcast();

  Future<void> fetchSearchResults(
      String query, TextEditingController controller) async {
    List<SearchResult> searchResults;
    if (dsa == 0) {
      dsa++;
      searchResults = await Future.delayed(
          Duration(seconds: 2), () => _repository.fetchSearchResults(query));
    } else {
      searchResults = await _repository.fetchSearchResults(query);
    }

    if (!_searchController.isClosed && query == controller.text) {
      _results = searchResults;
      _searchController.add(SearchState.list);
    }
  }

  void shiftStateToEmpty() {
    _searchController.add(SearchState.empty);
  }

  Stream<SearchState> get searchStream => _searchController.stream;
  List<SearchResult> get results => _results;

  void dispose() {
    _searchController.close();
  }
}
