import 'package:core/core.dart';

/// Defines common type aliases used throughout the application to improve
/// code readability and consistency, aligned with the modern [Result] system.

/// A type alias for a [Future] that returns a [Result].
///
/// This is the standard return type for asynchronous repository methods and
/// use cases that can either succeed with data of type [T] or fail with an [AppError].
///
/// Example:
/// `ResultFuture<User> fetchUser(String id);`
typedef ResultFuture<T> = Future<Result<T>>;

/// A type alias for a [Future] that returns a `Result<void>`.
///
/// This is used for asynchronous operations that do not return a value upon
/// success but may still fail, such as a delete or update operation.
///
/// Example:
/// `ResultVoid deleteItem(String id);`
typedef ResultVoid = ResultFuture<void>;

/// A standard type alias for a map representing a JSON object.
///
/// This is commonly used when decoding API responses or sending data in a
/// POST/PUT request.
typedef DataMap = Map<String, dynamic>;