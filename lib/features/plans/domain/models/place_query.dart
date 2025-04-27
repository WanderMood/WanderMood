import 'package:wandermood/features/plans/domain/enums/time_slot.dart';

class PlaceQuery {
  final String searchQuery;
  final String placeType;
  final TimeSlot timeSlot;
  final String query;

  PlaceQuery(this.searchQuery, this.placeType, this.timeSlot)
      : query = searchQuery; // Initialize query with searchQuery
} 