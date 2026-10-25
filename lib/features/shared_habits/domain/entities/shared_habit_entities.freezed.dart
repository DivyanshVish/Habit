// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shared_habit_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SharedHabit {

 String get id; String get name; String get description; int get points; String get ownerUid; Set<int> get weekdays; DateKey get startDate; int get participantCount; bool get archived;
/// Create a copy of SharedHabit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedHabitCopyWith<SharedHabit> get copyWith => _$SharedHabitCopyWithImpl<SharedHabit>(this as SharedHabit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedHabit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.archived, archived) || other.archived == archived));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,points,ownerUid,const DeepCollectionEquality().hash(weekdays),startDate,participantCount,archived);

@override
String toString() {
  return 'SharedHabit(id: $id, name: $name, description: $description, points: $points, ownerUid: $ownerUid, weekdays: $weekdays, startDate: $startDate, participantCount: $participantCount, archived: $archived)';
}


}

/// @nodoc
abstract mixin class $SharedHabitCopyWith<$Res>  {
  factory $SharedHabitCopyWith(SharedHabit value, $Res Function(SharedHabit) _then) = _$SharedHabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, int points, String ownerUid, Set<int> weekdays, DateKey startDate, int participantCount, bool archived
});




}
/// @nodoc
class _$SharedHabitCopyWithImpl<$Res>
    implements $SharedHabitCopyWith<$Res> {
  _$SharedHabitCopyWithImpl(this._self, this._then);

  final SharedHabit _self;
  final $Res Function(SharedHabit) _then;

/// Create a copy of SharedHabit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? points = null,Object? ownerUid = null,Object? weekdays = null,Object? startDate = null,Object? participantCount = null,Object? archived = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedHabit].
extension SharedHabitPatterns on SharedHabit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedHabit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedHabit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedHabit value)  $default,){
final _that = this;
switch (_that) {
case _SharedHabit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedHabit value)?  $default,){
final _that = this;
switch (_that) {
case _SharedHabit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int points,  String ownerUid,  Set<int> weekdays,  DateKey startDate,  int participantCount,  bool archived)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedHabit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.points,_that.ownerUid,_that.weekdays,_that.startDate,_that.participantCount,_that.archived);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  int points,  String ownerUid,  Set<int> weekdays,  DateKey startDate,  int participantCount,  bool archived)  $default,) {final _that = this;
switch (_that) {
case _SharedHabit():
return $default(_that.id,_that.name,_that.description,_that.points,_that.ownerUid,_that.weekdays,_that.startDate,_that.participantCount,_that.archived);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  int points,  String ownerUid,  Set<int> weekdays,  DateKey startDate,  int participantCount,  bool archived)?  $default,) {final _that = this;
switch (_that) {
case _SharedHabit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.points,_that.ownerUid,_that.weekdays,_that.startDate,_that.participantCount,_that.archived);case _:
  return null;

}
}

}

/// @nodoc


class _SharedHabit implements SharedHabit {
  const _SharedHabit({required this.id, required this.name, required this.description, required this.points, required this.ownerUid, required final  Set<int> weekdays, required this.startDate, required this.participantCount, required this.archived}): _weekdays = weekdays;
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  int points;
@override final  String ownerUid;
 final  Set<int> _weekdays;
@override Set<int> get weekdays {
  if (_weekdays is EqualUnmodifiableSetView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weekdays);
}

@override final  DateKey startDate;
@override final  int participantCount;
@override final  bool archived;

/// Create a copy of SharedHabit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedHabitCopyWith<_SharedHabit> get copyWith => __$SharedHabitCopyWithImpl<_SharedHabit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedHabit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.participantCount, participantCount) || other.participantCount == participantCount)&&(identical(other.archived, archived) || other.archived == archived));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,points,ownerUid,const DeepCollectionEquality().hash(_weekdays),startDate,participantCount,archived);

@override
String toString() {
  return 'SharedHabit(id: $id, name: $name, description: $description, points: $points, ownerUid: $ownerUid, weekdays: $weekdays, startDate: $startDate, participantCount: $participantCount, archived: $archived)';
}


}

/// @nodoc
abstract mixin class _$SharedHabitCopyWith<$Res> implements $SharedHabitCopyWith<$Res> {
  factory _$SharedHabitCopyWith(_SharedHabit value, $Res Function(_SharedHabit) _then) = __$SharedHabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, int points, String ownerUid, Set<int> weekdays, DateKey startDate, int participantCount, bool archived
});




}
/// @nodoc
class __$SharedHabitCopyWithImpl<$Res>
    implements _$SharedHabitCopyWith<$Res> {
  __$SharedHabitCopyWithImpl(this._self, this._then);

  final _SharedHabit _self;
  final $Res Function(_SharedHabit) _then;

/// Create a copy of SharedHabit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? points = null,Object? ownerUid = null,Object? weekdays = null,Object? startDate = null,Object? participantCount = null,Object? archived = null,}) {
  return _then(_SharedHabit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,participantCount: null == participantCount ? _self.participantCount : participantCount // ignore: cast_nullable_to_non_nullable
as int,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SharedParticipant {

 String get uid; String get displayName; bool get active;
/// Create a copy of SharedParticipant
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedParticipantCopyWith<SharedParticipant> get copyWith => _$SharedParticipantCopyWithImpl<SharedParticipant>(this as SharedParticipant, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedParticipant&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName,active);

@override
String toString() {
  return 'SharedParticipant(uid: $uid, displayName: $displayName, active: $active)';
}


}

/// @nodoc
abstract mixin class $SharedParticipantCopyWith<$Res>  {
  factory $SharedParticipantCopyWith(SharedParticipant value, $Res Function(SharedParticipant) _then) = _$SharedParticipantCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, bool active
});




}
/// @nodoc
class _$SharedParticipantCopyWithImpl<$Res>
    implements $SharedParticipantCopyWith<$Res> {
  _$SharedParticipantCopyWithImpl(this._self, this._then);

  final SharedParticipant _self;
  final $Res Function(SharedParticipant) _then;

/// Create a copy of SharedParticipant
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? active = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SharedParticipant].
extension SharedParticipantPatterns on SharedParticipant {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedParticipant value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedParticipant() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedParticipant value)  $default,){
final _that = this;
switch (_that) {
case _SharedParticipant():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedParticipant value)?  $default,){
final _that = this;
switch (_that) {
case _SharedParticipant() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedParticipant() when $default != null:
return $default(_that.uid,_that.displayName,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  bool active)  $default,) {final _that = this;
switch (_that) {
case _SharedParticipant():
return $default(_that.uid,_that.displayName,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _SharedParticipant() when $default != null:
return $default(_that.uid,_that.displayName,_that.active);case _:
  return null;

}
}

}

/// @nodoc


class _SharedParticipant implements SharedParticipant {
  const _SharedParticipant({required this.uid, required this.displayName, required this.active});
  

@override final  String uid;
@override final  String displayName;
@override final  bool active;

/// Create a copy of SharedParticipant
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedParticipantCopyWith<_SharedParticipant> get copyWith => __$SharedParticipantCopyWithImpl<_SharedParticipant>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedParticipant&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName,active);

@override
String toString() {
  return 'SharedParticipant(uid: $uid, displayName: $displayName, active: $active)';
}


}

/// @nodoc
abstract mixin class _$SharedParticipantCopyWith<$Res> implements $SharedParticipantCopyWith<$Res> {
  factory _$SharedParticipantCopyWith(_SharedParticipant value, $Res Function(_SharedParticipant) _then) = __$SharedParticipantCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, bool active
});




}
/// @nodoc
class __$SharedParticipantCopyWithImpl<$Res>
    implements _$SharedParticipantCopyWith<$Res> {
  __$SharedParticipantCopyWithImpl(this._self, this._then);

  final _SharedParticipant _self;
  final $Res Function(_SharedParticipant) _then;

/// Create a copy of SharedParticipant
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? active = null,}) {
  return _then(_SharedParticipant(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$NewSharedHabit {

 String get name; String get description; int get points; Set<int> get weekdays; DateKey get startDate; String? get sourceHabitId;
/// Create a copy of NewSharedHabit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewSharedHabitCopyWith<NewSharedHabit> get copyWith => _$NewSharedHabitCopyWithImpl<NewSharedHabit>(this as NewSharedHabit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewSharedHabit&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.sourceHabitId, sourceHabitId) || other.sourceHabitId == sourceHabitId));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points,const DeepCollectionEquality().hash(weekdays),startDate,sourceHabitId);

@override
String toString() {
  return 'NewSharedHabit(name: $name, description: $description, points: $points, weekdays: $weekdays, startDate: $startDate, sourceHabitId: $sourceHabitId)';
}


}

/// @nodoc
abstract mixin class $NewSharedHabitCopyWith<$Res>  {
  factory $NewSharedHabitCopyWith(NewSharedHabit value, $Res Function(NewSharedHabit) _then) = _$NewSharedHabitCopyWithImpl;
@useResult
$Res call({
 String name, String description, int points, Set<int> weekdays, DateKey startDate, String? sourceHabitId
});




}
/// @nodoc
class _$NewSharedHabitCopyWithImpl<$Res>
    implements $NewSharedHabitCopyWith<$Res> {
  _$NewSharedHabitCopyWithImpl(this._self, this._then);

  final NewSharedHabit _self;
  final $Res Function(NewSharedHabit) _then;

/// Create a copy of NewSharedHabit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? points = null,Object? weekdays = null,Object? startDate = null,Object? sourceHabitId = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,sourceHabitId: freezed == sourceHabitId ? _self.sourceHabitId : sourceHabitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewSharedHabit].
extension NewSharedHabitPatterns on NewSharedHabit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewSharedHabit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewSharedHabit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewSharedHabit value)  $default,){
final _that = this;
switch (_that) {
case _NewSharedHabit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewSharedHabit value)?  $default,){
final _that = this;
switch (_that) {
case _NewSharedHabit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  int points,  Set<int> weekdays,  DateKey startDate,  String? sourceHabitId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewSharedHabit() when $default != null:
return $default(_that.name,_that.description,_that.points,_that.weekdays,_that.startDate,_that.sourceHabitId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  int points,  Set<int> weekdays,  DateKey startDate,  String? sourceHabitId)  $default,) {final _that = this;
switch (_that) {
case _NewSharedHabit():
return $default(_that.name,_that.description,_that.points,_that.weekdays,_that.startDate,_that.sourceHabitId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  int points,  Set<int> weekdays,  DateKey startDate,  String? sourceHabitId)?  $default,) {final _that = this;
switch (_that) {
case _NewSharedHabit() when $default != null:
return $default(_that.name,_that.description,_that.points,_that.weekdays,_that.startDate,_that.sourceHabitId);case _:
  return null;

}
}

}

/// @nodoc


class _NewSharedHabit implements NewSharedHabit {
  const _NewSharedHabit({required this.name, required this.description, required this.points, required final  Set<int> weekdays, required this.startDate, this.sourceHabitId}): _weekdays = weekdays;
  

@override final  String name;
@override final  String description;
@override final  int points;
 final  Set<int> _weekdays;
@override Set<int> get weekdays {
  if (_weekdays is EqualUnmodifiableSetView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weekdays);
}

@override final  DateKey startDate;
@override final  String? sourceHabitId;

/// Create a copy of NewSharedHabit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewSharedHabitCopyWith<_NewSharedHabit> get copyWith => __$NewSharedHabitCopyWithImpl<_NewSharedHabit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewSharedHabit&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.points, points) || other.points == points)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.sourceHabitId, sourceHabitId) || other.sourceHabitId == sourceHabitId));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,points,const DeepCollectionEquality().hash(_weekdays),startDate,sourceHabitId);

@override
String toString() {
  return 'NewSharedHabit(name: $name, description: $description, points: $points, weekdays: $weekdays, startDate: $startDate, sourceHabitId: $sourceHabitId)';
}


}

/// @nodoc
abstract mixin class _$NewSharedHabitCopyWith<$Res> implements $NewSharedHabitCopyWith<$Res> {
  factory _$NewSharedHabitCopyWith(_NewSharedHabit value, $Res Function(_NewSharedHabit) _then) = __$NewSharedHabitCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, int points, Set<int> weekdays, DateKey startDate, String? sourceHabitId
});




}
/// @nodoc
class __$NewSharedHabitCopyWithImpl<$Res>
    implements _$NewSharedHabitCopyWith<$Res> {
  __$NewSharedHabitCopyWithImpl(this._self, this._then);

  final _NewSharedHabit _self;
  final $Res Function(_NewSharedHabit) _then;

/// Create a copy of NewSharedHabit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? points = null,Object? weekdays = null,Object? startDate = null,Object? sourceHabitId = freezed,}) {
  return _then(_NewSharedHabit(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as int,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,sourceHabitId: freezed == sourceHabitId ? _self.sourceHabitId : sourceHabitId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SharedHabitDetail {

 SharedHabit get habit; List<SharedParticipant> get participants; DateKey get today;/// Null until the day's cycle is opened.
 CycleSnapshot? get cycle; bool get doneToday; bool get pendingSync; StreakStats get personalStats; HistoryBreakdown get history;
/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SharedHabitDetailCopyWith<SharedHabitDetail> get copyWith => _$SharedHabitDetailCopyWithImpl<SharedHabitDetail>(this as SharedHabitDetail, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SharedHabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&const DeepCollectionEquality().equals(other.participants, participants)&&(identical(other.today, today) || other.today == today)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.personalStats, personalStats) || other.personalStats == personalStats)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,habit,const DeepCollectionEquality().hash(participants),today,cycle,doneToday,pendingSync,personalStats,history);

@override
String toString() {
  return 'SharedHabitDetail(habit: $habit, participants: $participants, today: $today, cycle: $cycle, doneToday: $doneToday, pendingSync: $pendingSync, personalStats: $personalStats, history: $history)';
}


}

/// @nodoc
abstract mixin class $SharedHabitDetailCopyWith<$Res>  {
  factory $SharedHabitDetailCopyWith(SharedHabitDetail value, $Res Function(SharedHabitDetail) _then) = _$SharedHabitDetailCopyWithImpl;
@useResult
$Res call({
 SharedHabit habit, List<SharedParticipant> participants, DateKey today, CycleSnapshot? cycle, bool doneToday, bool pendingSync, StreakStats personalStats, HistoryBreakdown history
});


$SharedHabitCopyWith<$Res> get habit;$CycleSnapshotCopyWith<$Res>? get cycle;

}
/// @nodoc
class _$SharedHabitDetailCopyWithImpl<$Res>
    implements $SharedHabitDetailCopyWith<$Res> {
  _$SharedHabitDetailCopyWithImpl(this._self, this._then);

  final SharedHabitDetail _self;
  final $Res Function(SharedHabitDetail) _then;

/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? habit = null,Object? participants = null,Object? today = null,Object? cycle = freezed,Object? doneToday = null,Object? pendingSync = null,Object? personalStats = null,Object? history = null,}) {
  return _then(_self.copyWith(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as SharedHabit,participants: null == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as List<SharedParticipant>,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,cycle: freezed == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as CycleSnapshot?,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,personalStats: null == personalStats ? _self.personalStats : personalStats // ignore: cast_nullable_to_non_nullable
as StreakStats,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistoryBreakdown,
  ));
}
/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedHabitCopyWith<$Res> get habit {
  
  return $SharedHabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleSnapshotCopyWith<$Res>? get cycle {
    if (_self.cycle == null) {
    return null;
  }

  return $CycleSnapshotCopyWith<$Res>(_self.cycle!, (value) {
    return _then(_self.copyWith(cycle: value));
  });
}
}


/// Adds pattern-matching-related methods to [SharedHabitDetail].
extension SharedHabitDetailPatterns on SharedHabitDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SharedHabitDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SharedHabitDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SharedHabitDetail value)  $default,){
final _that = this;
switch (_that) {
case _SharedHabitDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SharedHabitDetail value)?  $default,){
final _that = this;
switch (_that) {
case _SharedHabitDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SharedHabit habit,  List<SharedParticipant> participants,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SharedHabitDetail() when $default != null:
return $default(_that.habit,_that.participants,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SharedHabit habit,  List<SharedParticipant> participants,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)  $default,) {final _that = this;
switch (_that) {
case _SharedHabitDetail():
return $default(_that.habit,_that.participants,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SharedHabit habit,  List<SharedParticipant> participants,  DateKey today,  CycleSnapshot? cycle,  bool doneToday,  bool pendingSync,  StreakStats personalStats,  HistoryBreakdown history)?  $default,) {final _that = this;
switch (_that) {
case _SharedHabitDetail() when $default != null:
return $default(_that.habit,_that.participants,_that.today,_that.cycle,_that.doneToday,_that.pendingSync,_that.personalStats,_that.history);case _:
  return null;

}
}

}

/// @nodoc


class _SharedHabitDetail implements SharedHabitDetail {
  const _SharedHabitDetail({required this.habit, required final  List<SharedParticipant> participants, required this.today, required this.cycle, required this.doneToday, required this.pendingSync, required this.personalStats, required this.history}): _participants = participants;
  

@override final  SharedHabit habit;
 final  List<SharedParticipant> _participants;
@override List<SharedParticipant> get participants {
  if (_participants is EqualUnmodifiableListView) return _participants;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participants);
}

@override final  DateKey today;
/// Null until the day's cycle is opened.
@override final  CycleSnapshot? cycle;
@override final  bool doneToday;
@override final  bool pendingSync;
@override final  StreakStats personalStats;
@override final  HistoryBreakdown history;

/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SharedHabitDetailCopyWith<_SharedHabitDetail> get copyWith => __$SharedHabitDetailCopyWithImpl<_SharedHabitDetail>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SharedHabitDetail&&(identical(other.habit, habit) || other.habit == habit)&&const DeepCollectionEquality().equals(other._participants, _participants)&&(identical(other.today, today) || other.today == today)&&(identical(other.cycle, cycle) || other.cycle == cycle)&&(identical(other.doneToday, doneToday) || other.doneToday == doneToday)&&(identical(other.pendingSync, pendingSync) || other.pendingSync == pendingSync)&&(identical(other.personalStats, personalStats) || other.personalStats == personalStats)&&(identical(other.history, history) || other.history == history));
}


@override
int get hashCode => Object.hash(runtimeType,habit,const DeepCollectionEquality().hash(_participants),today,cycle,doneToday,pendingSync,personalStats,history);

@override
String toString() {
  return 'SharedHabitDetail(habit: $habit, participants: $participants, today: $today, cycle: $cycle, doneToday: $doneToday, pendingSync: $pendingSync, personalStats: $personalStats, history: $history)';
}


}

/// @nodoc
abstract mixin class _$SharedHabitDetailCopyWith<$Res> implements $SharedHabitDetailCopyWith<$Res> {
  factory _$SharedHabitDetailCopyWith(_SharedHabitDetail value, $Res Function(_SharedHabitDetail) _then) = __$SharedHabitDetailCopyWithImpl;
@override @useResult
$Res call({
 SharedHabit habit, List<SharedParticipant> participants, DateKey today, CycleSnapshot? cycle, bool doneToday, bool pendingSync, StreakStats personalStats, HistoryBreakdown history
});


@override $SharedHabitCopyWith<$Res> get habit;@override $CycleSnapshotCopyWith<$Res>? get cycle;

}
/// @nodoc
class __$SharedHabitDetailCopyWithImpl<$Res>
    implements _$SharedHabitDetailCopyWith<$Res> {
  __$SharedHabitDetailCopyWithImpl(this._self, this._then);

  final _SharedHabitDetail _self;
  final $Res Function(_SharedHabitDetail) _then;

/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? habit = null,Object? participants = null,Object? today = null,Object? cycle = freezed,Object? doneToday = null,Object? pendingSync = null,Object? personalStats = null,Object? history = null,}) {
  return _then(_SharedHabitDetail(
habit: null == habit ? _self.habit : habit // ignore: cast_nullable_to_non_nullable
as SharedHabit,participants: null == participants ? _self._participants : participants // ignore: cast_nullable_to_non_nullable
as List<SharedParticipant>,today: null == today ? _self.today : today // ignore: cast_nullable_to_non_nullable
as DateKey,cycle: freezed == cycle ? _self.cycle : cycle // ignore: cast_nullable_to_non_nullable
as CycleSnapshot?,doneToday: null == doneToday ? _self.doneToday : doneToday // ignore: cast_nullable_to_non_nullable
as bool,pendingSync: null == pendingSync ? _self.pendingSync : pendingSync // ignore: cast_nullable_to_non_nullable
as bool,personalStats: null == personalStats ? _self.personalStats : personalStats // ignore: cast_nullable_to_non_nullable
as StreakStats,history: null == history ? _self.history : history // ignore: cast_nullable_to_non_nullable
as HistoryBreakdown,
  ));
}

/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SharedHabitCopyWith<$Res> get habit {
  
  return $SharedHabitCopyWith<$Res>(_self.habit, (value) {
    return _then(_self.copyWith(habit: value));
  });
}/// Create a copy of SharedHabitDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CycleSnapshotCopyWith<$Res>? get cycle {
    if (_self.cycle == null) {
    return null;
  }

  return $CycleSnapshotCopyWith<$Res>(_self.cycle!, (value) {
    return _then(_self.copyWith(cycle: value));
  });
}
}

// dart format on
