// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cycle_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CycleSnapshot {

 DateKey get dateKey; List<String> get eligibleUids; List<String> get visibleCompletedUids; int get completedCount; CompletionRule get rule; bool get closed;
/// Create a copy of CycleSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CycleSnapshotCopyWith<CycleSnapshot> get copyWith => _$CycleSnapshotCopyWithImpl<CycleSnapshot>(this as CycleSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CycleSnapshot&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&const DeepCollectionEquality().equals(other.eligibleUids, eligibleUids)&&const DeepCollectionEquality().equals(other.visibleCompletedUids, visibleCompletedUids)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.closed, closed) || other.closed == closed));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,const DeepCollectionEquality().hash(eligibleUids),const DeepCollectionEquality().hash(visibleCompletedUids),completedCount,rule,closed);

@override
String toString() {
  return 'CycleSnapshot(dateKey: $dateKey, eligibleUids: $eligibleUids, visibleCompletedUids: $visibleCompletedUids, completedCount: $completedCount, rule: $rule, closed: $closed)';
}


}

/// @nodoc
abstract mixin class $CycleSnapshotCopyWith<$Res>  {
  factory $CycleSnapshotCopyWith(CycleSnapshot value, $Res Function(CycleSnapshot) _then) = _$CycleSnapshotCopyWithImpl;
@useResult
$Res call({
 DateKey dateKey, List<String> eligibleUids, List<String> visibleCompletedUids, int completedCount, CompletionRule rule, bool closed
});




}
/// @nodoc
class _$CycleSnapshotCopyWithImpl<$Res>
    implements $CycleSnapshotCopyWith<$Res> {
  _$CycleSnapshotCopyWithImpl(this._self, this._then);

  final CycleSnapshot _self;
  final $Res Function(CycleSnapshot) _then;

/// Create a copy of CycleSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dateKey = null,Object? eligibleUids = null,Object? visibleCompletedUids = null,Object? completedCount = null,Object? rule = null,Object? closed = null,}) {
  return _then(_self.copyWith(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as DateKey,eligibleUids: null == eligibleUids ? _self.eligibleUids : eligibleUids // ignore: cast_nullable_to_non_nullable
as List<String>,visibleCompletedUids: null == visibleCompletedUids ? _self.visibleCompletedUids : visibleCompletedUids // ignore: cast_nullable_to_non_nullable
as List<String>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as CompletionRule,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CycleSnapshot].
extension CycleSnapshotPatterns on CycleSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CycleSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CycleSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CycleSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _CycleSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CycleSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _CycleSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateKey dateKey,  List<String> eligibleUids,  List<String> visibleCompletedUids,  int completedCount,  CompletionRule rule,  bool closed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CycleSnapshot() when $default != null:
return $default(_that.dateKey,_that.eligibleUids,_that.visibleCompletedUids,_that.completedCount,_that.rule,_that.closed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateKey dateKey,  List<String> eligibleUids,  List<String> visibleCompletedUids,  int completedCount,  CompletionRule rule,  bool closed)  $default,) {final _that = this;
switch (_that) {
case _CycleSnapshot():
return $default(_that.dateKey,_that.eligibleUids,_that.visibleCompletedUids,_that.completedCount,_that.rule,_that.closed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateKey dateKey,  List<String> eligibleUids,  List<String> visibleCompletedUids,  int completedCount,  CompletionRule rule,  bool closed)?  $default,) {final _that = this;
switch (_that) {
case _CycleSnapshot() when $default != null:
return $default(_that.dateKey,_that.eligibleUids,_that.visibleCompletedUids,_that.completedCount,_that.rule,_that.closed);case _:
  return null;

}
}

}

/// @nodoc


class _CycleSnapshot extends CycleSnapshot {
  const _CycleSnapshot({required this.dateKey, required final  List<String> eligibleUids, required final  List<String> visibleCompletedUids, required this.completedCount, required this.rule, required this.closed}): _eligibleUids = eligibleUids,_visibleCompletedUids = visibleCompletedUids,super._();
  

@override final  DateKey dateKey;
 final  List<String> _eligibleUids;
@override List<String> get eligibleUids {
  if (_eligibleUids is EqualUnmodifiableListView) return _eligibleUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eligibleUids);
}

 final  List<String> _visibleCompletedUids;
@override List<String> get visibleCompletedUids {
  if (_visibleCompletedUids is EqualUnmodifiableListView) return _visibleCompletedUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_visibleCompletedUids);
}

@override final  int completedCount;
@override final  CompletionRule rule;
@override final  bool closed;

/// Create a copy of CycleSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CycleSnapshotCopyWith<_CycleSnapshot> get copyWith => __$CycleSnapshotCopyWithImpl<_CycleSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleSnapshot&&(identical(other.dateKey, dateKey) || other.dateKey == dateKey)&&const DeepCollectionEquality().equals(other._eligibleUids, _eligibleUids)&&const DeepCollectionEquality().equals(other._visibleCompletedUids, _visibleCompletedUids)&&(identical(other.completedCount, completedCount) || other.completedCount == completedCount)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.closed, closed) || other.closed == closed));
}


@override
int get hashCode => Object.hash(runtimeType,dateKey,const DeepCollectionEquality().hash(_eligibleUids),const DeepCollectionEquality().hash(_visibleCompletedUids),completedCount,rule,closed);

@override
String toString() {
  return 'CycleSnapshot(dateKey: $dateKey, eligibleUids: $eligibleUids, visibleCompletedUids: $visibleCompletedUids, completedCount: $completedCount, rule: $rule, closed: $closed)';
}


}

/// @nodoc
abstract mixin class _$CycleSnapshotCopyWith<$Res> implements $CycleSnapshotCopyWith<$Res> {
  factory _$CycleSnapshotCopyWith(_CycleSnapshot value, $Res Function(_CycleSnapshot) _then) = __$CycleSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DateKey dateKey, List<String> eligibleUids, List<String> visibleCompletedUids, int completedCount, CompletionRule rule, bool closed
});




}
/// @nodoc
class __$CycleSnapshotCopyWithImpl<$Res>
    implements _$CycleSnapshotCopyWith<$Res> {
  __$CycleSnapshotCopyWithImpl(this._self, this._then);

  final _CycleSnapshot _self;
  final $Res Function(_CycleSnapshot) _then;

/// Create a copy of CycleSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dateKey = null,Object? eligibleUids = null,Object? visibleCompletedUids = null,Object? completedCount = null,Object? rule = null,Object? closed = null,}) {
  return _then(_CycleSnapshot(
dateKey: null == dateKey ? _self.dateKey : dateKey // ignore: cast_nullable_to_non_nullable
as DateKey,eligibleUids: null == eligibleUids ? _self._eligibleUids : eligibleUids // ignore: cast_nullable_to_non_nullable
as List<String>,visibleCompletedUids: null == visibleCompletedUids ? _self._visibleCompletedUids : visibleCompletedUids // ignore: cast_nullable_to_non_nullable
as List<String>,completedCount: null == completedCount ? _self.completedCount : completedCount // ignore: cast_nullable_to_non_nullable
as int,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as CompletionRule,closed: null == closed ? _self.closed : closed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
