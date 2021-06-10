import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

List<PieChartSectionData> getSections(pillars) {
  final pillarsLength = pillars.length;
  var invalidLength = 0;
  var validLength = 0;
  pillars.forEach((item) =>
      {if (item['status'] == 'invalid') invalidLength++ else validLength++});

  final invalidPercent = (invalidLength / pillarsLength) * 100;
  final validPercent = (validLength / pillarsLength) * 100;

  List<Data> data = [
    Data(percent: invalidLength.toDouble(), color: Colors.red),
    Data(percent: validLength.toDouble(), color: Colors.green),
  ];

  return data
      .asMap()
      .map<int, PieChartSectionData>((idx, data) {
        final value = PieChartSectionData(
            color: data.color,
            value: data.percent,
            radius: 15,
            showTitle: false);
        return MapEntry(idx, value);
      })
      .values
      .toList();
}

List<PieChartSectionData> getSectionsMore(pillars) {
  final pillarsLength = pillars.length;
  var invalidLength = 0;
  var validLength = 0;
  pillars.forEach((item) =>
      {if (item['status'] == 'invalid') invalidLength++ else validLength++});

  final invalidPercent = (invalidLength / pillarsLength) * 100;
  final validPercent = (validLength / pillarsLength) * 100;

  List<Data> data = [
    Data(percent: invalidLength.toDouble(), color: Colors.red),
    Data(percent: validLength.toDouble(), color: Colors.green),
  ];

  return data
      .asMap()
      .map<int, PieChartSectionData>((idx, data) {
        final value = PieChartSectionData(
            color: data.color,
            value: data.percent,
            radius: 30,
            showTitle: false);
        return MapEntry(idx, value);
      })
      .values
      .toList();
}

class Data {
  final double percent;
  final Color color;

  Data({required this.percent, required this.color});
}
