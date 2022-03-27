// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'current_index.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$CurrentIndexTearOff {
  const _$CurrentIndexTearOff();

  _CurrentIndex call(int index, Handler handler,
      [List<PadElement> foregrounds = const []]) {
    return _CurrentIndex(
      index,
      handler,
      foregrounds,
    );
  }
}

/// @nodoc
const $CurrentIndex = _$CurrentIndexTearOff();

/// @nodoc
mixin _$CurrentIndex {
  int get index => throw _privateConstructorUsedError;
  Handler get handler => throw _privateConstructorUsedError;
  List<PadElement> get foregrounds => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CurrentIndexCopyWith<CurrentIndex> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrentIndexCopyWith<$Res> {
  factory $CurrentIndexCopyWith(
          CurrentIndex value, $Res Function(CurrentIndex) then) =
      _$CurrentIndexCopyWithImpl<$Res>;
  $Res call({int index, Handler handler, List<PadElement> foregrounds});
}

/// @nodoc
class _$CurrentIndexCopyWithImpl<$Res> implements $CurrentIndexCopyWith<$Res> {
  _$CurrentIndexCopyWithImpl(this._value, this._then);

  final CurrentIndex _value;
  // ignore: unused_field
  final $Res Function(CurrentIndex) _then;

  @override
  $Res call({
    Object? index = freezed,
    Object? handler = freezed,
    Object? foregrounds = freezed,
  }) {
    return _then(_value.copyWith(
      index: index == freezed
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      handler: handler == freezed
          ? _value.handler
          : handler // ignore: cast_nullable_to_non_nullable
              as Handler,
      foregrounds: foregrounds == freezed
          ? _value.foregrounds
          : foregrounds // ignore: cast_nullable_to_non_nullable
              as List<PadElement>,
    ));
  }
}

/// @nodoc
abstract class _$CurrentIndexCopyWith<$Res>
    implements $CurrentIndexCopyWith<$Res> {
  factory _$CurrentIndexCopyWith(
          _CurrentIndex value, $Res Function(_CurrentIndex) then) =
      __$CurrentIndexCopyWithImpl<$Res>;
  @override
  $Res call({int index, Handler handler, List<PadElement> foregrounds});
}

/// @nodoc
class __$CurrentIndexCopyWithImpl<$Res> extends _$CurrentIndexCopyWithImpl<$Res>
    implements _$CurrentIndexCopyWith<$Res> {
  __$CurrentIndexCopyWithImpl(
      _CurrentIndex _value, $Res Function(_CurrentIndex) _then)
      : super(_value, (v) => _then(v as _CurrentIndex));

  @override
  _CurrentIndex get _value => super._value as _CurrentIndex;

  @override
  $Res call({
    Object? index = freezed,
    Object? handler = freezed,
    Object? foregrounds = freezed,
  }) {
    return _then(_CurrentIndex(
      index == freezed
          ? _value.index
          : index // ignore: cast_nullable_to_non_nullable
              as int,
      handler == freezed
          ? _value.handler
          : handler // ignore: cast_nullable_to_non_nullable
              as Handler,
      foregrounds == freezed
          ? _value.foregrounds
          : foregrounds // ignore: cast_nullable_to_non_nullable
              as List<PadElement>,
    ));
  }
}

/// @nodoc

class _$_CurrentIndex implements _CurrentIndex {
  const _$_CurrentIndex(this.index, this.handler,
      [this.foregrounds = const []]);

  @override
  final int index;
  @override
  final Handler handler;
  @JsonKey()
  @override
  final List<PadElement> foregrounds;

  @override
  String toString() {
    return 'CurrentIndex(index: $index, handler: $handler, foregrounds: $foregrounds)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CurrentIndex &&
            const DeepCollectionEquality().equals(other.index, index) &&
            const DeepCollectionEquality().equals(other.handler, handler) &&
            const DeepCollectionEquality()
                .equals(other.foregrounds, foregrounds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(index),
      const DeepCollectionEquality().hash(handler),
      const DeepCollectionEquality().hash(foregrounds));

  @JsonKey(ignore: true)
  @override
  _$CurrentIndexCopyWith<_CurrentIndex> get copyWith =>
      __$CurrentIndexCopyWithImpl<_CurrentIndex>(this, _$identity);
}

abstract class _CurrentIndex implements CurrentIndex {
  const factory _CurrentIndex(int index, Handler handler,
      [List<PadElement> foregrounds]) = _$_CurrentIndex;

  @override
  int get index;
  @override
  Handler get handler;
  @override
  List<PadElement> get foregrounds;
  @override
  @JsonKey(ignore: true)
  _$CurrentIndexCopyWith<_CurrentIndex> get copyWith =>
      throw _privateConstructorUsedError;
}
