part of 'document_bloc.dart';

enum StorageType {
  local,
  cloud,
}

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentLoadInProgress extends DocumentState {}

class DocumentLoadFailure extends DocumentState {
  final String message;

  const DocumentLoadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class DocumentLoadSuccess extends DocumentState {
  final AppDocument document;
  final StorageType storageType;
  final String currentLayer;
  final String currentAreaName;
  final List<String> invisibleLayers;
  final SettingsCubit settingsCubit;
  final CurrentIndexCubit currentIndexCubit;

  DocumentLoadSuccess(this.document,
      {AssetLocation? location,
      this.storageType = StorageType.local,
      required this.settingsCubit,
      required this.currentIndexCubit,
      this.currentAreaName = '',
      this.currentLayer = '',
      this.invisibleLayers = const []}) {
    if (location != null) {
      currentIndexCubit.setSaveState(location: location);
    }
  }

  @override
  List<Object?> get props => [
        invisibleLayers,
        document,
        currentLayer,
        currentAreaName,
        settingsCubit,
        currentIndexCubit,
      ];

  Area? get currentArea {
    return document.getAreaByName(currentAreaName);
  }

  CameraViewport get cameraViewport => currentIndexCubit.state.cameraViewport;

  List<Renderer<PadElement>> get renderers => currentIndexCubit.renderers;

  AssetLocation get location => currentIndexCubit.state.location;
  bool get saved => !location.absolute && currentIndexCubit.state.saved;

  Embedding? get embedding => currentIndexCubit.state.embedding;

  DocumentLoadSuccess copyWith({
    AppDocument? document,
    bool? editMode,
    String? currentLayer,
    String? currentAreaName,
    List<String>? invisibleLayers,
  }) =>
      DocumentLoadSuccess(
        document ?? this.document,
        invisibleLayers: invisibleLayers ?? this.invisibleLayers,
        currentLayer: currentLayer ?? this.currentLayer,
        currentAreaName: currentAreaName ?? this.currentAreaName,
        settingsCubit: settingsCubit,
        currentIndexCubit: currentIndexCubit,
        location: location,
      );

  bool isLayerVisible(String layer) => !invisibleLayers.contains(layer);

  bool hasAutosave() =>
      !(embedding?.save ?? true) ||
      (!kIsWeb &&
          !location.absolute &&
          (location.remote.isEmpty ||
              (settingsCubit.state
                      .getRemote(location.remote)
                      ?.hasDocumentCached(location.path) ??
                  false)));

  Future<AssetLocation> save() {
    final storage = getRemoteStorage();
    if (embedding != null) return Future.value(AssetLocation.local(''));
    if (location.path == '' ||
        location.absolute ||
        location.fileType != AssetFileType.note) {
      return DocumentFileSystem.fromPlatform(remote: storage)
          .importDocument(document)
          .then((value) => value.location)
        ..then(settingsCubit.addRecentHistory);
    }
    return DocumentFileSystem.fromPlatform(remote: storage)
        .updateDocument(location.path, document)
        .then((value) => value.location)
      ..then(settingsCubit.addRecentHistory);
  }

  RemoteStorage? getRemoteStorage() => location.remote.isEmpty
      ? null
      : settingsCubit.state.getRemote(location.remote);

  Future<void> bake(
          {Size? viewportSize, double? pixelRatio, bool reset = false}) =>
      currentIndexCubit.bake(document,
          viewportSize: viewportSize, pixelRatio: pixelRatio, reset: reset);

  Painter? get painter => currentIndexCubit.state.handler.data;
}
