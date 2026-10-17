// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'add_habit_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AddHabitEvent {

 String get name; String get description; int get points;
/// Create a copy of AddHabitEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddHabitEventCopyWith<AddHabitEvent> get copyWith => _$AddHabitEventCopyWithImpl<AddHabitEvent>(this as AddHabitEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitEvent&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points);

@override
String toString() {
  return 'AddHabitEvent(name: $name, description: $description, points: $points)';
}


}

/// @nodoc
abstract mixin class $AddHabitEventCopyWith<$Res>  {
  factory $AddHabitEventCopyWith(AddHabitEvent value, $Res Function(AddHabitEvent) _then) = _$AddHabitEventCopyWithImpl;
@useResult
$Res call({
 String name, String description, int points
});




}
/// @nodoc
class _$AddHabitEventCopyWithImpl<$Res>
    implements $AddHabitEventCopyWith<$Res> {
  _$AddHabitEventCopyWithImpl(this._self, this._then);

  final AddHabitEvent _self;
  final $Res Function(AddHabitEvent) _then;

/// Create a copy of AddHabitEvent
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


/// Adds pattern-matching-related methods to [AddHabitEvent].
extension AddHabitEventPatterns on AddHabitEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AddHabitSubmitted value)?  submitted,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddHabitSubmitted() when submitted != null:
return submitted(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AddHabitSubmitted value)  submitted,}){
final _that = this;
switch (_that) {
case AddHabitSubmitted():
return submitted(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AddHabitSubmitted value)?  submitted,}){
final _that = this;
switch (_that) {
case AddHabitSubmitted() when submitted != null:
return submitted(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String name,  String description,  int points)?  submitted,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddHabitSubmitted() when submitted != null:
return submitted(_that.name,_that.description,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String name,  String description,  int points)  submitted,}) {final _that = this;
switch (_that) {
case AddHabitSubmitted():
return submitted(_that.name,_that.description,_that.points);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String name,  String description,  int points)?  submitted,}) {final _that = this;
switch (_that) {
case AddHabitSubmitted() when submitted != null:
return submitted(_that.name,_that.description,_that.points);case _:
  return null;

}
}

}

/// @nodoc


class AddHabitSubmitted implements AddHabitEvent {
  const AddHabitSubmitted({required this.name, required this.description, required this.points});
  

@override final  String name;
@override final  String description;
@override final  int points;

/// Create a copy of AddHabitEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddHabitSubmittedCopyWith<AddHabitSubmitted> get copyWith => _$AddHabitSubmittedCopyWithImpl<AddHabitSubmitted>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitSubmitted&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points);

@override
String toString() {
  return 'AddHabitEvent.submitted(name: $name, description: $description, points: $points)';
}


}

/// @nodoc
abstract mixin class $AddHabitSubmittedCopyWith<$Res> implements $AddHabitEventCopyWith<$Res> {
  factory $AddHabitSubmittedCopyWith(AddHabitSubmitted value, $Res Function(AddHabitSubmitted) _then) = _$AddHabitSubmittedCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, int points
});




}
/// @nodoc
class _$AddHabitSubmittedCopyWithImpl<$Res>
    implements $AddHabitSubmittedCopyWith<$Res> {
  _$AddHabitSubmittedCopyWithImpl(this._self, this._then);

  final AddHabitSubmitted _self;
  final $Res Function(AddHabitSubmitted) _then;

/// Create a copy of AddHabitEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? points = null,}) {
  return _then(AddHabitSubmitted(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AddHabitState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddHabitState()';
}


}

/// @nodoc
class $AddHabitStateCopyWith<$Res>  {
$AddHabitStateCopyWith(AddHabitState _, $Res Function(AddHabitState) __);
}


/// Adds pattern-matching-related methods to [AddHabitState].
extension AddHabitStatePatterns on AddHabitState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( AddHabitInitial value)?  initial,TResult Function( AddHabitSubmitting value)?  submitting,TResult Function( AddHabitSuccess value)?  success,TResult Function( AddHabitFailure value)?  failure,required TResult orElse(),}){
final _that = this;
switch (_that) {
case AddHabitInitial() when initial != null:
return initial(_that);case AddHabitSubmitting() when submitting != null:
return submitting(_that);case AddHabitSuccess() when success != null:
return success(_that);case AddHabitFailure() when failure != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( AddHabitInitial value)  initial,required TResult Function( AddHabitSubmitting value)  submitting,required TResult Function( AddHabitSuccess value)  success,required TResult Function( AddHabitFailure value)  failure,}){
final _that = this;
switch (_that) {
case AddHabitInitial():
return initial(_that);case AddHabitSubmitting():
return submitting(_that);case AddHabitSuccess():
return success(_that);case AddHabitFailure():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( AddHabitInitial value)?  initial,TResult? Function( AddHabitSubmitting value)?  submitting,TResult? Function( AddHabitSuccess value)?  success,TResult? Function( AddHabitFailure value)?  failure,}){
final _that = this;
switch (_that) {
case AddHabitInitial() when initial != null:
return initial(_that);case AddHabitSubmitting() when submitting != null:
return submitting(_that);case AddHabitSuccess() when success != null:
return success(_that);case AddHabitFailure() when failure != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  submitting,TResult Function()?  success,TResult Function( Failure failure)?  failure,required TResult orElse(),}) {final _that = this;
switch (_that) {
case AddHabitInitial() when initial != null:
return initial();case AddHabitSubmitting() when submitting != null:
return submitting();case AddHabitSuccess() when success != null:
return success();case AddHabitFailure() when failure != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  submitting,required TResult Function()  success,required TResult Function( Failure failure)  failure,}) {final _that = this;
switch (_that) {
case AddHabitInitial():
return initial();case AddHabitSubmitting():
return submitting();case AddHabitSuccess():
return success();case AddHabitFailure():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  submitting,TResult? Function()?  success,TResult? Function( Failure failure)?  failure,}) {final _that = this;
switch (_that) {
case AddHabitInitial() when initial != null:
return initial();case AddHabitSubmitting() when submitting != null:
return submitting();case AddHabitSuccess() when success != null:
return success();case AddHabitFailure() when failure != null:
return failure(_that.failure);case _:
  return null;

}
}

}

/// @nodoc


class AddHabitInitial implements AddHabitState {
  const AddHabitInitial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitInitial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddHabitState.initial()';
}


}




/// @nodoc


class AddHabitSubmitting implements AddHabitState {
  const AddHabitSubmitting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitSubmitting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddHabitState.submitting()';
}


}




/// @nodoc


class AddHabitSuccess implements AddHabitState {
  const AddHabitSuccess();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitSuccess);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AddHabitState.success()';
}


}




/// @nodoc


class AddHabitFailure implements AddHabitState {
  const AddHabitFailure(this.failure);
  

 final  Failure failure;

/// Create a copy of AddHabitState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AddHabitFailureCopyWith<AddHabitFailure> get copyWith => _$AddHabitFailureCopyWithImpl<AddHabitFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AddHabitFailure&&(identical(other.failure, failure) || other.failure == failure));
}


@override
int get hashCode => Object.hash(runtimeType,failure);

@override
String toString() {
  return 'AddHabitState.failure(failure: $failure)';
}


}

/// @nodoc
abstract mixin class $AddHabitFailureCopyWith<$Res> implements $AddHabitStateCopyWith<$Res> {
  factory $AddHabitFailureCopyWith(AddHabitFailure value, $Res Function(AddHabitFailure) _then) = _$AddHabitFailureCopyWithImpl;
@useResult
$Res call({
 Failure failure
});


$FailureCopyWith<$Res> get failure;

}
/// @nodoc
class _$AddHabitFailureCopyWithImpl<$Res>
    implements $AddHabitFailureCopyWith<$Res> {
  _$AddHabitFailureCopyWithImpl(this._self, this._then);

  final AddHabitFailure _self;
  final $Res Function(AddHabitFailure) _then;

/// Create a copy of AddHabitState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failure = null,}) {
  return _then(AddHabitFailure(
null == failure ? _self.failure : failure // ignore: cast_nullable_to_non_nullable
as Failure,
  ));
}

/// Create a copy of AddHabitState
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
