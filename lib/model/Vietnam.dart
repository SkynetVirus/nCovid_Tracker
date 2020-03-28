import 'package:flutter/foundation.dart';

import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
class Vietnam with ChangeNotifier{
  bool _success;
  Data _data;

  
  Vietnam({bool success, Data data}) {
    this._success = success;
    this._data = data;
  }
  
  bool get success => _success;
  set success(bool success) => _success = success;
  Data get data => _data;
  set data(Data data){
    _data = data;
    notifyListeners();
  }
  
  Vietnam.fromJson(Map<String, dynamic> json) {
    _success = json['success'];
    _data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this._success;
    if (this._data != null) {
      data['data'] = this._data.toJson();
    }
    return data;
  }
}

class Data {
  Global _global;
  Global _vietnam;

  Data({Global global, Global vietnam}) {
    this._global = global;
    this._vietnam = vietnam;
  }

  Global get global => _global;
  set global(Global global) => _global = global;
  Global get vietnam => _vietnam;
  set vietnam(Global vietnam) => _vietnam = vietnam;

  Data.fromJson(Map<String, dynamic> json) {
    _global =
        json['global'] != null ? new Global.fromJson(json['global']) : null;
    _vietnam =
        json['vietnam'] != null ? new Global.fromJson(json['vietnam']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._global != null) {
      data['global'] = this._global.toJson();
    }
    if (this._vietnam != null) {
      data['vietnam'] = this._vietnam.toJson();
    }
    return data;
  }
}

class Global {
  String _cases;
  String _deaths;
  String _recovered;

  Global({String cases, String deaths, String recovered}) {
    this._cases = cases;
    this._deaths = deaths;
    this._recovered = recovered;
  }

  String get cases => _cases;
  set cases(String cases) => _cases = cases;
  String get deaths => _deaths;
  set deaths(String deaths) => _deaths = deaths;
  String get recovered => _recovered;
  set recovered(String recovered) => _recovered = recovered;

  Global.fromJson(Map<String, dynamic> json) {
    _cases = json['cases'];
    _deaths = json['deaths'];
    _recovered = json['recovered'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cases'] = this._cases;
    data['deaths'] = this._deaths;
    data['recovered'] = this._recovered;
    return data;
  }
}
