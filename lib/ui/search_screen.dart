import 'package:aperture/blocs/enums/search_state.dart';
import 'package:aperture/blocs/search_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchTextController;
  FocusNode _searchFocusNode;

  SearchBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = SearchBloc();
    _searchFocusNode = FocusNode();
    _searchTextController = TextEditingController();
    _searchTextController.addListener(() {
      _shiftBlocState(_searchTextController.text);
    });
  }

  @override
  void dispose() {
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    bloc.dispose();
    super.dispose();
  }

  void _shiftBlocState(String value) {
    if (value.length == 0) {
      bloc.shiftStateToEmpty();
      return;
    }

    if (value.length >= 3) {
      bloc.fetchSearchResults(value, _searchTextController);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0.0,
        title: Container(
          margin: const EdgeInsets.fromLTRB(0.0, 8.0, 8.0, 8.0),
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
          ),
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
                    controller: _searchTextController,
                    cursorColor: Colors.grey[600],
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      isDense: true,
                      hintStyle: const TextStyle(color: Colors.grey),
                      hintText: 'Search...',
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: const BorderSide(
                          style: BorderStyle.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5.0),
              GestureDetector(
                onTap: () {
                  _searchTextController.clear();
                },
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
      body: StreamBuilder<SearchState>(
        stream: bloc.searchStream,
        initialData: SearchState.empty,
        builder: (BuildContext context, AsyncSnapshot<SearchState> snapshot) {
          switch (snapshot.data) {
            case SearchState.empty:
              return Container();
            case SearchState.list:
              return ListView.builder(
                itemCount: bloc.results.length,
                itemBuilder: (context, index) => ListTile(
                      title: Text(bloc.results[index].name),
                      leading: Icon(
                        bloc.results[index].type == 0
                            ? FontAwesomeIcons.hashtag
                            : FontAwesomeIcons.userAlt,
                      ),
                      onTap: () => (bloc.results[index].type == 0
                          ? Navigator.of(context).pushNamed(
                              '/topicFeed',
                              arguments: bloc.results[index].name,
                            )
                          : Navigator.of(context).pushNamed(
                              '/userProfile',
                              arguments: {
                                'id': bloc.results[index].userId,
                                'username': bloc.results[index].name,
                              },
                            )),
                    ),
              );
          }
        },
      ),
    );
  }
}
