import 'package:flutter/widgets.dart' show BuildContext, protected;

abstract class DeletableListItems {
  @protected
  Map<int, bool> checkBoxStates;
  int selected = 0;

  void triggerDeleteMode(int index);
  void onItemTap(BuildContext context, int index);
  void toggleSelectAll();
  bool isItemSelected(int index);
  void deleteItems(BuildContext context);

  bool get selectedAll;
}
