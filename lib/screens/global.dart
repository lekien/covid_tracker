import 'package:covid_live_tracker/screens/global_loading.dart';
import 'package:covid_live_tracker/screens/global_statistics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covid_live_tracker/services/covid_service.dart';
import 'package:covid_live_tracker/models/global_summary.dart';

CovidService covidService = CovidService();

class Global extends StatefulWidget{
  @override
  _GlobalState createState() => _GlobalState();
}

class _GlobalState extends State<Global> {
  Future<GlobalSummaryModel> summary;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    summary = covidService.getGlobalSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Global Corona Virus Cases",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14
                ),
              ),
              GestureDetector(
                onTap: (){
                  setState(() {
                    summary = covidService.getGlobalSummary();
                  });
                },
                child: Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
        FutureBuilder(
          future: summary,
          builder: (context, snapshot){
            if(snapshot.hasError){
              return Center(
                child: Text("Error"),
              );
            }
            switch(snapshot.connectionState){
              case ConnectionState.waiting:
                return GlobalLoading();
                break;
              default:
                return !snapshot.hasData
                    ? Center(child: Text("Empty"),)
                    : GlobalStatistics(summary: snapshot.data);
            }
          },
        )
      ],
    );
  }
}