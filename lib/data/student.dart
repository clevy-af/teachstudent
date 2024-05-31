import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teachstudent/strings.dart';

class Student{
  String name;
  DocumentReference? ref;
  String gender;
  Timestamp dob;
  Student({required this.name,required this.dob,required this.gender, this.ref});
  Student.parse(Map<String,dynamic> data,DocumentReference? refID):name=data[nameKey]??'',
        gender=data[genderKey]??'',
        dob=data[dobKey]??Timestamp.now(),
        ref=refID;

  Map<String, dynamic> get json => {
    nameKey:name,
    dobKey:dob,
    genderKey:gender,
  };

  @override
  // TODO: implement hashCode
  int get hashCode => json.hashCode;

  @override
  String toString() =>
    json.toString();

}