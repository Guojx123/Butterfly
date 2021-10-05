import 'package:butterfly/painter/eraser.dart';
import 'package:butterfly/painter/painter.dart';
import 'package:butterfly/painter/path_eraser.dart';
import 'package:butterfly/painter/pen.dart';
import 'package:butterfly/painter/text.dart';
import 'package:flutter/widgets.dart';

import 'elements/element.dart';
import 'elements/paint.dart';
import 'elements/label.dart';

@immutable
class AppDocument {
  final String name, description;
  //final List<PackCollection> packs;
  final List<ElementLayer> content;
  final List<Painter> painters;

  const AppDocument(
      {required this.name,
      this.description = '',
      this.content = const [],
      this.painters = const [PenPainter()]});

  AppDocument.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        description = json['description'],
        painters = (json['painters'] as List<Map<String, dynamic>>).map<Painter>((e) {
          switch (e['type']) {
            case 'eraser':
              return EraserPainter.fromJson(e);
            case 'path-eraser':
              return PathEraserPainter.fromJson(e);
            case 'pen':
              return PenPainter.fromJson(e);
            case 'label':
              return LabelPainter.fromJson(e);
            default:
              throw Exception('Unknown element type: ${e['type']}');
          }
        }).toList(),
        content = (json['content'] as List<Map<String, dynamic>>).map<ElementLayer>((e) {
          switch (e['type']) {
            case 'label':
              return LabelElement.fromJson(e);
            case 'paint':
              return PaintElement.fromJson(e);
            default:
              throw Exception('Unknown element type: ${e['type']}');
          }
        }).toList();
  AppDocument copyWith(
      {String? name, String? description, List<ElementLayer>? content, List<Painter>? painters}) {
    return AppDocument(
        name: name ?? this.name,
        description: description ?? this.description,
        content: content ?? this.content,
        painters: painters ?? this.painters);
  }
}
