import 'package:dartz/dartz.dart';
import 'package:plugoo/core/error/failures.dart';

/// Canonical return type for all use cases and repository methods.
/// Left = failure, Right = success value.
typedef ResultFuture<T> = Future<Either<Failure, T>>;
typedef ResultStream<T> = Stream<Either<Failure, T>>;
typedef DataMap = Map<String, dynamic>;
