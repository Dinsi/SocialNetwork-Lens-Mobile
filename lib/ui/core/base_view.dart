import 'package:aperture/view_models/core/base_model.dart';
import 'package:aperture/locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//* Widgets
class SimpleBaseView<T extends BaseModel> extends StatefulWidget {
  final Function(T) onModelReady;
  final Widget Function(BuildContext, T, Widget) builder;
  final Widget child;

  const SimpleBaseView({this.onModelReady, @required this.builder})
      : child = null;

  const SimpleBaseView.noConsumer({this.onModelReady, @required this.child})
      : builder = null;

  @override
  _SimpleBaseViewState<T> createState() => _SimpleBaseViewState<T>();
}

class ChangeNotifierBaseView<TT extends StateModel> extends StatefulWidget {
  final void Function(TT) onModelReady;
  final Widget Function(BuildContext, TT, Widget) builder;
  final Widget child;

  const ChangeNotifierBaseView({this.onModelReady, @required this.builder})
      : child = null;

  const ChangeNotifierBaseView.noConsumer(
      {this.onModelReady, @required this.child})
      : builder = null;

  @override
  _ChangeNotifierBaseViewState<TT> createState() =>
      _ChangeNotifierBaseViewState<TT>();
}

///////////////////////////////////////////////////////
//* States
class _SimpleBaseViewState<T extends BaseModel>
    extends State<SimpleBaseView<T>> {
  T model = locator<T>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider<T>(
      builder: (_) => model,
      dispose: (_, model) => model.dispose(),
      child: widget.child ?? Consumer<T>(builder: widget.builder),
    );
  }
}

class _ChangeNotifierBaseViewState<TT extends StateModel>
    extends State<ChangeNotifierBaseView<TT>> {
  TT model = locator<TT>();

  @override
  void initState() {
    super.initState();
    if (widget.onModelReady != null) {
      widget.onModelReady(model);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TT>(
      builder: (_) => model,
      child: widget.child ?? Consumer<TT>(builder: widget.builder),
    );
  }
}
