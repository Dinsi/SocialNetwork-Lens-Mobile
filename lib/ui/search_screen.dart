import 'package:aperture/models/search_result.dart';
import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/shared/loading_lists/scroll_loading_list_view.dart';
import 'package:aperture/view_models/search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SimpleBaseView<SearchModel>(
        onModelReady: (model) => model.init(context),
        builder: (context, model, _) {
          return NotificationListener<ScrollNotification>(
            onNotification: model.onNotification,
            child: Scaffold(
              appBar: AppBar(
                leading: IconButton(
                  icon: const BackButtonIcon(),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    Navigator.of(context).pop();
                    FocusScope.of(context).unfocus();
                  },
                ),
                titleSpacing: 0.0,
                title: Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: const BoxDecoration(
                    color: const Color(0xFFE5E5E5),
                    borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20.0,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: TextField(
                            autofocus: true,
                            focusNode: model.searchFocusNode,
                            controller: model.searchTextController,
                            cursorColor: Colors.grey[600],
                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 16.0),
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.only(top: 6.0),
                              isDense: true,
                              hintStyle: const TextStyle(color: Colors.grey),
                              hintText: 'Search...',
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      GestureDetector(
                        onTap: () => model.searchTextController.clear(),
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Icon(
                            Icons.cancel,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: StreamBuilder<bool>(
                stream: model.isFetchingStream,
                initialData: false,
                builder: (context, snapshot) {
                  return !snapshot.data
                      ? Container()
                      : ScrollLoadingListView<SearchResult>(
                          model: model,
                          widgetAdapter: (key, searchResult) {
                            IconData iconData;
                            switch (searchResult.type) {
                              case SearchResultType.hashtag:
                                iconData = FontAwesomeIcons.hashtag;
                                break;

                              case SearchResultType.city:
                                iconData = Icons.location_city;
                                break;

                              case SearchResultType.user:
                                iconData = FontAwesomeIcons.userAlt;
                                break;

                              default:
                            }

                            return ListTile(
                              key: key,
                              title: Text(searchResult.name),
                              leading: Icon(iconData),
                              onTap: () => model.navigateToTopicOrUserScreen(
                                  context, searchResult),
                            );
                          },
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
