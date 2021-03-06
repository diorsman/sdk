// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library error_ref_element;

import 'dart:html';
import 'dart:async';
import 'package:observatory/models.dart'
  show ErrorRef;
import 'package:observatory/src/elements/helpers/tag.dart';
import 'package:observatory/src/elements/helpers/rendering_scheduler.dart';

class ErrorRefElement extends HtmlElement implements Renderable {
  static const tag = const Tag<ErrorRefElement>('error-ref-wrapped');

  RenderingScheduler<ErrorRefElement> _r;

  Stream<RenderedEvent<ErrorRefElement>> get onRendered => _r.onRendered;

  ErrorRef _error;
  
  ErrorRef get error => _error;

  factory ErrorRefElement(ErrorRef error, {RenderingQueue queue}) {
    assert(error != null);
    ErrorRefElement e = document.createElement(tag.name);
    e._r = new RenderingScheduler<ErrorRefElement>(e, queue: queue);
    e._error = error;
    return e;
  }

  ErrorRefElement.created() : super.created();

  @override
  void attached() {
    super.attached();
    _r.enable();
  }

  @override
  void detached() {
    super.detached();
    children = [];
    _r.disable(notify: true);
  }

  void render() {
    children = [
      new PreElement()..text = error.message
    ];
  }
}
