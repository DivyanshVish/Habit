// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_overview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayOverview {

 DateKey get date; List<HabitWithStatus> get items;
/// Create a copy of TodayOverview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayOverviewCopyWith<TodayOverview> get copyWith => _$TodayOverviewCopyWithImpl<TodayOverview>(this as TodayOverview, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayOverview&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.items, items));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'TodayOverview(date: $date, items: $items)';
}


}

/// @nodoc
abstract mixin class $TodayOverviewCopyWith<$Res>  {
  factory $TodayOverviewCopyWith(TodayOverview value, $Res Function(TodayOverview) _then) = _$TodayOverviewCopyWithImpl;
@useResult
$Res call({
 DateKey date, List<HabitWithStatus> items
});




}
/// @nodoc
class _$TodayOverviewCopyWithImpl<$Res>
    implements $TodayOverviewCopyWith<$Res> {
  _$TodayOverviewCopyWithImpl(this._self, this._then);

  final TodayOverview _self;
  final $Res Function(TodayOverview) _then;

/// Create a copy of TodayOverview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? items = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateKey,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<HabitWithStatus>,
  ));
}

}


/// Adds pattern-matching-related methods to [TodayOverview].
extension TodayOverviewPatterns on TodayOverview {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TodayOverview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TodayOverview() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TodayOverview value)  $default,){
final _that = this;
switch (_that) {
case _TodayOverview():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TodayOverview value)?  $default,){
final _that = this;
switch (_that) {
case _TodayOverview() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateKey date,  List<HabitWithStatus> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TodayOverview() when $default != null:
return $default(_that.date,_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateKey date,  List<HabitWithStatus> items)  $default,) {final _that = this;
switch (_that) {
case _TodayOverview():
return $default(_that.date,_that.items);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateKey date,  List<HabitWithStatus> items)?  $default,) {final _that = this;
switch (_that) {
case _TodayOverview() when $default != null:
return $default(_that.date,_that.items);case _:
  return null;

}
}

}

/// @nodoc


class _TodayOverview extends TodayOverview {
  const _TodayOverview({required this.date, required final  List<HabitWithStatus> items}): _items = items,super._();
  

@override final  DateKey date;
 final  List<HabitWithStatus> _items;
@override List<HabitWithStatus> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of TodayOverview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TodayOverviewCopyWith<_TodayOverview> get copyWith => __$TodayOverviewCopyWithImpl<_TodayOverview>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TodayOverview&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other._items, _items));
}


@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'TodayOverview(date: $date, items: $items)';
}


}

/// @nodoc
abstract mixin class _$TodayOverviewCopyWith<$Res> implements $TodayOverviewCopyWith<$Res> {
  factory _$TodayOverviewCopyWith(_TodayOverview value, $Res Function(_TodayOverview) _then) = __$TodayOverviewCopyWithImpl;
@override @useResult
$Res call({
 DateKey date, List<HabitWithStatus> items
});




}
/// @nodoc
class __$TodayOverviewCopyWithImpl<$Res>
    implements _$TodayOverviewCopyWith<$Res> {
  __$TodayOverviewCopyWithImpl(this._self, this._then);

  final _TodayOverview _self;
  final $Res Function(_TodayOverview) _then;

/// Create a copy of TodayOverview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? items = null,}) {
  return _then(_TodayOverview(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateKey,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<HabitWithStatus>,
  ));
}


}

// dart format on
