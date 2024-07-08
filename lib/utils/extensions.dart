import 'package:flutter/widgets.dart';

extension SizedBoxExtension on int {
  SizedBox get height => SizedBox(height: toDouble());

  SizedBox get width => SizedBox(width: toDouble());
}
