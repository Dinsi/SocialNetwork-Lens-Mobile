import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/ui/utils/shortcuts.dart';
import 'package:aperture/view_models/recommended_topics.dart';
import 'package:flutter/material.dart';

const double _itemHeight = 70.0;

class RecommendedTopicsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
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
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  model.state == RecTopViewState.Loading
                      ? SizedBox(
                          height: 150.0,
                          child: Center(
                            child: defaultCircularIndicator(),
                          ),
                        )
                      : Wrap(
                          children: _getTopicWidgets(context, model),
                        ),
                  const SizedBox(height: 50.0),
                  Center(
                    child: RaisedButton(
                      disabledColor: Colors.grey,
                      onPressed: model.state != RecTopViewState.Busy
                          ? () => model.sendTopics(context)
                          : null,
                      color: Colors.red,
                      child: const Text(
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
                  ? Colors.grey[400]
                  : Colors.white,
              border: Border.all(
                color: Colors.red,
                width: 4.0,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Center(
              child: Text(
                '${topic.name}',
                style: const TextStyle(
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
