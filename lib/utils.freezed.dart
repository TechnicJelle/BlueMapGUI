// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'utils.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GetJarError {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is GetJarError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'GetJarError()';
}


}

/// @nodoc
class $GetJarErrorCopyWith<$Res>  {
$GetJarErrorCopyWith(GetJarError _, $Res Function(GetJarError) __);
}


/// Adds pattern-matching-related methods to [GetJarError].
extension GetJarErrorPatterns on GetJarError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( FileWrongHash value)?  fileWrongHash,TResult Function( DownloadWrongHash value)?  downloadWrongHash,TResult Function( DownloadFailed value)?  downloadFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case FileWrongHash() when fileWrongHash != null:
return fileWrongHash(_that);case DownloadWrongHash() when downloadWrongHash != null:
return downloadWrongHash(_that);case DownloadFailed() when downloadFailed != null:
return downloadFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( FileWrongHash value)  fileWrongHash,required TResult Function( DownloadWrongHash value)  downloadWrongHash,required TResult Function( DownloadFailed value)  downloadFailed,}){
final _that = this;
switch (_that) {
case FileWrongHash():
return fileWrongHash(_that);case DownloadWrongHash():
return downloadWrongHash(_that);case DownloadFailed():
return downloadFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( FileWrongHash value)?  fileWrongHash,TResult? Function( DownloadWrongHash value)?  downloadWrongHash,TResult? Function( DownloadFailed value)?  downloadFailed,}){
final _that = this;
switch (_that) {
case FileWrongHash() when fileWrongHash != null:
return fileWrongHash(_that);case DownloadWrongHash() when downloadWrongHash != null:
return downloadWrongHash(_that);case DownloadFailed() when downloadFailed != null:
return downloadFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  fileWrongHash,TResult Function()?  downloadWrongHash,TResult Function( IOException e)?  downloadFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case FileWrongHash() when fileWrongHash != null:
return fileWrongHash();case DownloadWrongHash() when downloadWrongHash != null:
return downloadWrongHash();case DownloadFailed() when downloadFailed != null:
return downloadFailed(_that.e);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  fileWrongHash,required TResult Function()  downloadWrongHash,required TResult Function( IOException e)  downloadFailed,}) {final _that = this;
switch (_that) {
case FileWrongHash():
return fileWrongHash();case DownloadWrongHash():
return downloadWrongHash();case DownloadFailed():
return downloadFailed(_that.e);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  fileWrongHash,TResult? Function()?  downloadWrongHash,TResult? Function( IOException e)?  downloadFailed,}) {final _that = this;
switch (_that) {
case FileWrongHash() when fileWrongHash != null:
return fileWrongHash();case DownloadWrongHash() when downloadWrongHash != null:
return downloadWrongHash();case DownloadFailed() when downloadFailed != null:
return downloadFailed(_that.e);case _:
  return null;

}
}

}

/// @nodoc


class FileWrongHash implements GetJarError {
  const FileWrongHash();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is FileWrongHash);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'GetJarError.fileWrongHash()';
}


}




/// @nodoc


class DownloadWrongHash implements GetJarError {
  const DownloadWrongHash();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadWrongHash);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'GetJarError.downloadWrongHash()';
}


}




/// @nodoc


class DownloadFailed implements GetJarError {
  const DownloadFailed(this.e);
  

 final  IOException e;

/// Create a copy of GetJarError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DownloadFailedCopyWith<DownloadFailed> get copyWith => _$DownloadFailedCopyWithImpl<DownloadFailed>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is DownloadFailed&&(identical(other.e, e) || other.e == e));
}


@override
int get hashCode {
    return Object.hash(runtimeType,e);
}

@override
String toString() {
    return 'GetJarError.downloadFailed(e: $e)';
}


}

/// @nodoc
abstract mixin class $DownloadFailedCopyWith<$Res> implements $GetJarErrorCopyWith<$Res> {
  factory $DownloadFailedCopyWith(DownloadFailed value, $Res Function(DownloadFailed) _then) = _$DownloadFailedCopyWithImpl;
@useResult
$Res call({
 IOException e
});




}
/// @nodoc
class _$DownloadFailedCopyWithImpl<$Res>
    implements $DownloadFailedCopyWith<$Res> {
  _$DownloadFailedCopyWithImpl(this._self, this._then);

  final DownloadFailed _self;
  final $Res Function(DownloadFailed) _then;

/// Create a copy of GetJarError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? e = null,}) {
  return _then(DownloadFailed(
null == e ? _self.e : e // ignore: cast_nullable_to_non_nullable
as IOException,
  ));
}


}

// dart format on
