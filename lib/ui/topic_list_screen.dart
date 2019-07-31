import 'package:aperture/view_models/core/enums/checkbox_state.dart';
import 'package:aperture/view_models/topic_list_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopicListScreen extends StatefulWidget {
  @override
  _TopicListScreenState createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  TopicListBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = TopicListBloc();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  Future<void> _saveUserTopics() async {
    await bloc.saveUserTopics();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(bloc.willPop),
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(),
          title: Text('List of Topics'),
          actions: <Widget>[
            StreamBuilder<bool>(
              stream: bloc.saveButton,
              initialData: true,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
                      ? () {
                          _saveUserTopics();
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: bloc.topics.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(
                '${bloc.topics[index]}',
                style: Theme.of(context).textTheme.title,
              ),
              leading: Icon(
                bloc.topics[index].type == 0
                    ? FontAwesomeIcons.hashtag
                    : FontAwesomeIcons.userAlt,
              ),
              trailing: StreamBuilder<CheckBoxState>(
                stream: bloc.getStream(index),
                initialData: CheckBoxState.Checked,
                builder: (BuildContext context,
                    AsyncSnapshot<CheckBoxState> snapshot) {
                  return Checkbox(
                    value: (snapshot.data == CheckBoxState.Checked ||
                            snapshot.data == CheckBoxState.CheckedDisabled
                        ? true
                        : false),
                    onChanged: (snapshot.data == CheckBoxState.Checked ||
                            snapshot.data == CheckBoxState.Unchecked
                        ? (bool newValue) {
                            bloc.shiftTopic(newValue, index);
                          }
                        : null),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
