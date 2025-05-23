// Mocks generated by Mockito 5.4.6 from annotations
// in setap4a/test/db_helper_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:mockito/mockito.dart' as _i1;
import 'package:setap4a/db/database_interface.dart' as _i2;
import 'package:setap4a/models/accommodation.dart' as _i7;
import 'package:setap4a/models/activity.dart' as _i8;
import 'package:setap4a/models/flight.dart' as _i6;
import 'package:setap4a/models/itinerary.dart' as _i5;
import 'package:setap4a/models/user.dart' as _i4;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [DatabaseInterface].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseInterface extends _i1.Mock implements _i2.DatabaseInterface {
  MockDatabaseInterface() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Future<int> insertUser(_i4.User? user) => (super.noSuchMethod(
        Invocation.method(
          #insertUser,
          [user],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> insertItinerary(_i5.Itinerary? itinerary) =>
      (super.noSuchMethod(
        Invocation.method(
          #insertItinerary,
          [itinerary],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> updateItinerary(_i5.Itinerary? itinerary) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateItinerary,
          [itinerary],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> deleteItinerary(_i5.Itinerary? itinerary) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteItinerary,
          [itinerary],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> insertFlight(_i6.Flight? flight) => (super.noSuchMethod(
        Invocation.method(
          #insertFlight,
          [flight],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> insertAccommodation(_i7.Accommodation? accommodation) =>
      (super.noSuchMethod(
        Invocation.method(
          #insertAccommodation,
          [accommodation],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);

  @override
  _i3.Future<int> insertActivity(_i8.Activity? activity) => (super.noSuchMethod(
        Invocation.method(
          #insertActivity,
          [activity],
        ),
        returnValue: _i3.Future<int>.value(0),
      ) as _i3.Future<int>);
}
