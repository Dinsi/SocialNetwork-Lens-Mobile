import 'package:aperture/view_models/base_model.dart';
import 'package:aperture/locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//* Widgets
class SimpleBaseView<T extends BaseModel> extends StatefulWidget {
  final Function(T model) onModelReady;
  final Widget Function(BuildContext context, T model, Widget child) builder;

  const SimpleBaseView({Key key, this.onModelReady, @required this.builder})
      : super(key: key);

  @override
  _SimpleBaseViewState<T> createState() => _SimpleBaseViewState<T>();
}

class ChangeNotifierBaseView<TT extends StateModel> extends StatefulWidget {
  final void Function(TT model) onModelReady;
  final Widget Function(BuildContext context, TT model, Widget child) builder;

  const ChangeNotifierBaseView(
      {Key key, this.onModelReady, @required this.builder})
      : super(key: key);

  @override
  _ChangeNotifierBaseViewState<TT> createState() =>
      _ChangeNotifierBaseViewState<TT>();
}

//* States
class _SimpleBaseViewState<T extends BaseModel> extends State<SimpleBaseView<T>> {
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
      child: Consumer<T>(builder: widget.builder),
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
      child: Consumer<TT>(builder: widget.builder),
    );
  }
}
