// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'today_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TodayEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TodayEvent()';
}


}

/// @nodoc
class $TodayEventCopyWith<$Res>  {
$TodayEventCopyWith(TodayEvent _, $Res Function(TodayEvent) __);
}


/// Adds pattern-matching-related methods to [TodayEvent].
extension TodayEventPatterns on TodayEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TodayStarted value)?  started,TResult Function( TodayHabitToggled value)?  habitToggled,TResult Function( TodayHabitDeleted value)?  habitDeleted,TResult Function( TodayResumed value)?  resumed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TodayStarted() when started != null:
return started(_that);case TodayHabitToggled() when habitToggled != null:
return habitToggled(_that);case TodayHabitDeleted() when habitDeleted != null:
return habitDeleted(_that);case TodayResumed() when resumed != null:
return resumed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TodayStarted value)  started,required TResult Function( TodayHabitToggled value)  habitToggled,required TResult Function( TodayHabitDeleted value)  habitDeleted,required TResult Function( TodayResumed value)  resumed,}){
final _that = this;
switch (_that) {
case TodayStarted():
return started(_that);case TodayHabitToggled():
return habitToggled(_that);case TodayHabitDeleted():
return habitDeleted(_that);case TodayResumed():
return resumed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TodayStarted value)?  started,TResult? Function( TodayHabitToggled value)?  habitToggled,TResult? Function( TodayHabitDeleted value)?  habitDeleted,TResult? Function( TodayResumed value)?  resumed,}){
final _that = this;
switch (_that) {
case TodayStarted() when started != null:
return started(_that);case TodayHabitToggled() when habitToggled != null:
return habitToggled(_that);case TodayHabitDeleted() when habitDeleted != null:
return habitDeleted(_that);case TodayResumed() when resumed != null:
return resumed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function( String habitId)?  habitToggled,TResult Function( String habitId)?  habitDeleted,TResult Function()?  resumed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TodayStarted() when started != null:
return started();case TodayHabitToggled() when habitToggled != null:
return habitToggled(_that.habitId);case TodayHabitDeleted() when habitDeleted != null:
return habitDeleted(_that.habitId);case TodayResumed() when resumed != null:
return resumed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function( String habitId)  habitToggled,required TResult Function( String habitId)  habitDeleted,required TResult Function()  resumed,}) {final _that = this;
switch (_that) {
case TodayStarted():
return started();case TodayHabitToggled():
return habitToggled(_that.habitId);case TodayHabitDeleted():
return habitDeleted(_that.habitId);case TodayResumed():
return resumed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function( String habitId)?  habitToggled,TResult? Function( String habitId)?  habitDeleted,TResult? Function()?  resumed,}) {final _that = this;
switch (_that) {
case TodayStarted() when started != null:
return started();case TodayHabitToggled() when habitToggled != null:
return habitToggled(_that.habitId);case TodayHabitDeleted() when habitDeleted != null:
return habitDeleted(_that.habitId);case TodayResumed() when resumed != null:
return resumed();case _:
  return null;

}
}

}

/// @nodoc


class TodayStarted implements TodayEvent {
  const TodayStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TodayEvent.started()';
}


}




/// @nodoc


class TodayHabitToggled implements TodayEvent {
  const TodayHabitToggled(this.habitId);
  

 final  String habitId;

/// Create a copy of TodayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayHabitToggledCopyWith<TodayHabitToggled> get copyWith => _$TodayHabitToggledCopyWithImpl<TodayHabitToggled>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayHabitToggled&&(identical(other.habitId, habitId) || other.habitId == habitId));
}


@override
int get hashCode => Object.hash(runtimeType,habitId);

@override
String toString() {
  return 'TodayEvent.habitToggled(habitId: $habitId)';
}


}

/// @nodoc
abstract mixin class $TodayHabitToggledCopyWith<$Res> implements $TodayEventCopyWith<$Res> {
  factory $TodayHabitToggledCopyWith(TodayHabitToggled value, $Res Function(TodayHabitToggled) _then) = _$TodayHabitToggledCopyWithImpl;
@useResult
$Res call({
 String habitId
});




}
/// @nodoc
class _$TodayHabitToggledCopyWithImpl<$Res>
    implements $TodayHabitToggledCopyWith<$Res> {
  _$TodayHabitToggledCopyWithImpl(this._self, this._then);

  final TodayHabitToggled _self;
  final $Res Function(TodayHabitToggled) _then;

/// Create a copy of TodayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? habitId = null,}) {
  return _then(TodayHabitToggled(
null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TodayHabitDeleted implements TodayEvent {
  const TodayHabitDeleted(this.habitId);
  

 final  String habitId;

/// Create a copy of TodayEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayHabitDeletedCopyWith<TodayHabitDeleted> get copyWith => _$TodayHabitDeletedCopyWithImpl<TodayHabitDeleted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayHabitDeleted&&(identical(other.habitId, habitId) || other.habitId == habitId));
}


@override
int get hashCode => Object.hash(runtimeType,habitId);

@override
String toString() {
  return 'TodayEvent.habitDeleted(habitId: $habitId)';
}


}

/// @nodoc
abstract mixin class $TodayHabitDeletedCopyWith<$Res> implements $TodayEventCopyWith<$Res> {
  factory $TodayHabitDeletedCopyWith(TodayHabitDeleted value, $Res Function(TodayHabitDeleted) _then) = _$TodayHabitDeletedCopyWithImpl;
@useResult
$Res call({
 String habitId
});




}
/// @nodoc
class _$TodayHabitDeletedCopyWithImpl<$Res>
    implements $TodayHabitDeletedCopyWith<$Res> {
  _$TodayHabitDeletedCopyWithImpl(this._self, this._then);

  final TodayHabitDeleted _self;
  final $Res Function(TodayHabitDeleted) _then;

/// Create a copy of TodayEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? habitId = null,}) {
  return _then(TodayHabitDeleted(
null == habitId ? _self.habitId : habitId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TodayResumed implements TodayEvent {
  const TodayResumed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayResumed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TodayEvent.resumed()';
}


}




/// @nodoc
mixin _$TodayState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TodayState()';
}


}

/// @nodoc
class $TodayStateCopyWith<$Res>  {
$TodayStateCopyWith(TodayState _, $Res Function(TodayState) __);
}


/// Adds pattern-matching-related methods to [TodayState].
extension TodayStatePatterns on TodayState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TodayLoading value)?  loading,TResult Function( TodayLoaded value)?  loaded,TResult Function( TodayFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TodayLoading() when loading != null:
return loading(_that);case TodayLoaded() when loaded != null:
return loaded(_that);case TodayFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TodayLoading value)  loading,required TResult Function( TodayLoaded value)  loaded,required TResult Function( TodayFailure value)  failure,}){
final _that = this;
switch (_that) {
case TodayLoading():
return loading(_that);case TodayLoaded():
return loaded(_that);case TodayFailure():
return failure(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TodayLoading value)?  loading,TResult? Function( TodayLoaded value)?  loaded,TResult? Function( TodayFailure value)?  failure,}){
final _that = this;
switch (_that) {
case TodayLoading() when loading != null:
return loading(_that);case TodayLoaded() when loaded != null:
return loaded(_that);case TodayFailure() when failure != null:
return failure(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( TodayOverview overview,  Failure? actionFailure)?  loaded,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TodayLoading() when loading != null:
return loading();case TodayLoaded() when loaded != null:
return loaded(_that.overview,_that.actionFailure);case TodayFailure() when failure != null:
return failure(_that.failure);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( TodayOverview overview,  Failure? actionFailure)  loaded,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case TodayLoading():
return loading();case TodayLoaded():
return loaded(_that.overview,_that.actionFailure);case TodayFailure():
return failure(_that.failure);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( TodayOverview overview,  Failure? actionFailure)?  loaded,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case TodayLoading() when loading != null:
return loading();case TodayLoaded() when loaded != null:
return loaded(_that.overview,_that.actionFailure);case TodayFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class TodayLoading implements TodayState {
  const TodayLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TodayState.loading()';
}


}




/// @nodoc


class TodayLoaded implements TodayState {
  const TodayLoaded(this.overview, {this.actionFailure});
  

 final  TodayOverview overview;
 final  Failure? actionFailure;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayLoadedCopyWith<TodayLoaded> get copyWith => _$TodayLoadedCopyWithImpl<TodayLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayLoaded&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure));
}


@override
int get hashCode => Object.hash(runtimeType,overview,actionFailure);

@override
String toString() {
  return 'TodayState.loaded(overview: $overview, actionFailure: $actionFailure)';
}


}

/// @nodoc
abstract mixin class $TodayLoadedCopyWith<$Res> implements $TodayStateCopyWith<$Res> {
  factory $TodayLoadedCopyWith(TodayLoaded value, $Res Function(TodayLoaded) _then) = _$TodayLoadedCopyWithImpl;
@useResult
$Res call({
 TodayOverview overview, Failure? actionFailure
});


$TodayOverviewCopyWith<$Res> get overview;$FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class _$TodayLoadedCopyWithImpl<$Res>
    implements $TodayLoadedCopyWith<$Res> {
  _$TodayLoadedCopyWithImpl(this._self, this._then);

  final TodayLoaded _self;
  final $Res Function(TodayLoaded) _then;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? overview = null,Object? actionFailure = freezed,}) {
  return _then(TodayLoaded(
null == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as TodayOverview,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TodayOverviewCopyWith<$Res> get overview {
  
  return $TodayOverviewCopyWith<$Res>(_self.overview, (value) {
    return _then(_self.copyWith(overview: value));
  });
}/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get actionFailure {
    if (_self.actionFailure == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.actionFailure!, (value) {
    return _then(_self.copyWith(actionFailure: value));
  });
}
}

/// @nodoc


class TodayFailure implements TodayState {
  const TodayFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TodayFailureCopyWith<TodayFailure> get copyWith => _$TodayFailureCopyWithImpl<TodayFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TodayFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'TodayState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $TodayFailureCopyWith<$Res> implements $TodayStateCopyWith<$Res> {
  factory $TodayFailureCopyWith(TodayFailure value, $Res Function(TodayFailure) _then) = _$TodayFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$TodayFailureCopyWithImpl<$Res>
    implements $TodayFailureCopyWith<$Res> {
  _$TodayFailureCopyWithImpl(this._self, this._then);

  final TodayFailure _self;
  final $Res Function(TodayFailure) _then;

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(TodayFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of TodayState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res> get failure {
  
  return $FailureCopyWith<$Res>(_self.failure, (value) {
    return _then(_self.copyWith(failure: value));
  });
}
}

// dart format on
