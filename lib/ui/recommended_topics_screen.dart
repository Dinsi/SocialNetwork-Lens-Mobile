import 'package:aperture/ui/base_view.dart';
import 'package:aperture/view_models/recommended_topics_model.dart';
import 'package:flutter/material.dart';

const double _itemHeight = 70.0;

class RecommendedTopicsScreen extends StatelessWidget {
  const RecommendedTopicsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: ChangeNotifierBaseView<RecommendedTopicsModel>(
            onModelReady: (model) => model.getRecommendedTopics(),
            builder: (context, model, _) {
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: 150.0,
                    child: Center(
                      child: Text(
                        'Welcome ${model.userUsername}!\nTo get you started, select a few topics of your interest!',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  (model.state == RecTopViewState.Loading
                      ? const SizedBox(
                          height: 150.0,
                          child: const Center(
                            child: const CircularProgressIndicator(),
                          ),
                        )
                      : Wrap(
                          children: _getTopicWidgets(context, model),
                        )),
                  SizedBox(height: 50.0),
                  Center(
                    child: RaisedButton(
                      disabledColor: Colors.grey,
                      onPressed: model.state != RecTopViewState.Busy
                          ? () => model.sendTopics(context)
                          : null,
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
              );
            },
          ),
        ),
      ),
    );
  }

  List<Widget> _getTopicWidgets(
      BuildContext context, RecommendedTopicsModel model) {
    return [
      for (final topic in model.topicList) ...[
        GestureDetector(
          onTap: () => model.toggleTopic(topic),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 2 - 12.0,
              maxHeight: _itemHeight,
            ),
            margin: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 20.0),
            decoration: BoxDecoration(
              color: model.recommendedTopics[topic]
                  ? Colors.white
                  : Colors.grey[400],
              border: Border.all(
                color: Colors.blue,
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Text(
                '${topic.name}',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ),
      ]
    ];
  }
}
