import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:recase/recase.dart';

import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  print(
      'Welcome to Flutter Set Assets Program. This program set directory element in dart file. This program was created by "Shuoib Hossain Badon"');
  print('Program Started...');

  await setAssets('anim');
  await setAssets('icons');
  await setAssets('images');
  await setAssets('logos');
  await setAssets('sounds');
  await setAssets('videos');
  print('Program Finished.');
}

Future<void> setAssets(String directoryName) async {
  Directory directory = Directory('${path.current}/assets/$directoryName');
  List<String> elementList = await getDirectoryElement(directory);

  if (elementList.isEmpty) {
    stderr.write('${directoryName.titleCase} directory is empty.\n');
    return;
  }
  String variables = '';
  for (var element in elementList) {
    final elementName = path.basenameWithoutExtension(element).camelCase;
    final variable =
        '''static String get $elementName => 'assets/$directoryName/$element';''';
    variables = await joinText(variables, variable);
  }

  await updateDartFile(directoryName, variables);
  print('The "${directoryName.titleCase}" directory element variables are set in the "app_$directoryName.dart" file. \u2713');
}

Future<String> joinText(String oldText, String newText,
    {bool gap = true}) async {
  if (oldText.isEmpty) {
    return newText;
  } else {
    if (gap) {
      return '$oldText\n  $newText';
    } else {
      return '$oldText\n$newText';
    }
  }
}

Future<List<String>> getDirectoryElement(Directory dir) async {
  List<String> elementList = [];
  var elements = dir.list(recursive: false);
  await elements.forEach((element) {
    final item = element.path.split('/').last.split('\\').last;
    elementList.add(item);
  });

  return elementList;
}

Future<void> updateDartFile(String directoryName, String variables) async {
  final fileDirectory =
      Directory('${path.current}/lib/constants/app_$directoryName.dart');

  final file = File(fileDirectory.path);

  final fileData =
      await file.openRead().map(utf8.decode).transform(LineSplitter()).toList();

  String fileHad = '';
  for (var element in fileData) {
    if (element.contains('class')) break;
    fileHad = await joinText(fileHad, element, gap: false);
  }

  String fileBody = '''
 $fileHad
class App${directoryName.titleCase} {
  App${directoryName.titleCase}._();
  
  $variables
  
}

''';
  await file.writeAsString(fileBody);
}

// dart compile exe bin/flutter_set_assets.dart && dart compile aot-snapshot bin/flutter_set_assets.dart
