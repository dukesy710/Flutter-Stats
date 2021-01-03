import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stats/models/data_view_model.dart';
import 'package:flutter_stats/services/backend_service.dart';
import 'package:flutter_stats/services/utilities_service.dart';

class StatsScreen extends StatefulWidget {
  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final BackendService backendService = BackendService();
  final DataViewModel dataViewModel = DataViewModel();
  bool _loading = false;
  bool _dataIsSet = false;

  @override
  void initState() {
    super.initState();
    // set starting data model values
    dataViewModel.initialize();
    // check if data already exists
    checkIfDataExists();
  }

  void checkIfDataExists() {
    backendService.checkifDataExists().then((value) {
      setState(() {
        _dataIsSet = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Stats App',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              height: 50,
              child: chartKeys(),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: chart(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selectDateRanges(),
    );
  }

  Widget chartKeys() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Chip(
          padding: const EdgeInsets.all(7),
          label: Text('sent', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFFFDA06F),
        ),
        Chip(
          padding: const EdgeInsets.all(7),
          label: Text('received', style: TextStyle(color: Colors.white)),
          backgroundColor: Color(0xFF6B37C1),
        ),
      ],
    );
  }

  Widget chart() {
    return StreamBuilder(
      stream: backendService.dataStreamQuery(
          dataViewModel.startDayId, dataViewModel.endDayId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!_dataIsSet) {
          return generateData();
        }

        if (snapshot.hasData && !snapshot.hasError) {
          return Container(
            padding: const EdgeInsets.fromLTRB(0, 20, 20, 5),
            child: barChart(snapshot.data.documents),
          );
        }

        return Center(child: Text('There seems to be an error.'));
      },
    );
  }

  Widget barChart(List<QueryDocumentSnapshot> documents) {
    return BarChart(
      BarChartData(
        barGroups: documents
            .asMap()
            .map((index, data) => MapEntry(
                  data.data()['dayId'],
                  BarChartGroupData(
                    x: data.data()['dayId'],
                    barRods: [
                      BarChartRodData(
                        y: data.data()['sent'].toDouble(),
                        colors: [Color(0xFFFDA06F)],
                      ),
                      BarChartRodData(
                        y: data.data()['received'].toDouble(),
                        colors: [Color(0xFF6B37C1)],
                      ),
                    ],
                  ),
                ))
            .values
            .toList(),
        barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.blueGrey[50],
            )),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            getTitles: (double val) => UtilitiesService.getDayFromEpoch(val).toString(),
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: 10,
          ),
        ),
        gridData: FlGridData(
          show: true,
        ),
      ),
    );
  }

  Widget selectDateRanges() {
    return Container(
      height: 80,
      color: Theme.of(context).primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                dataViewModel.updateDataDateTime(true);
              });
            },
          ),
          Text(
            dataViewModel.datePeriodText,
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                dataViewModel.updateDataDateTime(false);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget generateData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _loading ? 'Generating data...' : 'Generate some data',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
        SizedBox(height: 20),
        _loading
            ? CircularProgressIndicator(
                backgroundColor: Colors.white,
              )
            : FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                onPressed: () async {
                  setState(() {
                    _loading = true;
                  });
                  await backendService.generateDataAggregations();
                  setState(() {
                    _dataIsSet = true;
                    _loading = false;
                  });
                },
                child: Icon(
                  Icons.add_outlined,
                  size: 30,
                ),
              )
      ],
    );
  }
}
