// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_habit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddHabitParams {

 String get name; String get description; int get points;
/// Create a copy of AddHabitParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddHabitParamsCopyWith<AddHabitParams> get copyWith => _$AddHabitParamsCopyWithImpl<AddHabitParams>(this as AddHabitParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitParams&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points);

@override
String toString() {
  return 'AddHabitParams(name: $name, description: $description, points: $points)';
}


}

/// @nodoc
abstract mixin class $AddHabitParamsCopyWith<$Res>  {
  factory $AddHabitParamsCopyWith(AddHabitParams value, $Res Function(AddHabitParams) _then) = _$AddHabitParamsCopyWithImpl;
@useResult
$Res call({
 String name, String description, int points
});




}
/// @nodoc
class _$AddHabitParamsCopyWithImpl<$Res>
    implements $AddHabitParamsCopyWith<$Res> {
  _$AddHabitParamsCopyWithImpl(this._self, this._then);

  final AddHabitParams _self;
  final $Res Function(AddHabitParams) _then;

/// Create a copy of AddHabitParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? points = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AddHabitParams].
extension AddHabitParamsPatterns on AddHabitParams {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AddHabitParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AddHabitParams() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AddHabitParams value)  $default,){
final _that = this;
switch (_that) {
case _AddHabitParams():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AddHabitParams value)?  $default,){
final _that = this;
switch (_that) {
case _AddHabitParams() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  int points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AddHabitParams() when $default != null:
return $default(_that.name,_that.description,_that.points);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  int points)  $default,) {final _that = this;
switch (_that) {
case _AddHabitParams():
return $default(_that.name,_that.description,_that.points);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  int points)?  $default,) {final _that = this;
switch (_that) {
case _AddHabitParams() when $default != null:
return $default(_that.name,_that.description,_that.points);case _:
  return null;

}
}

}

/// @nodoc


class _AddHabitParams implements AddHabitParams {
  const _AddHabitParams({required this.name, required this.description, required this.points});
  

@override final  String name;
@override final  String description;
@override final  int points;

/// Create a copy of AddHabitParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddHabitParamsCopyWith<_AddHabitParams> get copyWith => __$AddHabitParamsCopyWithImpl<_AddHabitParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddHabitParams&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points);

@override
String toString() {
  return 'AddHabitParams(name: $name, description: $description, points: $points)';
}


}

/// @nodoc
abstract mixin class _$AddHabitParamsCopyWith<$Res> implements $AddHabitParamsCopyWith<$Res> {
  factory _$AddHabitParamsCopyWith(_AddHabitParams value, $Res Function(_AddHabitParams) _then) = __$AddHabitParamsCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, int points
});




}
/// @nodoc
class __$AddHabitParamsCopyWithImpl<$Res>
    implements _$AddHabitParamsCopyWith<$Res> {
  __$AddHabitParamsCopyWithImpl(this._self, this._then);

  final _AddHabitParams _self;
  final $Res Function(_AddHabitParams) _then;

/// Create a copy of AddHabitParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? points = null,}) {
  return _then(_AddHabitParams(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
