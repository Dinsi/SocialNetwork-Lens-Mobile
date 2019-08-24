import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/core/enums/checkbox_state.dart';
import 'package:aperture/view_models/topic_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TopicListScreen extends StatefulWidget {
  @override
  _TopicListScreenState createState() => _TopicListScreenState();
}

class _TopicListScreenState extends State<TopicListScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<TopicListModel>(
      builder: (context, model, _) {
        return WillPopScope(
          onWillPop: () => Future.value(model.state == TopicListViewState.Idle),
          child: SafeArea(
            child: Scaffold(
              appBar: AppBar(
                leading: BackButton(),
                title: Text('List of Topics'),
                actions: <Widget>[
                  FlatButton.icon(
                    icon: Icon(
                      Icons.check,
                      color: model.state == TopicListViewState.Idle
                          ? Colors.red
                          : Colors.grey,
                    ),
                    label: Text(
                      'SAVE',
                      style: Theme.of(context).textTheme.button.merge(
                            TextStyle(
                              color: model.state == TopicListViewState.Idle
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                          ),
                    ),
                    onPressed: model.state == TopicListViewState.Idle
                        ? () => model.saveUserTopics(context)
                        : null,
                  ),
                ],
              ),
              body: ListView.builder(
                itemCount: model.topics.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      '${model.topics[index]}',
                      style: Theme.of(context).textTheme.title,
                    ),
                    leading: Icon(
                      model.topics[index].type == 0
                          ? FontAwesomeIcons.hashtag
                          : FontAwesomeIcons.userAlt,
                    ),
                    trailing: StreamBuilder<CheckBoxState>(
                      stream: model.getStreamByIndex(index),
                      initialData: CheckBoxState.Checked,
                      builder: (context, snapshot) {
                        return Checkbox(
                          value: snapshot.data == CheckBoxState.Checked ||
                                  snapshot.data == CheckBoxState.CheckedDisabled
                              ? true
                              : false,
                          onChanged: snapshot.data == CheckBoxState.Checked ||
                                  snapshot.data == CheckBoxState.Unchecked
                              ? (newValue) => model.toggleTopic(newValue, index)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
