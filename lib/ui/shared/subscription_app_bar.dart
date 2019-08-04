import 'package:aperture/ui/core/base_view.dart';
import 'package:aperture/view_models/shared/subscription_app_bar.dart';
import 'package:flutter/material.dart';

class SubscriptionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String topicOrUser;

  final Color actionColor;
  final Color backgroundColor;
  final Color disabledActionColor;
  final Widget leading;
  final Widget title;

  const SubscriptionAppBar({
    Color actionColor,
    this.backgroundColor,
    Color disabledActionColor,
    this.leading,
    @required this.title,
    @required this.topicOrUser,
  })  : this.actionColor = actionColor ?? Colors.blue,
        this.disabledActionColor = disabledActionColor ?? Colors.grey;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierBaseView<SubscriptionAppBarModel>(
      onModelReady: (model) => model.init(topicOrUser),
      builder: (_, model, __) {
        return AppBar(
          backgroundColor: backgroundColor ?? AppBarTheme.of(context).color,
          leading: leading ?? BackButton(),
          title: title,
          actions: <Widget>[
            _buildSubscribeButton(context, model),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  Widget _buildSubscribeButton(
      BuildContext context, SubscriptionAppBarModel model) {
    switch (model.state) {
      case SubscriptionAppBarViewState.Subscribe:
        return FlatButton(
          child: Text(
            'SUBSCRIBE',
            style: Theme.of(context).textTheme.button.merge(
                  TextStyle(color: actionColor),
                ),
          ),
          onPressed: () => model.toggleSubscribe(),
        );

      case SubscriptionAppBarViewState.DisabledSubscribe:
        return FlatButton(
          child: Text(
            'SUBSCRIBE',
            style: Theme.of(context).textTheme.button.merge(
                  TextStyle(color: disabledActionColor),
                ),
          ),
          onPressed: null,
        );

      case SubscriptionAppBarViewState.Unsubscribe:
        return FlatButton.icon(
          icon: Icon(
            Icons.check,
            color: actionColor,
          ),
          label: Text(
            'SUBSCRIBED',
            style: Theme.of(context).textTheme.button.merge(
                  TextStyle(color: actionColor),
                ),
          ),
          onPressed: () => model.toggleSubscribe(),
        );

      case SubscriptionAppBarViewState.DisabledUnsubscribe:
        return FlatButton.icon(
          icon: Icon(
            Icons.check,
            color: disabledActionColor,
          ),
          label: Text(
            'SUBSCRIBED',
            style: Theme.of(context).textTheme.button.merge(
                  TextStyle(color: disabledActionColor),
                ),
          ),
          onPressed: null,
        );

      default:
        return Container();
    }
  }
}
