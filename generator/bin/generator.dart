import 'dart:io';
import 'package:generator/generator.dart';

void main(List<String> arguments) async {
  await jsonToIndexFile(
    File('../sfh-index.min.json'),
    await genSFHIndex(),
  );
}
