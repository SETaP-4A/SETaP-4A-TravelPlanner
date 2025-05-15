import '../models/user.dart';
import '../models/itinerary.dart';
import '../models/flight.dart';
import '../models/accommodation.dart';
import '../models/activity.dart';

abstract class DatabaseInterface {
  Future<int> insertUser(User user);
  Future<int> insertItinerary(Itinerary itinerary);
  Future<int> updateItinerary(Itinerary itinerary);
  Future<int> deleteItinerary(Itinerary itinerary);
  Future<int> insertFlight(Flight flight);
  Future<int> insertAccommodation(Accommodation accommodation);
  Future<int> insertActivity(Activity activity);
}
