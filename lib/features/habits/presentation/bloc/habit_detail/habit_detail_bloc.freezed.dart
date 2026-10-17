// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_detail_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HabitDetailEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailEvent()';
}


}

/// @nodoc
class $HabitDetailEventCopyWith<$Res>  {
$HabitDetailEventCopyWith(HabitDetailEvent _, $Res Function(HabitDetailEvent) __);
}


/// Adds pattern-matching-related methods to [HabitDetailEvent].
extension HabitDetailEventPatterns on HabitDetailEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HabitDetailStarted value)?  started,TResult Function( HabitDetailTodayToggled value)?  todayToggled,TResult Function( HabitDetailResumed value)?  resumed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HabitDetailStarted() when started != null:
return started(_that);case HabitDetailTodayToggled() when todayToggled != null:
return todayToggled(_that);case HabitDetailResumed() when resumed != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HabitDetailStarted value)  started,required TResult Function( HabitDetailTodayToggled value)  todayToggled,required TResult Function( HabitDetailResumed value)  resumed,}){
final _that = this;
switch (_that) {
case HabitDetailStarted():
return started(_that);case HabitDetailTodayToggled():
return todayToggled(_that);case HabitDetailResumed():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HabitDetailStarted value)?  started,TResult? Function( HabitDetailTodayToggled value)?  todayToggled,TResult? Function( HabitDetailResumed value)?  resumed,}){
final _that = this;
switch (_that) {
case HabitDetailStarted() when started != null:
return started(_that);case HabitDetailTodayToggled() when todayToggled != null:
return todayToggled(_that);case HabitDetailResumed() when resumed != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  started,TResult Function()?  todayToggled,TResult Function()?  resumed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HabitDetailStarted() when started != null:
return started();case HabitDetailTodayToggled() when todayToggled != null:
return todayToggled();case HabitDetailResumed() when resumed != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  started,required TResult Function()  todayToggled,required TResult Function()  resumed,}) {final _that = this;
switch (_that) {
case HabitDetailStarted():
return started();case HabitDetailTodayToggled():
return todayToggled();case HabitDetailResumed():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  started,TResult? Function()?  todayToggled,TResult? Function()?  resumed,}) {final _that = this;
switch (_that) {
case HabitDetailStarted() when started != null:
return started();case HabitDetailTodayToggled() when todayToggled != null:
return todayToggled();case HabitDetailResumed() when resumed != null:
return resumed();case _:
  return null;

}
}

}

/// @nodoc


class HabitDetailStarted implements HabitDetailEvent {
  const HabitDetailStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailEvent.started()';
}


}




/// @nodoc


class HabitDetailTodayToggled implements HabitDetailEvent {
  const HabitDetailTodayToggled();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailTodayToggled);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailEvent.todayToggled()';
}


}




/// @nodoc


class HabitDetailResumed implements HabitDetailEvent {
  const HabitDetailResumed();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailResumed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailEvent.resumed()';
}


}




/// @nodoc
mixin _$HabitDetailState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailState()';
}


}

/// @nodoc
class $HabitDetailStateCopyWith<$Res>  {
$HabitDetailStateCopyWith(HabitDetailState _, $Res Function(HabitDetailState) __);
}


/// Adds pattern-matching-related methods to [HabitDetailState].
extension HabitDetailStatePatterns on HabitDetailState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( HabitDetailLoading value)?  loading,TResult Function( HabitDetailLoaded value)?  loaded,TResult Function( HabitDetailFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case HabitDetailLoading() when loading != null:
return loading(_that);case HabitDetailLoaded() when loaded != null:
return loaded(_that);case HabitDetailFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( HabitDetailLoading value)  loading,required TResult Function( HabitDetailLoaded value)  loaded,required TResult Function( HabitDetailFailure value)  failure,}){
final _that = this;
switch (_that) {
case HabitDetailLoading():
return loading(_that);case HabitDetailLoaded():
return loaded(_that);case HabitDetailFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( HabitDetailLoading value)?  loading,TResult? Function( HabitDetailLoaded value)?  loaded,TResult? Function( HabitDetailFailure value)?  failure,}){
final _that = this;
switch (_that) {
case HabitDetailLoading() when loading != null:
return loading(_that);case HabitDetailLoaded() when loaded != null:
return loaded(_that);case HabitDetailFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loading,TResult Function( HabitDetail detail,  Failure? actionFailure)?  loaded,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case HabitDetailLoading() when loading != null:
return loading();case HabitDetailLoaded() when loaded != null:
return loaded(_that.detail,_that.actionFailure);case HabitDetailFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loading,required TResult Function( HabitDetail detail,  Failure? actionFailure)  loaded,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case HabitDetailLoading():
return loading();case HabitDetailLoaded():
return loaded(_that.detail,_that.actionFailure);case HabitDetailFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loading,TResult? Function( HabitDetail detail,  Failure? actionFailure)?  loaded,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case HabitDetailLoading() when loading != null:
return loading();case HabitDetailLoaded() when loaded != null:
return loaded(_that.detail,_that.actionFailure);case HabitDetailFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class HabitDetailLoading implements HabitDetailState {
  const HabitDetailLoading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailLoading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'HabitDetailState.loading()';
}


}




/// @nodoc


class HabitDetailLoaded implements HabitDetailState {
  const HabitDetailLoaded(this.detail, {this.actionFailure});
  

 final  HabitDetail detail;
 final  Failure? actionFailure;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDetailLoadedCopyWith<HabitDetailLoaded> get copyWith => _$HabitDetailLoadedCopyWithImpl<HabitDetailLoaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailLoaded&&(identical(other.detail, detail) || other.detail == detail)&&(identical(other.actionFailure, actionFailure) || other.actionFailure == actionFailure));
}


@override
int get hashCode => Object.hash(runtimeType,detail,actionFailure);

@override
String toString() {
  return 'HabitDetailState.loaded(detail: $detail, actionFailure: $actionFailure)';
}


}

/// @nodoc
abstract mixin class $HabitDetailLoadedCopyWith<$Res> implements $HabitDetailStateCopyWith<$Res> {
  factory $HabitDetailLoadedCopyWith(HabitDetailLoaded value, $Res Function(HabitDetailLoaded) _then) = _$HabitDetailLoadedCopyWithImpl;
@useResult
$Res call({
 HabitDetail detail, Failure? actionFailure
});


$HabitDetailCopyWith<$Res> get detail;$FailureCopyWith<$Res>? get actionFailure;

}
/// @nodoc
class _$HabitDetailLoadedCopyWithImpl<$Res>
    implements $HabitDetailLoadedCopyWith<$Res> {
  _$HabitDetailLoadedCopyWithImpl(this._self, this._then);

  final HabitDetailLoaded _self;
  final $Res Function(HabitDetailLoaded) _then;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? detail = null,Object? actionFailure = freezed,}) {
  return _then(HabitDetailLoaded(
null == detail ? _self.detail : detail // ignore: cast_nullable_to_non_nullable
as HabitDetail,actionFailure: freezed == actionFailure ? _self.actionFailure : actionFailure // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HabitDetailCopyWith<$Res> get detail {
  
  return $HabitDetailCopyWith<$Res>(_self.detail, (value) {
    return _then(_self.copyWith(detail: value));
  });
}/// Create a copy of HabitDetailState
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


class HabitDetailFailure implements HabitDetailState {
  const HabitDetailFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitDetailFailureCopyWith<HabitDetailFailure> get copyWith => _$HabitDetailFailureCopyWithImpl<HabitDetailFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitDetailFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'HabitDetailState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $HabitDetailFailureCopyWith<$Res> implements $HabitDetailStateCopyWith<$Res> {
  factory $HabitDetailFailureCopyWith(HabitDetailFailure value, $Res Function(HabitDetailFailure) _then) = _$HabitDetailFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$HabitDetailFailureCopyWithImpl<$Res>
    implements $HabitDetailFailureCopyWith<$Res> {
  _$HabitDetailFailureCopyWithImpl(this._self, this._then);

  final HabitDetailFailure _self;
  final $Res Function(HabitDetailFailure) _then;

/// Create a copy of HabitDetailState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(HabitDetailFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of HabitDetailState
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
