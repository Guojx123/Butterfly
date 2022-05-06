part of 'handler.dart';

class EraserHandler extends Handler {
  Map<int, EraserElement> elements = {};
  List<EraserElement> submittedElements = [];

  EraserHandler();

  @override
  List<Renderer> createForegrounds(AppDocument document, [Area? currentArea]) {
    return elements.values.map((e) => EraserRenderer(e)).toList()
      ..addAll(submittedElements.map((e) => EraserRenderer(e)));
  }

  @override
  void onPointerUp(
      Size viewportSize, BuildContext context, PointerUpEvent event) {
    addPoint(context, event.pointer, event.localPosition, event.pressure,
        event.kind, false);
    submitElement(viewportSize, context, event.pointer);
  }

  void submitElement(Size viewportSize, BuildContext context, int index) {
    final bloc = context.read<DocumentBloc>();
    final transform = context.read<TransformCubit>().state;
    var element = elements.remove(index);
    if (element == null) return;
    submittedElements.add(element);
    if (elements.isEmpty) {
      bloc
        ..add(ElementsCreated(List<PadElement>.from(submittedElements)))
        ..add(ImageBaked(viewportSize, transform.size, transform));
    } else {
      bloc.add(const IndexRefreshed());
    }
  }

  void addPoint(BuildContext context, int pointer, Offset localPosition,
      double pressure, PointerDeviceKind kind,
      [bool refresh = true]) {
    final bloc = context.read<DocumentBloc>();
    final transform = context.read<TransformCubit>().state;
    final state = bloc.state as DocumentLoadSuccess;
    final painter = state.currentPainter as EraserPainter;
    final inputType = context.read<SettingsCubit>().state.inputType;
    if (!inputType.canCreate(pointer, elements.keys.firstOrNull, kind)) {
      return;
    }

    final element = elements[pointer] ??
        EraserElement(
          layer: state.currentLayer,
          property: painter.property
              .copyWith(strokeWidth: painter.property.strokeWidth),
        );

    elements[pointer] = element.copyWith(
        points: List<PathPoint>.from(element.points)
          ..add(PathPoint.fromOffset(
              transform.localToGlobal(localPosition), pressure)));
    if (refresh) bloc.add(const IndexRefreshed());
  }

  @override
  void onPointerDown(
      Size viewportSize, BuildContext context, PointerDownEvent event) {
    // Clean up submitted elements
    if (elements.isEmpty) {
      submittedElements.clear();
    }
    addPoint(context, event.pointer, event.localPosition, event.pressure,
        event.kind);
  }

  @override
  void onPointerMove(
          Size viewportSize, BuildContext context, PointerMoveEvent event) =>
      addPoint(context, event.pointer, event.localPosition, event.pressure,
          event.kind);
}
