import 'package:flutter/material.dart';

import 'user_info_screen.dart';
import '../models/topic.dart';
import '../blocs/recommended_topics_bloc.dart';

const double _itemHeight = 70.0;

class RecommendedTopicsScreen extends StatefulWidget {
  const RecommendedTopicsScreen({Key key}) : super(key: key);

  _RecommendedTopicsScreenState createState() =>
      _RecommendedTopicsScreenState();
}

class _RecommendedTopicsScreenState extends State<RecommendedTopicsScreen> {
  List<Topic> _recommendedTopics;
  List<int> _selectedTopics = List<int>();

  List<Color> _colorVariables;

  VoidCallback _onPressedFunction;

  @override
  void initState() {
    super.initState();
    _getRecommendedTopics();
  }

  Future _getRecommendedTopics() async {
    List<Topic> topics = await recommendedTopicsBloc.recommendedTopics();
    _colorVariables = List<Color>(topics.length);
    _colorVariables.fillRange(0, topics.length, Colors.white);

    setState(() {
      _onPressedFunction = () => _sendTopics();
      _recommendedTopics = topics;
    });
  }

  List<Widget> _getTopicWidgets() {
    List<Widget> widgets = List<Widget>();
    for (int i = 0; i < _recommendedTopics.length; i++) {
      widgets.add(
        GestureDetector(
          onTap: () => _toggleTopic(i, _recommendedTopics[i].id),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 2 - 12.0,
              maxHeight: _itemHeight,
            ),
            margin: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 20.0),
            decoration: BoxDecoration(
              color: _colorVariables[i],
              border: Border.all(
                color: Colors.blue,
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Text(
                '${_recommendedTopics[i].name}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  void _toggleTopic(int targetIndex, int topicId) {
    if (_colorVariables[targetIndex] == Colors.white) {
      _selectedTopics.add(topicId);
      setState(() => _colorVariables[targetIndex] = Colors.grey[400]);
    } else {
      _selectedTopics.remove(topicId);
      setState(() => _colorVariables[targetIndex] = Colors.white);
    }
  }

  Future _sendTopics() async {
    setState(() => _onPressedFunction = null);
    int code = await recommendedTopicsBloc.finishRegister(_selectedTopics);
    if (code == 0) {
      final replacementWidget = UserInfoScreen();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<Null>(
          builder: (context) => replacementWidget,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 150.0,
                child: Center(
                  child: Text(
                    'Welcome ${recommendedTopicsBloc.userUsername}!\nTo get you started, select a few topics of your interest!',
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              (_recommendedTopics == null
                  ? const SizedBox(
                      height: 150.0,
                      child: const Center(
                        child: const CircularProgressIndicator(),
                      ),
                    )
                  : Wrap(
                      children: _getTopicWidgets(),
                    )),
              SizedBox(height: 50.0),
              Center(
                child: RaisedButton(
                  disabledColor: Colors.grey,
                  onPressed: _onPressedFunction,
                  color: Colors.blue,
                  child: Text(
                    "Continue...",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
/*Center(
        child: FlatButton(
          child: Text("Click to continue..."),
          onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<Null>(
                  builder: (context) => UserInfoScreen(),
                ),
              ),
        ),
      ),*/
