bool isUrl(String input) {
  return RegExp(
          r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)')
      .hasMatch(input);
}

bool isEmail(String input) {
  return RegExp(
          r'^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(input);
}

List<String> detectHashtags(String description) {
  int currentIndex = 0;
  List<String> splits = List<String>();

  List<Match> matches =
      RegExp(r'(?:^|\n+|\W+)(#[a-z0-9A-Z]+)').allMatches(description).toList();

  if (matches.isEmpty) {
    splits.add(description);
    return splits;
  }

  while (currentIndex != description.length - 1) {
    // matches.first.start -> first index of string
    if (matches.isNotEmpty) {
      if (currentIndex == matches.first.start) {
        splits.add(matches.first.group(1));
        currentIndex = matches.first.end;
        matches.remove(matches.first);
        continue;
      }

      splits.add(description.substring(currentIndex, matches.first.start));
      currentIndex = matches.first.start;
      continue;
    }

    splits.add(description.substring(currentIndex, description.length));
    break;
  }

  return splits;
}

String nFormatter(double number) {
  final List<Map<dynamic, dynamic>> si = const [
    {"value": 1, "symbol": ""},
    {"value": 1E3, "symbol": "k"},
    {"value": 1E6, "symbol": "M"},
    {"value": 1E9, "symbol": "B"}
  ];
  final rx = RegExp(r"\.0+$|(\.[0-9]*[1-9]*)0+$");
  int i;
  for (i = si.length - 1; i > 0; i--) {
    if (number >= si[i]["value"]) {
      break;
    }
  }

  String resultNumber;
  if (number <= 99999) {
    resultNumber = (number / si[i]["value"]).toStringAsFixed(1);
  } else {
    resultNumber = (number / si[i]["value"]).floorToDouble().toStringAsFixed(0);
  }

  return resultNumber.replaceAllMapped(rx, (match) {
        return match.group(1) ?? "";
      }) +
      si[i]["symbol"];
}
