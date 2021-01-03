import 'package:flutter_stats/services/utilities_service.dart';

class DataViewModel {
  DateTime dataDateTime;
  String datePeriodText;
  int startDayId, endDayId;

  initialize() {
    // get the date time to the current date time and set the starting day ids
    dataDateTime = DateTime.now();
    setDayIds();
  }

  setDayIds() {
    datePeriodText = UtilitiesService.getUserFriendlyWeekId(dataDateTime);
    startDayId = UtilitiesService.getStartOfWeekDayId(dataDateTime);
    endDayId = UtilitiesService.getEndOfWeekDayId(dataDateTime);
  }

  // update selected date time
  updateDataDateTime(bool previousDate) {
    if (previousDate) {
      dataDateTime = dataDateTime.subtract(Duration(days: 7));
      setDayIds();
    } else {
      dataDateTime = dataDateTime.add(Duration(days: 7));
      setDayIds();
    }
  }
}
