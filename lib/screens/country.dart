import 'package:covid_live_tracker/models/country_summary.dart';
import 'package:covid_live_tracker/models/country.dart';
import 'package:covid_live_tracker/screens/country_loading.dart';
import 'package:covid_live_tracker/screens/country_statistics.dart';
import 'package:covid_live_tracker/services/covid_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

CovidService covidService = CovidService();
class Country extends StatefulWidget{
  @override
  _CountryState createState() => _CountryState();
}

class _CountryState extends State<Country> {
  Future<List<CountrySummaryModel>> summaryList;
  final TextEditingController _typeAheadController = TextEditingController();
  Future<List<CountryModel>> countryList;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    countryList = covidService.getCountryList();
    summaryList = covidService.getCountrySummary("united-states");
    this._typeAheadController.text = "United States of America";
  }

  List<String> _getSuggestions(List<CountryModel> list, String query){
    List<String> matches = List();
    for(var item in list){
      matches.add(item.country);
    }

    matches.retainWhere((element) => element.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: countryList,
      builder: (context, snapshot){
        if(snapshot.hasError){
          return Center(
            child: Text("Error"),
          );
        }
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
            return Center(
              child: CountryLoading(inputTextLoading: true,),
            );
            break;
          default:
            return !snapshot.hasData
              ? Center(child: Text("Empty"),)
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: Text(
                      "Type the country name",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                  ),
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      controller: _typeAheadController,
                      decoration: InputDecoration(
                        hintText: "Type here the country name",
                        hintStyle: TextStyle(fontSize: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none
                          )
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.all(20),
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(left: 24, right: 16),
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 28,
                          ),
                        )
                      )
                    ),
                    suggestionsCallback: (pattern){
                      return _getSuggestions(snapshot.data, pattern);
                    },
                    itemBuilder: (context, suggestion){
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: (context, suggestionBox, controller){
                      return suggestionBox;
                    },
                    onSuggestionSelected: (suggestion){
                      this._typeAheadController.text = suggestion;
                      setState(() {
                        summaryList = covidService.getCountrySummary(snapshot.data.firstWhere((element) => element.country == suggestion).slug);
                      });
                    },
                  ),
                  SizedBox(height: 8,),
                  FutureBuilder(
                    future: summaryList,
                    builder: (context, snapshot){
                      if(snapshot.hasError){
                        return Center(
                          child: Text("Error"),
                        );
                      }
                      switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                          return Center(
                            child: CountryLoading(inputTextLoading: false,),
                          );
                          break;
                        default:
                          return !snapshot.hasData
                              ? Center(child: Text("Empty"),)
                              : CountryStatistics(summaryList: snapshot.data);
                      }
                    },
                  )
                ],
            );;
        }
      },
    );
  }
}