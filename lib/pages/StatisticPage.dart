import 'package:anglesensor/pages/MeasuringPage.dart';
import 'package:anglesensor/widget/pie_chart_sections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatisticPage extends StatelessWidget {
  final item;
  int invalidLength = 0;
  int validLength = 0;

  StatisticPage({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    item['pillars'].forEach((item) =>
        {if (item['status'] == 'invalid') invalidLength++ else validLength++});

    Timestamp timestamp = item['createdAt'];
    String formattedDate =
        DateFormat('dd.MM.yyyy в kk:mm').format(timestamp.toDate());
    return Scaffold(
      backgroundColor: Color(0xFFF3F3F3),
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          ),
          title: Text(
            item['title'],
            style: GoogleFonts.cuprum(
              textStyle: TextStyle(color: Colors.black87),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red,
              ),
            ),
          ]),
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 5),
                    blurRadius: 15,
                    color: Colors.black.withOpacity(0.07),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.view_week_rounded,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Опор: ${item['pillars']!.length}',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 15),
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    child: Hero(
                      tag: item['title'],
                      child: PieChart(
                        PieChartData(
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 5,
                          sections: getSectionsMore(item['pillars']),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text('Исправных: ${validLength}'),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text('Неисправных: ${invalidLength}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, -5),
                      blurRadius: 15,
                      color: Colors.black.withOpacity(0.07),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                  child: ListView.builder(
                    itemCount: item['pillars']!.length,
                    itemBuilder: (context, int index) {
                      return MeasuringItem(
                        x: item['pillars']![index]['x'],
                        y: item['pillars']![index]['y'],
                        status: item['pillars']![index]['status'],
                        index: index,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
