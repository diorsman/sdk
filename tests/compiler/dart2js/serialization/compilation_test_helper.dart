// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart2js.serialization_compilation_test;

import 'dart:async';
import 'package:async_helper/async_helper.dart';
import 'package:compiler/src/commandline_options.dart';
import 'package:compiler/src/filenames.dart';
import '../memory_compiler.dart';
import 'helper.dart';
import 'test_data.dart';
import '../output_collector.dart';

/// Number of tests that are not part of the automatic test grouping.
int SKIP_COUNT = 2;

/// Number of groups that the [TESTS] are split into.
int SPLIT_COUNT = 4;

main(List<String> args) {
  asyncTest(() async {
    Arguments arguments = new Arguments.from(args);
    SerializedData serializedData =
        await serializeDartCore(arguments: arguments);
    if (arguments.filename != null) {
      Uri entryPoint = Uri.base.resolve(nativeToUriPath(arguments.filename));
      await compile(
          entryPoint,
          resolutionInputs: serializedData.toUris(),
          sourceFiles: serializedData.toMemorySourceFiles());
    } else {
      Uri entryPoint = Uri.parse('memory:main.dart');
      await arguments.forEachTest(serializedData, TESTS, compile);
    }
    printMeasurementResults();
  });
}

Future compile(
    Uri entryPoint,
    {Map<String, String> sourceFiles: const <String, String>{},
     List<Uri> resolutionInputs,
     int index,
     Test test,
     bool verbose: false}) async {
  String testDescription = test != null ? test.name : '${entryPoint}';
  String id = index != null ? '$index: ' : '';
  String title = '${id}${testDescription}';
  OutputCollector outputCollector = new OutputCollector();
  await measure(title, 'compile', () async {
    List<String> options = [];
    if (test.checkedMode) {
      options.add(Flags.enableCheckedMode);
    }
    await runCompiler(
        entryPoint: entryPoint,
        memorySourceFiles: sourceFiles,
        resolutionInputs: resolutionInputs,
        options: options,
        outputProvider: outputCollector);
  });
  if (verbose) {
    print(outputCollector.getOutput('', 'js'));
  }
}

