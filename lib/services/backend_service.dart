import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_stats/services/utilities_service.dart';
import 'dart:math';

class BackendService {
  final dbReference = FirebaseFirestore.instance;

  Future<bool> checkifDataExists() async {
    DocumentSnapshot dataIsSet =
        await dbReference.collection('aggregations').doc('data-is-set').get();

    return dataIsSet.exists;
  }

  // function to generate some mock data
  generateDataAggregations() async {
    try {
      // will set data using a batch write
      WriteBatch batchWrite = dbReference.batch();

      // generate random aggregation counts over the last 365 days
      DateTime aggregationDate = DateTime.now();
      int maxDailyCount = 300;
      for (int i = 0; i < 365; i++) {
        int dayId = UtilitiesService.getDayId(aggregationDate);
        int sentCount = Random().nextInt(maxDailyCount);
        int receivedCount = Random().nextInt(maxDailyCount);

        // save data
        DocumentReference docRef =
            dbReference.collection('aggregations').doc(dayId.toString());
        batchWrite
            .set(docRef, {'sent': sentCount, 'received': receivedCount, 'dayId': dayId});

        // go back a day
        aggregationDate = aggregationDate.subtract(Duration(days: 1));
      }

      // set that the data exists
      batchWrite.set(dbReference.collection('aggregations').doc('data-is-set'), {});

      // commit the batch write
      await batchWrite.commit();
      print('Succesfully generated data aggregations');
    } catch (e) {
      print('Failed to generate mock data: ' + e.message);
    }
  }

  getDocumentSnapshot(String docId) async {
    return await dbReference.collection('aggregations').doc('$docId').get();
  }

  // return data stream
  Stream dataStreamQuery(int startDayId, int endDayId) {
    return dbReference
        .collection('aggregations')
        .orderBy('dayId')
        .where('dayId', isGreaterThanOrEqualTo: startDayId)
        .where('dayId', isLessThanOrEqualTo: endDayId)
        .snapshots();
  }
}
