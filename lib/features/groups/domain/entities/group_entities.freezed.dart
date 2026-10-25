// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_entities.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GroupEmblem {

 String get icon; int get color;
/// Create a copy of GroupEmblem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupEmblemCopyWith<GroupEmblem> get copyWith => _$GroupEmblemCopyWithImpl<GroupEmblem>(this as GroupEmblem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupEmblem&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,icon,color);

@override
String toString() {
  return 'GroupEmblem(icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class $GroupEmblemCopyWith<$Res>  {
  factory $GroupEmblemCopyWith(GroupEmblem value, $Res Function(GroupEmblem) _then) = _$GroupEmblemCopyWithImpl;
@useResult
$Res call({
 String icon, int color
});




}
/// @nodoc
class _$GroupEmblemCopyWithImpl<$Res>
    implements $GroupEmblemCopyWith<$Res> {
  _$GroupEmblemCopyWithImpl(this._self, this._then);

  final GroupEmblem _self;
  final $Res Function(GroupEmblem) _then;

/// Create a copy of GroupEmblem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? icon = null,Object? color = null,}) {
  return _then(_self.copyWith(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupEmblem].
extension GroupEmblemPatterns on GroupEmblem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupEmblem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupEmblem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupEmblem value)  $default,){
final _that = this;
switch (_that) {
case _GroupEmblem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupEmblem value)?  $default,){
final _that = this;
switch (_that) {
case _GroupEmblem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String icon,  int color)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupEmblem() when $default != null:
return $default(_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String icon,  int color)  $default,) {final _that = this;
switch (_that) {
case _GroupEmblem():
return $default(_that.icon,_that.color);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String icon,  int color)?  $default,) {final _that = this;
switch (_that) {
case _GroupEmblem() when $default != null:
return $default(_that.icon,_that.color);case _:
  return null;

}
}

}

/// @nodoc


class _GroupEmblem implements GroupEmblem {
  const _GroupEmblem({required this.icon, required this.color});
  

@override final  String icon;
@override final  int color;

/// Create a copy of GroupEmblem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupEmblemCopyWith<_GroupEmblem> get copyWith => __$GroupEmblemCopyWithImpl<_GroupEmblem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupEmblem&&(identical(other.icon, icon) || other.icon == icon)&&(identical(other.color, color) || other.color == color));
}


@override
int get hashCode => Object.hash(runtimeType,icon,color);

@override
String toString() {
  return 'GroupEmblem(icon: $icon, color: $color)';
}


}

/// @nodoc
abstract mixin class _$GroupEmblemCopyWith<$Res> implements $GroupEmblemCopyWith<$Res> {
  factory _$GroupEmblemCopyWith(_GroupEmblem value, $Res Function(_GroupEmblem) _then) = __$GroupEmblemCopyWithImpl;
@override @useResult
$Res call({
 String icon, int color
});




}
/// @nodoc
class __$GroupEmblemCopyWithImpl<$Res>
    implements _$GroupEmblemCopyWith<$Res> {
  __$GroupEmblemCopyWithImpl(this._self, this._then);

  final _GroupEmblem _self;
  final $Res Function(_GroupEmblem) _then;

/// Create a copy of GroupEmblem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? icon = null,Object? color = null,}) {
  return _then(_GroupEmblem(
icon: null == icon ? _self.icon : icon // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GroupMembership {

 String get groupId; String get groupName; MemberRole get role; MembershipStatus get status; bool get groupArchived; GroupEmblem? get emblem;
/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMembershipCopyWith<GroupMembership> get copyWith => _$GroupMembershipCopyWithImpl<GroupMembership>(this as GroupMembership, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMembership&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.groupArchived, groupArchived) || other.groupArchived == groupArchived)&&(identical(other.emblem, emblem) || other.emblem == emblem));
}


@override
int get hashCode => Object.hash(runtimeType,groupId,groupName,role,status,groupArchived,emblem);

@override
String toString() {
  return 'GroupMembership(groupId: $groupId, groupName: $groupName, role: $role, status: $status, groupArchived: $groupArchived, emblem: $emblem)';
}


}

/// @nodoc
abstract mixin class $GroupMembershipCopyWith<$Res>  {
  factory $GroupMembershipCopyWith(GroupMembership value, $Res Function(GroupMembership) _then) = _$GroupMembershipCopyWithImpl;
@useResult
$Res call({
 String groupId, String groupName, MemberRole role, MembershipStatus status, bool groupArchived, GroupEmblem? emblem
});


$GroupEmblemCopyWith<$Res>? get emblem;

}
/// @nodoc
class _$GroupMembershipCopyWithImpl<$Res>
    implements $GroupMembershipCopyWith<$Res> {
  _$GroupMembershipCopyWithImpl(this._self, this._then);

  final GroupMembership _self;
  final $Res Function(GroupMembership) _then;

/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? groupId = null,Object? groupName = null,Object? role = null,Object? status = null,Object? groupArchived = null,Object? emblem = freezed,}) {
  return _then(_self.copyWith(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,groupArchived: null == groupArchived ? _self.groupArchived : groupArchived // ignore: cast_nullable_to_non_nullable
as bool,emblem: freezed == emblem ? _self.emblem : emblem // ignore: cast_nullable_to_non_nullable
as GroupEmblem?,
  ));
}
/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupEmblemCopyWith<$Res>? get emblem {
    if (_self.emblem == null) {
    return null;
  }

  return $GroupEmblemCopyWith<$Res>(_self.emblem!, (value) {
    return _then(_self.copyWith(emblem: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupMembership].
extension GroupMembershipPatterns on GroupMembership {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMembership value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMembership() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMembership value)  $default,){
final _that = this;
switch (_that) {
case _GroupMembership():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMembership value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMembership() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String groupId,  String groupName,  MemberRole role,  MembershipStatus status,  bool groupArchived,  GroupEmblem? emblem)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMembership() when $default != null:
return $default(_that.groupId,_that.groupName,_that.role,_that.status,_that.groupArchived,_that.emblem);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String groupId,  String groupName,  MemberRole role,  MembershipStatus status,  bool groupArchived,  GroupEmblem? emblem)  $default,) {final _that = this;
switch (_that) {
case _GroupMembership():
return $default(_that.groupId,_that.groupName,_that.role,_that.status,_that.groupArchived,_that.emblem);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String groupId,  String groupName,  MemberRole role,  MembershipStatus status,  bool groupArchived,  GroupEmblem? emblem)?  $default,) {final _that = this;
switch (_that) {
case _GroupMembership() when $default != null:
return $default(_that.groupId,_that.groupName,_that.role,_that.status,_that.groupArchived,_that.emblem);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMembership implements GroupMembership {
  const _GroupMembership({required this.groupId, required this.groupName, required this.role, required this.status, required this.groupArchived, this.emblem});
  

@override final  String groupId;
@override final  String groupName;
@override final  MemberRole role;
@override final  MembershipStatus status;
@override final  bool groupArchived;
@override final  GroupEmblem? emblem;

/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMembershipCopyWith<_GroupMembership> get copyWith => __$GroupMembershipCopyWithImpl<_GroupMembership>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMembership&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.groupName, groupName) || other.groupName == groupName)&&(identical(other.role, role) || other.role == role)&&(identical(other.status, status) || other.status == status)&&(identical(other.groupArchived, groupArchived) || other.groupArchived == groupArchived)&&(identical(other.emblem, emblem) || other.emblem == emblem));
}


@override
int get hashCode => Object.hash(runtimeType,groupId,groupName,role,status,groupArchived,emblem);

@override
String toString() {
  return 'GroupMembership(groupId: $groupId, groupName: $groupName, role: $role, status: $status, groupArchived: $groupArchived, emblem: $emblem)';
}


}

/// @nodoc
abstract mixin class _$GroupMembershipCopyWith<$Res> implements $GroupMembershipCopyWith<$Res> {
  factory _$GroupMembershipCopyWith(_GroupMembership value, $Res Function(_GroupMembership) _then) = __$GroupMembershipCopyWithImpl;
@override @useResult
$Res call({
 String groupId, String groupName, MemberRole role, MembershipStatus status, bool groupArchived, GroupEmblem? emblem
});


@override $GroupEmblemCopyWith<$Res>? get emblem;

}
/// @nodoc
class __$GroupMembershipCopyWithImpl<$Res>
    implements _$GroupMembershipCopyWith<$Res> {
  __$GroupMembershipCopyWithImpl(this._self, this._then);

  final _GroupMembership _self;
  final $Res Function(_GroupMembership) _then;

/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? groupId = null,Object? groupName = null,Object? role = null,Object? status = null,Object? groupArchived = null,Object? emblem = freezed,}) {
  return _then(_GroupMembership(
groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,groupName: null == groupName ? _self.groupName : groupName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembershipStatus,groupArchived: null == groupArchived ? _self.groupArchived : groupArchived // ignore: cast_nullable_to_non_nullable
as bool,emblem: freezed == emblem ? _self.emblem : emblem // ignore: cast_nullable_to_non_nullable
as GroupEmblem?,
  ));
}

/// Create a copy of GroupMembership
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupEmblemCopyWith<$Res>? get emblem {
    if (_self.emblem == null) {
    return null;
  }

  return $GroupEmblemCopyWith<$Res>(_self.emblem!, (value) {
    return _then(_self.copyWith(emblem: value));
  });
}
}

/// @nodoc
mixin _$HabitGroup {

 String get id; String get name; String get description; String get ownerUid; int get memberCount; bool get membersCanInvite; bool get archived; GroupEmblem? get emblem;/// When true, joining with a code only files a request that an admin
/// approves or rejects.
 bool get requireApproval;
/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HabitGroupCopyWith<HabitGroup> get copyWith => _$HabitGroupCopyWithImpl<HabitGroup>(this as HabitGroup, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HabitGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.membersCanInvite, membersCanInvite) || other.membersCanInvite == membersCanInvite)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.emblem, emblem) || other.emblem == emblem)&&(identical(other.requireApproval, requireApproval) || other.requireApproval == requireApproval));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerUid,memberCount,membersCanInvite,archived,emblem,requireApproval);

@override
String toString() {
  return 'HabitGroup(id: $id, name: $name, description: $description, ownerUid: $ownerUid, memberCount: $memberCount, membersCanInvite: $membersCanInvite, archived: $archived, emblem: $emblem, requireApproval: $requireApproval)';
}


}

/// @nodoc
abstract mixin class $HabitGroupCopyWith<$Res>  {
  factory $HabitGroupCopyWith(HabitGroup value, $Res Function(HabitGroup) _then) = _$HabitGroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, String ownerUid, int memberCount, bool membersCanInvite, bool archived, GroupEmblem? emblem, bool requireApproval
});


$GroupEmblemCopyWith<$Res>? get emblem;

}
/// @nodoc
class _$HabitGroupCopyWithImpl<$Res>
    implements $HabitGroupCopyWith<$Res> {
  _$HabitGroupCopyWithImpl(this._self, this._then);

  final HabitGroup _self;
  final $Res Function(HabitGroup) _then;

/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? ownerUid = null,Object? memberCount = null,Object? membersCanInvite = null,Object? archived = null,Object? emblem = freezed,Object? requireApproval = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,membersCanInvite: null == membersCanInvite ? _self.membersCanInvite : membersCanInvite // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,emblem: freezed == emblem ? _self.emblem : emblem // ignore: cast_nullable_to_non_nullable
as GroupEmblem?,requireApproval: null == requireApproval ? _self.requireApproval : requireApproval // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupEmblemCopyWith<$Res>? get emblem {
    if (_self.emblem == null) {
    return null;
  }

  return $GroupEmblemCopyWith<$Res>(_self.emblem!, (value) {
    return _then(_self.copyWith(emblem: value));
  });
}
}


/// Adds pattern-matching-related methods to [HabitGroup].
extension HabitGroupPatterns on HabitGroup {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HabitGroup value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HabitGroup() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HabitGroup value)  $default,){
final _that = this;
switch (_that) {
case _HabitGroup():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HabitGroup value)?  $default,){
final _that = this;
switch (_that) {
case _HabitGroup() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String ownerUid,  int memberCount,  bool membersCanInvite,  bool archived,  GroupEmblem? emblem,  bool requireApproval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HabitGroup() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerUid,_that.memberCount,_that.membersCanInvite,_that.archived,_that.emblem,_that.requireApproval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  String ownerUid,  int memberCount,  bool membersCanInvite,  bool archived,  GroupEmblem? emblem,  bool requireApproval)  $default,) {final _that = this;
switch (_that) {
case _HabitGroup():
return $default(_that.id,_that.name,_that.description,_that.ownerUid,_that.memberCount,_that.membersCanInvite,_that.archived,_that.emblem,_that.requireApproval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  String ownerUid,  int memberCount,  bool membersCanInvite,  bool archived,  GroupEmblem? emblem,  bool requireApproval)?  $default,) {final _that = this;
switch (_that) {
case _HabitGroup() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.ownerUid,_that.memberCount,_that.membersCanInvite,_that.archived,_that.emblem,_that.requireApproval);case _:
  return null;

}
}

}

/// @nodoc


class _HabitGroup implements HabitGroup {
  const _HabitGroup({required this.id, required this.name, required this.description, required this.ownerUid, required this.memberCount, required this.membersCanInvite, required this.archived, this.emblem, this.requireApproval = false});
  

@override final  String id;
@override final  String name;
@override final  String description;
@override final  String ownerUid;
@override final  int memberCount;
@override final  bool membersCanInvite;
@override final  bool archived;
@override final  GroupEmblem? emblem;
/// When true, joining with a code only files a request that an admin
/// approves or rejects.
@override@JsonKey() final  bool requireApproval;

/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HabitGroupCopyWith<_HabitGroup> get copyWith => __$HabitGroupCopyWithImpl<_HabitGroup>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HabitGroup&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.membersCanInvite, membersCanInvite) || other.membersCanInvite == membersCanInvite)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.emblem, emblem) || other.emblem == emblem)&&(identical(other.requireApproval, requireApproval) || other.requireApproval == requireApproval));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,ownerUid,memberCount,membersCanInvite,archived,emblem,requireApproval);

@override
String toString() {
  return 'HabitGroup(id: $id, name: $name, description: $description, ownerUid: $ownerUid, memberCount: $memberCount, membersCanInvite: $membersCanInvite, archived: $archived, emblem: $emblem, requireApproval: $requireApproval)';
}


}

/// @nodoc
abstract mixin class _$HabitGroupCopyWith<$Res> implements $HabitGroupCopyWith<$Res> {
  factory _$HabitGroupCopyWith(_HabitGroup value, $Res Function(_HabitGroup) _then) = __$HabitGroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, String ownerUid, int memberCount, bool membersCanInvite, bool archived, GroupEmblem? emblem, bool requireApproval
});


@override $GroupEmblemCopyWith<$Res>? get emblem;

}
/// @nodoc
class __$HabitGroupCopyWithImpl<$Res>
    implements _$HabitGroupCopyWith<$Res> {
  __$HabitGroupCopyWithImpl(this._self, this._then);

  final _HabitGroup _self;
  final $Res Function(_HabitGroup) _then;

/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? ownerUid = null,Object? memberCount = null,Object? membersCanInvite = null,Object? archived = null,Object? emblem = freezed,Object? requireApproval = null,}) {
  return _then(_HabitGroup(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,membersCanInvite: null == membersCanInvite ? _self.membersCanInvite : membersCanInvite // ignore: cast_nullable_to_non_nullable
as bool,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,emblem: freezed == emblem ? _self.emblem : emblem // ignore: cast_nullable_to_non_nullable
as GroupEmblem?,requireApproval: null == requireApproval ? _self.requireApproval : requireApproval // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of HabitGroup
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupEmblemCopyWith<$Res>? get emblem {
    if (_self.emblem == null) {
    return null;
  }

  return $GroupEmblemCopyWith<$Res>(_self.emblem!, (value) {
    return _then(_self.copyWith(emblem: value));
  });
}
}

/// @nodoc
mixin _$GroupMember {

 String get uid; String get displayName; MemberRole get role; bool get active;
/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupMemberCopyWith<GroupMember> get copyWith => _$GroupMemberCopyWithImpl<GroupMember>(this as GroupMember, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupMember&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName,role,active);

@override
String toString() {
  return 'GroupMember(uid: $uid, displayName: $displayName, role: $role, active: $active)';
}


}

/// @nodoc
abstract mixin class $GroupMemberCopyWith<$Res>  {
  factory $GroupMemberCopyWith(GroupMember value, $Res Function(GroupMember) _then) = _$GroupMemberCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName, MemberRole role, bool active
});




}
/// @nodoc
class _$GroupMemberCopyWithImpl<$Res>
    implements $GroupMemberCopyWith<$Res> {
  _$GroupMemberCopyWithImpl(this._self, this._then);

  final GroupMember _self;
  final $Res Function(GroupMember) _then;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,Object? role = null,Object? active = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupMember].
extension GroupMemberPatterns on GroupMember {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupMember value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupMember value)  $default,){
final _that = this;
switch (_that) {
case _GroupMember():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupMember value)?  $default,){
final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName,  MemberRole role,  bool active)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
return $default(_that.uid,_that.displayName,_that.role,_that.active);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName,  MemberRole role,  bool active)  $default,) {final _that = this;
switch (_that) {
case _GroupMember():
return $default(_that.uid,_that.displayName,_that.role,_that.active);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName,  MemberRole role,  bool active)?  $default,) {final _that = this;
switch (_that) {
case _GroupMember() when $default != null:
return $default(_that.uid,_that.displayName,_that.role,_that.active);case _:
  return null;

}
}

}

/// @nodoc


class _GroupMember implements GroupMember {
  const _GroupMember({required this.uid, required this.displayName, required this.role, required this.active});
  

@override final  String uid;
@override final  String displayName;
@override final  MemberRole role;
@override final  bool active;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupMemberCopyWith<_GroupMember> get copyWith => __$GroupMemberCopyWithImpl<_GroupMember>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupMember&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.role, role) || other.role == role)&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName,role,active);

@override
String toString() {
  return 'GroupMember(uid: $uid, displayName: $displayName, role: $role, active: $active)';
}


}

/// @nodoc
abstract mixin class _$GroupMemberCopyWith<$Res> implements $GroupMemberCopyWith<$Res> {
  factory _$GroupMemberCopyWith(_GroupMember value, $Res Function(_GroupMember) _then) = __$GroupMemberCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName, MemberRole role, bool active
});




}
/// @nodoc
class __$GroupMemberCopyWithImpl<$Res>
    implements _$GroupMemberCopyWith<$Res> {
  __$GroupMemberCopyWithImpl(this._self, this._then);

  final _GroupMember _self;
  final $Res Function(_GroupMember) _then;

/// Create a copy of GroupMember
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,Object? role = null,Object? active = null,}) {
  return _then(_GroupMember(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as MemberRole,active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$GroupStreak {

 int get current; int get best;
/// Create a copy of GroupStreak
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupStreakCopyWith<GroupStreak> get copyWith => _$GroupStreakCopyWithImpl<GroupStreak>(this as GroupStreak, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best));
}


@override
int get hashCode => Object.hash(runtimeType,current,best);

@override
String toString() {
  return 'GroupStreak(current: $current, best: $best)';
}


}

/// @nodoc
abstract mixin class $GroupStreakCopyWith<$Res>  {
  factory $GroupStreakCopyWith(GroupStreak value, $Res Function(GroupStreak) _then) = _$GroupStreakCopyWithImpl;
@useResult
$Res call({
 int current, int best
});




}
/// @nodoc
class _$GroupStreakCopyWithImpl<$Res>
    implements $GroupStreakCopyWith<$Res> {
  _$GroupStreakCopyWithImpl(this._self, this._then);

  final GroupStreak _self;
  final $Res Function(GroupStreak) _then;

/// Create a copy of GroupStreak
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? current = null,Object? best = null,}) {
  return _then(_self.copyWith(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [GroupStreak].
extension GroupStreakPatterns on GroupStreak {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupStreak value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupStreak() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupStreak value)  $default,){
final _that = this;
switch (_that) {
case _GroupStreak():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupStreak value)?  $default,){
final _that = this;
switch (_that) {
case _GroupStreak() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int current,  int best)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupStreak() when $default != null:
return $default(_that.current,_that.best);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int current,  int best)  $default,) {final _that = this;
switch (_that) {
case _GroupStreak():
return $default(_that.current,_that.best);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int current,  int best)?  $default,) {final _that = this;
switch (_that) {
case _GroupStreak() when $default != null:
return $default(_that.current,_that.best);case _:
  return null;

}
}

}

/// @nodoc


class _GroupStreak implements GroupStreak {
  const _GroupStreak({required this.current, required this.best});
  

@override final  int current;
@override final  int best;

/// Create a copy of GroupStreak
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupStreakCopyWith<_GroupStreak> get copyWith => __$GroupStreakCopyWithImpl<_GroupStreak>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupStreak&&(identical(other.current, current) || other.current == current)&&(identical(other.best, best) || other.best == best));
}


@override
int get hashCode => Object.hash(runtimeType,current,best);

@override
String toString() {
  return 'GroupStreak(current: $current, best: $best)';
}


}

/// @nodoc
abstract mixin class _$GroupStreakCopyWith<$Res> implements $GroupStreakCopyWith<$Res> {
  factory _$GroupStreakCopyWith(_GroupStreak value, $Res Function(_GroupStreak) _then) = __$GroupStreakCopyWithImpl;
@override @useResult
$Res call({
 int current, int best
});




}
/// @nodoc
class __$GroupStreakCopyWithImpl<$Res>
    implements _$GroupStreakCopyWith<$Res> {
  __$GroupStreakCopyWithImpl(this._self, this._then);

  final _GroupStreak _self;
  final $Res Function(_GroupStreak) _then;

/// Create a copy of GroupStreak
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? current = null,Object? best = null,}) {
  return _then(_GroupStreak(
current: null == current ? _self.current : current // ignore: cast_nullable_to_non_nullable
as int,best: null == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$GroupHabit {

 String get id; String get name; String get description; Set<int> get weekdays; CompletionRule get target; DateKey get startDate; DateKey? get endDate; bool get archived; GroupStreak get groupStreak;/// When a queued schedule or target change starts, if there is one.
 DateKey? get pendingFrom;
/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupHabitCopyWith<GroupHabit> get copyWith => _$GroupHabitCopyWithImpl<GroupHabit>(this as GroupHabit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupHabit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.target, target) || other.target == target)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.groupStreak, groupStreak) || other.groupStreak == groupStreak)&&(identical(other.pendingFrom, pendingFrom) || other.pendingFrom == pendingFrom));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(weekdays),target,startDate,endDate,archived,groupStreak,pendingFrom);

@override
String toString() {
  return 'GroupHabit(id: $id, name: $name, description: $description, weekdays: $weekdays, target: $target, startDate: $startDate, endDate: $endDate, archived: $archived, groupStreak: $groupStreak, pendingFrom: $pendingFrom)';
}


}

/// @nodoc
abstract mixin class $GroupHabitCopyWith<$Res>  {
  factory $GroupHabitCopyWith(GroupHabit value, $Res Function(GroupHabit) _then) = _$GroupHabitCopyWithImpl;
@useResult
$Res call({
 String id, String name, String description, Set<int> weekdays, CompletionRule target, DateKey startDate, DateKey? endDate, bool archived, GroupStreak groupStreak, DateKey? pendingFrom
});


$GroupStreakCopyWith<$Res> get groupStreak;

}
/// @nodoc
class _$GroupHabitCopyWithImpl<$Res>
    implements $GroupHabitCopyWith<$Res> {
  _$GroupHabitCopyWithImpl(this._self, this._then);

  final GroupHabit _self;
  final $Res Function(GroupHabit) _then;

/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? weekdays = null,Object? target = null,Object? startDate = null,Object? endDate = freezed,Object? archived = null,Object? groupStreak = null,Object? pendingFrom = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CompletionRule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateKey?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,groupStreak: null == groupStreak ? _self.groupStreak : groupStreak // ignore: cast_nullable_to_non_nullable
as GroupStreak,pendingFrom: freezed == pendingFrom ? _self.pendingFrom : pendingFrom // ignore: cast_nullable_to_non_nullable
as DateKey?,
  ));
}
/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStreakCopyWith<$Res> get groupStreak {
  
  return $GroupStreakCopyWith<$Res>(_self.groupStreak, (value) {
    return _then(_self.copyWith(groupStreak: value));
  });
}
}


/// Adds pattern-matching-related methods to [GroupHabit].
extension GroupHabitPatterns on GroupHabit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GroupHabit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GroupHabit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GroupHabit value)  $default,){
final _that = this;
switch (_that) {
case _GroupHabit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GroupHabit value)?  $default,){
final _that = this;
switch (_that) {
case _GroupHabit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate,  bool archived,  GroupStreak groupStreak,  DateKey? pendingFrom)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GroupHabit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate,_that.archived,_that.groupStreak,_that.pendingFrom);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate,  bool archived,  GroupStreak groupStreak,  DateKey? pendingFrom)  $default,) {final _that = this;
switch (_that) {
case _GroupHabit():
return $default(_that.id,_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate,_that.archived,_that.groupStreak,_that.pendingFrom);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate,  bool archived,  GroupStreak groupStreak,  DateKey? pendingFrom)?  $default,) {final _that = this;
switch (_that) {
case _GroupHabit() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate,_that.archived,_that.groupStreak,_that.pendingFrom);case _:
  return null;

}
}

}

/// @nodoc


class _GroupHabit implements GroupHabit {
  const _GroupHabit({required this.id, required this.name, required this.description, required final  Set<int> weekdays, required this.target, required this.startDate, required this.endDate, required this.archived, required this.groupStreak, required this.pendingFrom}): _weekdays = weekdays;
  

@override final  String id;
@override final  String name;
@override final  String description;
 final  Set<int> _weekdays;
@override Set<int> get weekdays {
  if (_weekdays is EqualUnmodifiableSetView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weekdays);
}

@override final  CompletionRule target;
@override final  DateKey startDate;
@override final  DateKey? endDate;
@override final  bool archived;
@override final  GroupStreak groupStreak;
/// When a queued schedule or target change starts, if there is one.
@override final  DateKey? pendingFrom;

/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupHabitCopyWith<_GroupHabit> get copyWith => __$GroupHabitCopyWithImpl<_GroupHabit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GroupHabit&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.target, target) || other.target == target)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.groupStreak, groupStreak) || other.groupStreak == groupStreak)&&(identical(other.pendingFrom, pendingFrom) || other.pendingFrom == pendingFrom));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_weekdays),target,startDate,endDate,archived,groupStreak,pendingFrom);

@override
String toString() {
  return 'GroupHabit(id: $id, name: $name, description: $description, weekdays: $weekdays, target: $target, startDate: $startDate, endDate: $endDate, archived: $archived, groupStreak: $groupStreak, pendingFrom: $pendingFrom)';
}


}

/// @nodoc
abstract mixin class _$GroupHabitCopyWith<$Res> implements $GroupHabitCopyWith<$Res> {
  factory _$GroupHabitCopyWith(_GroupHabit value, $Res Function(_GroupHabit) _then) = __$GroupHabitCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String description, Set<int> weekdays, CompletionRule target, DateKey startDate, DateKey? endDate, bool archived, GroupStreak groupStreak, DateKey? pendingFrom
});


@override $GroupStreakCopyWith<$Res> get groupStreak;

}
/// @nodoc
class __$GroupHabitCopyWithImpl<$Res>
    implements _$GroupHabitCopyWith<$Res> {
  __$GroupHabitCopyWithImpl(this._self, this._then);

  final _GroupHabit _self;
  final $Res Function(_GroupHabit) _then;

/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? weekdays = null,Object? target = null,Object? startDate = null,Object? endDate = freezed,Object? archived = null,Object? groupStreak = null,Object? pendingFrom = freezed,}) {
  return _then(_GroupHabit(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CompletionRule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateKey?,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,groupStreak: null == groupStreak ? _self.groupStreak : groupStreak // ignore: cast_nullable_to_non_nullable
as GroupStreak,pendingFrom: freezed == pendingFrom ? _self.pendingFrom : pendingFrom // ignore: cast_nullable_to_non_nullable
as DateKey?,
  ));
}

/// Create a copy of GroupHabit
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GroupStreakCopyWith<$Res> get groupStreak {
  
  return $GroupStreakCopyWith<$Res>(_self.groupStreak, (value) {
    return _then(_self.copyWith(groupStreak: value));
  });
}
}

/// @nodoc
mixin _$NewGroupHabit {

 String get name; String get description; Set<int> get weekdays; CompletionRule get target; DateKey get startDate; DateKey? get endDate;
/// Create a copy of NewGroupHabit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewGroupHabitCopyWith<NewGroupHabit> get copyWith => _$NewGroupHabitCopyWithImpl<NewGroupHabit>(this as NewGroupHabit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewGroupHabit&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.weekdays, weekdays)&&(identical(other.target, target) || other.target == target)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(weekdays),target,startDate,endDate);

@override
String toString() {
  return 'NewGroupHabit(name: $name, description: $description, weekdays: $weekdays, target: $target, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class $NewGroupHabitCopyWith<$Res>  {
  factory $NewGroupHabitCopyWith(NewGroupHabit value, $Res Function(NewGroupHabit) _then) = _$NewGroupHabitCopyWithImpl;
@useResult
$Res call({
 String name, String description, Set<int> weekdays, CompletionRule target, DateKey startDate, DateKey? endDate
});




}
/// @nodoc
class _$NewGroupHabitCopyWithImpl<$Res>
    implements $NewGroupHabitCopyWith<$Res> {
  _$NewGroupHabitCopyWithImpl(this._self, this._then);

  final NewGroupHabit _self;
  final $Res Function(NewGroupHabit) _then;

/// Create a copy of NewGroupHabit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = null,Object? weekdays = null,Object? target = null,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self.weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CompletionRule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateKey?,
  ));
}

}


/// Adds pattern-matching-related methods to [NewGroupHabit].
extension NewGroupHabitPatterns on NewGroupHabit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewGroupHabit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewGroupHabit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewGroupHabit value)  $default,){
final _that = this;
switch (_that) {
case _NewGroupHabit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewGroupHabit value)?  $default,){
final _that = this;
switch (_that) {
case _NewGroupHabit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewGroupHabit() when $default != null:
return $default(_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate)  $default,) {final _that = this;
switch (_that) {
case _NewGroupHabit():
return $default(_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String description,  Set<int> weekdays,  CompletionRule target,  DateKey startDate,  DateKey? endDate)?  $default,) {final _that = this;
switch (_that) {
case _NewGroupHabit() when $default != null:
return $default(_that.name,_that.description,_that.weekdays,_that.target,_that.startDate,_that.endDate);case _:
  return null;

}
}

}

/// @nodoc


class _NewGroupHabit implements NewGroupHabit {
  const _NewGroupHabit({required this.name, required this.description, required final  Set<int> weekdays, required this.target, required this.startDate, this.endDate}): _weekdays = weekdays;
  

@override final  String name;
@override final  String description;
 final  Set<int> _weekdays;
@override Set<int> get weekdays {
  if (_weekdays is EqualUnmodifiableSetView) return _weekdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_weekdays);
}

@override final  CompletionRule target;
@override final  DateKey startDate;
@override final  DateKey? endDate;

/// Create a copy of NewGroupHabit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewGroupHabitCopyWith<_NewGroupHabit> get copyWith => __$NewGroupHabitCopyWithImpl<_NewGroupHabit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewGroupHabit&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._weekdays, _weekdays)&&(identical(other.target, target) || other.target == target)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,const DeepCollectionEquality().hash(_weekdays),target,startDate,endDate);

@override
String toString() {
  return 'NewGroupHabit(name: $name, description: $description, weekdays: $weekdays, target: $target, startDate: $startDate, endDate: $endDate)';
}


}

/// @nodoc
abstract mixin class _$NewGroupHabitCopyWith<$Res> implements $NewGroupHabitCopyWith<$Res> {
  factory _$NewGroupHabitCopyWith(_NewGroupHabit value, $Res Function(_NewGroupHabit) _then) = __$NewGroupHabitCopyWithImpl;
@override @useResult
$Res call({
 String name, String description, Set<int> weekdays, CompletionRule target, DateKey startDate, DateKey? endDate
});




}
/// @nodoc
class __$NewGroupHabitCopyWithImpl<$Res>
    implements _$NewGroupHabitCopyWith<$Res> {
  __$NewGroupHabitCopyWithImpl(this._self, this._then);

  final _NewGroupHabit _self;
  final $Res Function(_NewGroupHabit) _then;

/// Create a copy of NewGroupHabit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = null,Object? weekdays = null,Object? target = null,Object? startDate = null,Object? endDate = freezed,}) {
  return _then(_NewGroupHabit(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,weekdays: null == weekdays ? _self._weekdays : weekdays // ignore: cast_nullable_to_non_nullable
as Set<int>,target: null == target ? _self.target : target // ignore: cast_nullable_to_non_nullable
as CompletionRule,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateKey,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateKey?,
  ));
}


}

/// @nodoc
mixin _$MyCompletions {

 Set<DateKey> get dates; bool get hasPendingWrites;
/// Create a copy of MyCompletions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MyCompletionsCopyWith<MyCompletions> get copyWith => _$MyCompletionsCopyWithImpl<MyCompletions>(this as MyCompletions, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MyCompletions&&const DeepCollectionEquality().equals(other.dates, dates)&&(identical(other.hasPendingWrites, hasPendingWrites) || other.hasPendingWrites == hasPendingWrites));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(dates),hasPendingWrites);

@override
String toString() {
  return 'MyCompletions(dates: $dates, hasPendingWrites: $hasPendingWrites)';
}


}

/// @nodoc
abstract mixin class $MyCompletionsCopyWith<$Res>  {
  factory $MyCompletionsCopyWith(MyCompletions value, $Res Function(MyCompletions) _then) = _$MyCompletionsCopyWithImpl;
@useResult
$Res call({
 Set<DateKey> dates, bool hasPendingWrites
});




}
/// @nodoc
class _$MyCompletionsCopyWithImpl<$Res>
    implements $MyCompletionsCopyWith<$Res> {
  _$MyCompletionsCopyWithImpl(this._self, this._then);

  final MyCompletions _self;
  final $Res Function(MyCompletions) _then;

/// Create a copy of MyCompletions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? dates = null,Object? hasPendingWrites = null,}) {
  return _then(_self.copyWith(
dates: null == dates ? _self.dates : dates // ignore: cast_nullable_to_non_nullable
as Set<DateKey>,hasPendingWrites: null == hasPendingWrites ? _self.hasPendingWrites : hasPendingWrites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MyCompletions].
extension MyCompletionsPatterns on MyCompletions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MyCompletions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MyCompletions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MyCompletions value)  $default,){
final _that = this;
switch (_that) {
case _MyCompletions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MyCompletions value)?  $default,){
final _that = this;
switch (_that) {
case _MyCompletions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Set<DateKey> dates,  bool hasPendingWrites)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MyCompletions() when $default != null:
return $default(_that.dates,_that.hasPendingWrites);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Set<DateKey> dates,  bool hasPendingWrites)  $default,) {final _that = this;
switch (_that) {
case _MyCompletions():
return $default(_that.dates,_that.hasPendingWrites);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Set<DateKey> dates,  bool hasPendingWrites)?  $default,) {final _that = this;
switch (_that) {
case _MyCompletions() when $default != null:
return $default(_that.dates,_that.hasPendingWrites);case _:
  return null;

}
}

}

/// @nodoc


class _MyCompletions implements MyCompletions {
  const _MyCompletions({required final  Set<DateKey> dates, required this.hasPendingWrites}): _dates = dates;
  

 final  Set<DateKey> _dates;
@override Set<DateKey> get dates {
  if (_dates is EqualUnmodifiableSetView) return _dates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_dates);
}

@override final  bool hasPendingWrites;

/// Create a copy of MyCompletions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MyCompletionsCopyWith<_MyCompletions> get copyWith => __$MyCompletionsCopyWithImpl<_MyCompletions>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MyCompletions&&const DeepCollectionEquality().equals(other._dates, _dates)&&(identical(other.hasPendingWrites, hasPendingWrites) || other.hasPendingWrites == hasPendingWrites));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_dates),hasPendingWrites);

@override
String toString() {
  return 'MyCompletions(dates: $dates, hasPendingWrites: $hasPendingWrites)';
}


}

/// @nodoc
abstract mixin class _$MyCompletionsCopyWith<$Res> implements $MyCompletionsCopyWith<$Res> {
  factory _$MyCompletionsCopyWith(_MyCompletions value, $Res Function(_MyCompletions) _then) = __$MyCompletionsCopyWithImpl;
@override @useResult
$Res call({
 Set<DateKey> dates, bool hasPendingWrites
});




}
/// @nodoc
class __$MyCompletionsCopyWithImpl<$Res>
    implements _$MyCompletionsCopyWith<$Res> {
  __$MyCompletionsCopyWithImpl(this._self, this._then);

  final _MyCompletions _self;
  final $Res Function(_MyCompletions) _then;

/// Create a copy of MyCompletions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? dates = null,Object? hasPendingWrites = null,}) {
  return _then(_MyCompletions(
dates: null == dates ? _self._dates : dates // ignore: cast_nullable_to_non_nullable
as Set<DateKey>,hasPendingWrites: null == hasPendingWrites ? _self.hasPendingWrites : hasPendingWrites // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$JoinRequest {

 String get uid; String get displayName;
/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$JoinRequestCopyWith<JoinRequest> get copyWith => _$JoinRequestCopyWithImpl<JoinRequest>(this as JoinRequest, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is JoinRequest&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName);

@override
String toString() {
  return 'JoinRequest(uid: $uid, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class $JoinRequestCopyWith<$Res>  {
  factory $JoinRequestCopyWith(JoinRequest value, $Res Function(JoinRequest) _then) = _$JoinRequestCopyWithImpl;
@useResult
$Res call({
 String uid, String displayName
});




}
/// @nodoc
class _$JoinRequestCopyWithImpl<$Res>
    implements $JoinRequestCopyWith<$Res> {
  _$JoinRequestCopyWithImpl(this._self, this._then);

  final JoinRequest _self;
  final $Res Function(JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? displayName = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [JoinRequest].
extension JoinRequestPatterns on JoinRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _JoinRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _JoinRequest value)  $default,){
final _that = this;
switch (_that) {
case _JoinRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _JoinRequest value)?  $default,){
final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String displayName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.uid,_that.displayName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String displayName)  $default,) {final _that = this;
switch (_that) {
case _JoinRequest():
return $default(_that.uid,_that.displayName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String displayName)?  $default,) {final _that = this;
switch (_that) {
case _JoinRequest() when $default != null:
return $default(_that.uid,_that.displayName);case _:
  return null;

}
}

}

/// @nodoc


class _JoinRequest implements JoinRequest {
  const _JoinRequest({required this.uid, required this.displayName});
  

@override final  String uid;
@override final  String displayName;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$JoinRequestCopyWith<_JoinRequest> get copyWith => __$JoinRequestCopyWithImpl<_JoinRequest>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _JoinRequest&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.displayName, displayName) || other.displayName == displayName));
}


@override
int get hashCode => Object.hash(runtimeType,uid,displayName);

@override
String toString() {
  return 'JoinRequest(uid: $uid, displayName: $displayName)';
}


}

/// @nodoc
abstract mixin class _$JoinRequestCopyWith<$Res> implements $JoinRequestCopyWith<$Res> {
  factory _$JoinRequestCopyWith(_JoinRequest value, $Res Function(_JoinRequest) _then) = __$JoinRequestCopyWithImpl;
@override @useResult
$Res call({
 String uid, String displayName
});




}
/// @nodoc
class __$JoinRequestCopyWithImpl<$Res>
    implements _$JoinRequestCopyWith<$Res> {
  __$JoinRequestCopyWithImpl(this._self, this._then);

  final _JoinRequest _self;
  final $Res Function(_JoinRequest) _then;

/// Create a copy of JoinRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? displayName = null,}) {
  return _then(_JoinRequest(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$AuditEntry {

 String get id; String get action; String get actorUid; DateTime? get at; Map<String, Object?> get details;
/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuditEntryCopyWith<AuditEntry> get copyWith => _$AuditEntryCopyWithImpl<AuditEntry>(this as AuditEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuditEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.at, at) || other.at == at)&&const DeepCollectionEquality().equals(other.details, details));
}


@override
int get hashCode => Object.hash(runtimeType,id,action,actorUid,at,const DeepCollectionEquality().hash(details));

@override
String toString() {
  return 'AuditEntry(id: $id, action: $action, actorUid: $actorUid, at: $at, details: $details)';
}


}

/// @nodoc
abstract mixin class $AuditEntryCopyWith<$Res>  {
  factory $AuditEntryCopyWith(AuditEntry value, $Res Function(AuditEntry) _then) = _$AuditEntryCopyWithImpl;
@useResult
$Res call({
 String id, String action, String actorUid, DateTime? at, Map<String, Object?> details
});




}
/// @nodoc
class _$AuditEntryCopyWithImpl<$Res>
    implements $AuditEntryCopyWith<$Res> {
  _$AuditEntryCopyWithImpl(this._self, this._then);

  final AuditEntry _self;
  final $Res Function(AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? action = null,Object? actorUid = null,Object? at = freezed,Object? details = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuditEntry].
extension AuditEntryPatterns on AuditEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuditEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuditEntry value)  $default,){
final _that = this;
switch (_that) {
case _AuditEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuditEntry value)?  $default,){
final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String action,  String actorUid,  DateTime? at,  Map<String, Object?> details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.action,_that.actorUid,_that.at,_that.details);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String action,  String actorUid,  DateTime? at,  Map<String, Object?> details)  $default,) {final _that = this;
switch (_that) {
case _AuditEntry():
return $default(_that.id,_that.action,_that.actorUid,_that.at,_that.details);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String action,  String actorUid,  DateTime? at,  Map<String, Object?> details)?  $default,) {final _that = this;
switch (_that) {
case _AuditEntry() when $default != null:
return $default(_that.id,_that.action,_that.actorUid,_that.at,_that.details);case _:
  return null;

}
}

}

/// @nodoc


class _AuditEntry implements AuditEntry {
  const _AuditEntry({required this.id, required this.action, required this.actorUid, required this.at, required final  Map<String, Object?> details}): _details = details;
  

@override final  String id;
@override final  String action;
@override final  String actorUid;
@override final  DateTime? at;
 final  Map<String, Object?> _details;
@override Map<String, Object?> get details {
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_details);
}


/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuditEntryCopyWith<_AuditEntry> get copyWith => __$AuditEntryCopyWithImpl<_AuditEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuditEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.action, action) || other.action == action)&&(identical(other.actorUid, actorUid) || other.actorUid == actorUid)&&(identical(other.at, at) || other.at == at)&&const DeepCollectionEquality().equals(other._details, _details));
}


@override
int get hashCode => Object.hash(runtimeType,id,action,actorUid,at,const DeepCollectionEquality().hash(_details));

@override
String toString() {
  return 'AuditEntry(id: $id, action: $action, actorUid: $actorUid, at: $at, details: $details)';
}


}

/// @nodoc
abstract mixin class _$AuditEntryCopyWith<$Res> implements $AuditEntryCopyWith<$Res> {
  factory _$AuditEntryCopyWith(_AuditEntry value, $Res Function(_AuditEntry) _then) = __$AuditEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String action, String actorUid, DateTime? at, Map<String, Object?> details
});




}
/// @nodoc
class __$AuditEntryCopyWithImpl<$Res>
    implements _$AuditEntryCopyWith<$Res> {
  __$AuditEntryCopyWithImpl(this._self, this._then);

  final _AuditEntry _self;
  final $Res Function(_AuditEntry) _then;

/// Create a copy of AuditEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? action = null,Object? actorUid = null,Object? at = freezed,Object? details = null,}) {
  return _then(_AuditEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,action: null == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String,actorUid: null == actorUid ? _self.actorUid : actorUid // ignore: cast_nullable_to_non_nullable
as String,at: freezed == at ? _self.at : at // ignore: cast_nullable_to_non_nullable
as DateTime?,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}


}

// dart format on
