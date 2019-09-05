import 'package:flutter/material.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool selectedAll;
  final int selected;
  final void Function() onTap;
  final List<Widget> actions;

  const SelectionAppBar({
    @required this.selectedAll,
    @required this.selected,
    @required this.onTap,
    @required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 25.0,
                child: IgnorePointer(
                  child: Checkbox(
                    value: selectedAll,
                    onChanged: (_) {},
                  ),
                ),
              ),
              Text(
                'Select all',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(fontSize: 10.0),
              ),
            ],
          ),
        ),
      ),
      title: Text(selected == 0 ? 'Select items' : '$selected selected'),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
