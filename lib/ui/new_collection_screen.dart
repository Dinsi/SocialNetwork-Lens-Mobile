import 'package:aperture/view_models/new_collection_bloc.dart';
import 'package:aperture/models/collections/compact_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewCollectionScreen extends StatefulWidget {
  final NewCollectionBloc bloc;
  final bool addToCollection;
  final int postId;

  const NewCollectionScreen(
      {Key key,
      @required this.bloc,
      @required this.addToCollection,
      this.postId})
      : assert(addToCollection == false ||
            (addToCollection == true && postId != null)),
        super(key: key);

  @override
  _NewCollectionScreenState createState() =>
      _NewCollectionScreenState(this.bloc);
}

class _NewCollectionScreenState extends State<NewCollectionScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _collectionNameController = TextEditingController();

  NewCollectionBloc bloc;

  _NewCollectionScreenState(this.bloc);

  @override
  void dispose() {
    _collectionNameController.dispose();

    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.close),
            iconSize: 28.0,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('New collection'),
          actions: <Widget>[
            StreamBuilder(
              stream: bloc.saveButton,
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return FlatButton.icon(
                  icon: Icon(
                    Icons.check,
                    color: snapshot.data ? Colors.blue : Colors.grey,
                  ),
                  label: Text(
                    'SAVE',
                    style: Theme.of(context).textTheme.button.merge(
                          TextStyle(
                            color: snapshot.data ? Colors.blue : Colors.grey,
                          ),
                        ),
                  ),
                  onPressed: snapshot.data
                      ? () async {
                          FocusScope.of(context).requestFocus(FocusNode());
                          final collectionName = _collectionNameController.text;
                          final result = await bloc.postNewCollection(
                              collectionName, widget.postId);

                          if (result is CompactCollection) {
                            Navigator.of(context).pop(result);
                          } else {
                            switch (result) {
                              case -1:
                                _showInSnackBar(
                                    'The collection name cannot be empty');
                                break;
                              case 1:
                                _showInSnackBar(
                                    'An error has occurred in the server');
                            }
                          }
                        }
                      : () {},
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Name',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextField(
                controller: _collectionNameController,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(64),
                ],
                decoration: InputDecoration(
                  hintText: 'Insert a collection name (max: 64)',
                ),
              ),
            ],
          ),
        ));
  }

  void _showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(new SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            fontFamily: "WorkSansSemiBold"),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }
}
