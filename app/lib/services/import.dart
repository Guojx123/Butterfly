import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:butterfly/api/file_system.dart';
import 'package:butterfly/bloc/document_bloc.dart';
import 'package:butterfly/cubits/current_index.dart';
import 'package:butterfly/models/area.dart';
import 'package:butterfly/models/element.dart';
import 'package:butterfly/models/painter.dart';
import 'package:butterfly/renderers/renderer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/parser.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../dialogs/error.dart';
import '../dialogs/image_export.dart';
import '../dialogs/pages.dart';
import '../dialogs/pdf_export.dart';
import '../dialogs/svg_export.dart';
import '../models/converter.dart';
import '../models/document.dart';

class ImportService {
  final DocumentBloc bloc;
  final BuildContext context;

  ImportService(this.bloc, this.context);

  Future<void> load([String type = '', Object? data]) async {
    final state = bloc.state;
    if (state is! DocumentLoadSuccess) return;
    final location = state.location;
    Uint8List? bytes;
    if (data is Uint8List) {
      bytes = data;
    } else if (data is String) {
      bytes = Uint8List.fromList(utf8.encode(data));
    } else {
      bytes =
          await DocumentFileSystem.fromPlatform().loadAbsolute(location.path);
    }
    final fileType =
        type.isNotEmpty ? AssetFileType.values.byName(type) : location.fileType;
    if (bytes == null || fileType == null) return;
    await import(fileType, bytes);
  }

  Future<void> import(AssetFileType type, Uint8List bytes,
      {Offset? position, bool meta = true}) async {
    switch (type) {
      case AssetFileType.note:
        return importNote(bytes, position, meta);
      case AssetFileType.image:
        return importImage(bytes, position);
      case AssetFileType.svg:
        return importSvg(bytes, position);
      case AssetFileType.pdf:
        return importPdf(bytes, position, true);
      default:
        return Future.value();
    }
  }

  void importNote(Uint8List bytes, [Offset? position, bool meta = true]) {
    final firstPos = position ?? Offset.zero;
    final doc = const DocumentJsonConverter().fromJson(
      json.decode(
        String.fromCharCodes(bytes),
      ),
    );
    if (meta) {
      bloc.add(DocumentUpdated(doc));
    }
    final areas = doc.areas
        .map((e) => e.copyWith(position: e.position + firstPos))
        .toList();
    final content = doc.content
        .map((e) =>
            Renderer.fromInstance(e)
                .transform(position: firstPos, relative: true)
                ?.element ??
            e)
        .toList();
    bloc
      ..add(AreasCreated(areas))
      ..add(ElementsCreated(content));
  }

  Future<void> importImage(Uint8List bytes, [Offset? position]) async {
    final firstPos = position ?? Offset.zero;
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image.clone();

    final newBytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final state = bloc.state;
    if (state is! DocumentLoadSuccess) return;
    _submit(elements: [
      ImageElement(
          height: image.height.toDouble(),
          width: image.width.toDouble(),
          layer: state.currentLayer,
          pixels: newBytes?.buffer.asUint8List() ?? Uint8List(0),
          position: firstPos)
    ], choosePosition: position == null);
  }

  Future<void> importSvg(Uint8List bytes, [Offset? position]) async {
    final firstPos = position ?? Offset.zero;
    final contentString = String.fromCharCodes(bytes);
    final SvgParser parser = SvgParser();
    try {
      var document = await parser.parse(contentString,
          warningsAsErrors: true, key: contentString);
      final size = document.viewport.viewBox;
      var height = size.height, width = size.width;
      if (!height.isFinite) height = 0;
      if (!width.isFinite) width = 0;
      _submit(elements: [
        SvgElement(
          width: width,
          height: height,
          data: contentString,
          position: firstPos,
        ),
      ], choosePosition: position == null);
    } catch (e, stackTrace) {
      showDialog<void>(
          context: context,
          builder: (context) => ErrorDialog(
                error: e,
                stackTrace: stackTrace,
              ));
    }
  }

  Future<void> importPdf(Uint8List bytes,
      [Offset? position, bool createAreas = false]) async {
    final firstPos = position ?? Offset.zero;
    final elements = <Uint8List>[];
    final localizations = AppLocalizations.of(context);
    await for (var page in Printing.raster(bytes)) {
      final png = await page.toPng();
      elements.add(png);
    }
    if (context.mounted) {
      final callback = await showDialog<PageDialogCallback>(
          context: context, builder: (context) => PagesDialog(pages: elements));
      if (callback == null) return;
      final selectedElements = <ImageElement>[];
      final areas = <Area>[];
      var y = firstPos.dx;
      await for (var page in Printing.raster(bytes,
          pages: callback.pages, dpi: PdfPageFormat.inch * callback.quality)) {
        final png = await page.toPng();
        final scale = 1 / callback.quality;
        final height = page.height;
        final width = page.width;
        selectedElements.add(ImageElement(
            height: height.toDouble(),
            width: width.toDouble(),
            pixels: png,
            constraints:
                ElementConstraints.scaled(scaleX: scale, scaleY: scale),
            position: Offset(firstPos.dx, y)));
        if (createAreas) {
          areas.add(Area(
            height: height * scale,
            width: width * scale,
            position: Offset(firstPos.dx, y),
            name: localizations.pageIndex(areas.length + 1),
          ));
        }
        if (createAreas) {
          bloc.add(AreasCreated(areas));
        }
      }
      _submit(
        elements: selectedElements,
        areas: createAreas ? areas : [],
        choosePosition: position == null,
      );
    }
  }

  Future<void> export() async {
    final state = bloc.state;
    if (state is! DocumentLoadSuccess) return;
    final location = state.location;
    final fileType = location.fileType;
    final viewport = context.read<CurrentIndexCubit>().state.cameraViewport;
    switch (fileType) {
      case AssetFileType.note:
        final data =
            json.encode(const DocumentJsonConverter().toJson(state.document));
        final bytes = Uint8List.fromList(data.codeUnits);
        DocumentFileSystem.fromPlatform().saveAbsolute(location.path, bytes);
        break;
      case AssetFileType.image:
        return showDialog<void>(
            context: context,
            builder: (context) => BlocProvider.value(
                value: bloc,
                child: ImageExportDialog(
                  height: viewport.height ?? 1000,
                  width: viewport.width ?? 1000,
                  scale: viewport.scale,
                  x: viewport.x,
                  y: viewport.y,
                )));
      case AssetFileType.pdf:
        return showDialog<void>(
            context: context,
            builder: (context) => BlocProvider.value(
                value: bloc,
                child: PdfExportDialog(
                    areas: state.document.getAreaNames().toList())));
      case AssetFileType.svg:
        return showDialog<void>(
            context: context,
            builder: (context) => BlocProvider.value(
                value: bloc,
                child: SvgExportDialog(
                    width: ((viewport.width ?? 1000) / viewport.scale).round(),
                    height:
                        ((viewport.height ?? 1000) / viewport.scale).round(),
                    x: viewport.x,
                    y: viewport.y)));
      default:
        return;
    }
  }

  void _submit({
    required List<PadElement> elements,
    List<Area> areas = const [],
    bool choosePosition = false,
  }) {
    final state = bloc.state;
    if (choosePosition && state is DocumentLoadSuccess) {
      state.currentIndexCubit.changeTemporaryHandler(
          bloc, ImportPainter(elements: elements, areas: areas));
    } else {
      bloc
        ..add(ElementsCreated(elements))
        ..add(AreasCreated(areas));
    }
  }
}
