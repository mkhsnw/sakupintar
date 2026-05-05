// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BudgetModel {

 String get monthKey;// "YYYY-MM"
 double get income;@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) Timestamp get createdAt; List<AllocationModel> get allocations;
/// Create a copy of BudgetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BudgetModelCopyWith<BudgetModel> get copyWith => _$BudgetModelCopyWithImpl<BudgetModel>(this as BudgetModel, _$identity);

  /// Serializes this BudgetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BudgetModel&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.income, income) || other.income == income)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.allocations, allocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthKey,income,createdAt,const DeepCollectionEquality().hash(allocations));

@override
String toString() {
  return 'BudgetModel(monthKey: $monthKey, income: $income, createdAt: $createdAt, allocations: $allocations)';
}


}

/// @nodoc
abstract mixin class $BudgetModelCopyWith<$Res>  {
  factory $BudgetModelCopyWith(BudgetModel value, $Res Function(BudgetModel) _then) = _$BudgetModelCopyWithImpl;
@useResult
$Res call({
 String monthKey, double income,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) Timestamp createdAt, List<AllocationModel> allocations
});




}
/// @nodoc
class _$BudgetModelCopyWithImpl<$Res>
    implements $BudgetModelCopyWith<$Res> {
  _$BudgetModelCopyWithImpl(this._self, this._then);

  final BudgetModel _self;
  final $Res Function(BudgetModel) _then;

/// Create a copy of BudgetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? monthKey = null,Object? income = null,Object? createdAt = null,Object? allocations = null,}) {
  return _then(_self.copyWith(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as Timestamp,allocations: null == allocations ? _self.allocations : allocations // ignore: cast_nullable_to_non_nullable
as List<AllocationModel>,
  ));
}

}


/// Adds pattern-matching-related methods to [BudgetModel].
extension BudgetModelPatterns on BudgetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BudgetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BudgetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BudgetModel value)  $default,){
final _that = this;
switch (_that) {
case _BudgetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BudgetModel value)?  $default,){
final _that = this;
switch (_that) {
case _BudgetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String monthKey,  double income, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  Timestamp createdAt,  List<AllocationModel> allocations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BudgetModel() when $default != null:
return $default(_that.monthKey,_that.income,_that.createdAt,_that.allocations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String monthKey,  double income, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  Timestamp createdAt,  List<AllocationModel> allocations)  $default,) {final _that = this;
switch (_that) {
case _BudgetModel():
return $default(_that.monthKey,_that.income,_that.createdAt,_that.allocations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String monthKey,  double income, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson)  Timestamp createdAt,  List<AllocationModel> allocations)?  $default,) {final _that = this;
switch (_that) {
case _BudgetModel() when $default != null:
return $default(_that.monthKey,_that.income,_that.createdAt,_that.allocations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BudgetModel implements BudgetModel {
  const _BudgetModel({required this.monthKey, required this.income, @JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) required this.createdAt, final  List<AllocationModel> allocations = const []}): _allocations = allocations;
  factory _BudgetModel.fromJson(Map<String, dynamic> json) => _$BudgetModelFromJson(json);

@override final  String monthKey;
// "YYYY-MM"
@override final  double income;
@override@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) final  Timestamp createdAt;
 final  List<AllocationModel> _allocations;
@override@JsonKey() List<AllocationModel> get allocations {
  if (_allocations is EqualUnmodifiableListView) return _allocations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allocations);
}


/// Create a copy of BudgetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BudgetModelCopyWith<_BudgetModel> get copyWith => __$BudgetModelCopyWithImpl<_BudgetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BudgetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BudgetModel&&(identical(other.monthKey, monthKey) || other.monthKey == monthKey)&&(identical(other.income, income) || other.income == income)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._allocations, _allocations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,monthKey,income,createdAt,const DeepCollectionEquality().hash(_allocations));

@override
String toString() {
  return 'BudgetModel(monthKey: $monthKey, income: $income, createdAt: $createdAt, allocations: $allocations)';
}


}

/// @nodoc
abstract mixin class _$BudgetModelCopyWith<$Res> implements $BudgetModelCopyWith<$Res> {
  factory _$BudgetModelCopyWith(_BudgetModel value, $Res Function(_BudgetModel) _then) = __$BudgetModelCopyWithImpl;
@override @useResult
$Res call({
 String monthKey, double income,@JsonKey(fromJson: _timestampFromJson, toJson: _timestampToJson) Timestamp createdAt, List<AllocationModel> allocations
});




}
/// @nodoc
class __$BudgetModelCopyWithImpl<$Res>
    implements _$BudgetModelCopyWith<$Res> {
  __$BudgetModelCopyWithImpl(this._self, this._then);

  final _BudgetModel _self;
  final $Res Function(_BudgetModel) _then;

/// Create a copy of BudgetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? monthKey = null,Object? income = null,Object? createdAt = null,Object? allocations = null,}) {
  return _then(_BudgetModel(
monthKey: null == monthKey ? _self.monthKey : monthKey // ignore: cast_nullable_to_non_nullable
as String,income: null == income ? _self.income : income // ignore: cast_nullable_to_non_nullable
as double,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as Timestamp,allocations: null == allocations ? _self._allocations : allocations // ignore: cast_nullable_to_non_nullable
as List<AllocationModel>,
  ));
}


}


/// @nodoc
mixin _$AllocationModel {

 String get categoryId; String get label; double get limitAmount; double get percentage;
/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AllocationModelCopyWith<AllocationModel> get copyWith => _$AllocationModelCopyWithImpl<AllocationModel>(this as AllocationModel, _$identity);

  /// Serializes this AllocationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AllocationModel&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.label, label) || other.label == label)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,label,limitAmount,percentage);

@override
String toString() {
  return 'AllocationModel(categoryId: $categoryId, label: $label, limitAmount: $limitAmount, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class $AllocationModelCopyWith<$Res>  {
  factory $AllocationModelCopyWith(AllocationModel value, $Res Function(AllocationModel) _then) = _$AllocationModelCopyWithImpl;
@useResult
$Res call({
 String categoryId, String label, double limitAmount, double percentage
});




}
/// @nodoc
class _$AllocationModelCopyWithImpl<$Res>
    implements $AllocationModelCopyWith<$Res> {
  _$AllocationModelCopyWithImpl(this._self, this._then);

  final AllocationModel _self;
  final $Res Function(AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? label = null,Object? limitAmount = null,Object? percentage = null,}) {
  return _then(_self.copyWith(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as double,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [AllocationModel].
extension AllocationModelPatterns on AllocationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AllocationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AllocationModel value)  $default,){
final _that = this;
switch (_that) {
case _AllocationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AllocationModel value)?  $default,){
final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String label,  double limitAmount,  double percentage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.categoryId,_that.label,_that.limitAmount,_that.percentage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String label,  double limitAmount,  double percentage)  $default,) {final _that = this;
switch (_that) {
case _AllocationModel():
return $default(_that.categoryId,_that.label,_that.limitAmount,_that.percentage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String label,  double limitAmount,  double percentage)?  $default,) {final _that = this;
switch (_that) {
case _AllocationModel() when $default != null:
return $default(_that.categoryId,_that.label,_that.limitAmount,_that.percentage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AllocationModel implements AllocationModel {
  const _AllocationModel({required this.categoryId, required this.label, required this.limitAmount, required this.percentage});
  factory _AllocationModel.fromJson(Map<String, dynamic> json) => _$AllocationModelFromJson(json);

@override final  String categoryId;
@override final  String label;
@override final  double limitAmount;
@override final  double percentage;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AllocationModelCopyWith<_AllocationModel> get copyWith => __$AllocationModelCopyWithImpl<_AllocationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AllocationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AllocationModel&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.label, label) || other.label == label)&&(identical(other.limitAmount, limitAmount) || other.limitAmount == limitAmount)&&(identical(other.percentage, percentage) || other.percentage == percentage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,categoryId,label,limitAmount,percentage);

@override
String toString() {
  return 'AllocationModel(categoryId: $categoryId, label: $label, limitAmount: $limitAmount, percentage: $percentage)';
}


}

/// @nodoc
abstract mixin class _$AllocationModelCopyWith<$Res> implements $AllocationModelCopyWith<$Res> {
  factory _$AllocationModelCopyWith(_AllocationModel value, $Res Function(_AllocationModel) _then) = __$AllocationModelCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String label, double limitAmount, double percentage
});




}
/// @nodoc
class __$AllocationModelCopyWithImpl<$Res>
    implements _$AllocationModelCopyWith<$Res> {
  __$AllocationModelCopyWithImpl(this._self, this._then);

  final _AllocationModel _self;
  final $Res Function(_AllocationModel) _then;

/// Create a copy of AllocationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? label = null,Object? limitAmount = null,Object? percentage = null,}) {
  return _then(_AllocationModel(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,limitAmount: null == limitAmount ? _self.limitAmount : limitAmount // ignore: cast_nullable_to_non_nullable
as double,percentage: null == percentage ? _self.percentage : percentage // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
