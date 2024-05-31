import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:teachstudent/colors.dart';
import 'package:teachstudent/data/student.dart';
import 'package:teachstudent/extensions.dart';
import 'package:teachstudent/pages/LoadingPage.dart';
import 'package:teachstudent/strings.dart';

String? stringValidator(String? value) {
  if (value!=null && value.isNotEmpty) {
    return null;
  }
  return "Please enter a valid input";
}


class CloudFirestorePage extends StatefulWidget {
  CloudFirestorePage({Key? key}) : super(key: key);

  @override
  CloudFirestorePageState createState() {
    return new CloudFirestorePageState();
  }
}

class CloudFirestorePageState extends State<CloudFirestorePage> {
  CloudFirestorePageState(): super() {}

  // Authentication
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  // Data
  Student? student=Student.parse({}, null);
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController textEditingController =TextEditingController();
  int selectedPageIndex = 0;
  final formKey = GlobalKey<FormState>(debugLabel: 'updateForm');
  String? dob;

  addStudent() {
    if(formKey.currentState?.validate()==true){
      if(student!=null)
        firestore.collection(studentsKey).add(student!.json).then((value) {
          setState(() {
              selectedPageIndex=1;
            });
          dob=null;
        }
        );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(selectedPageIndex),
      resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text("TeachStudent",style: TextStyle(color: Colors.white),),
            backgroundColor: primaryColor,
          actions: [
            IconButton(onPressed: auth.signOut, icon: Icon(Icons.logout,color: Colors.white,))
          ],
        ),
        body:[
          GestureDetector(
            onTap:FocusScope.of(context).unfocus,
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Visibility(
                    visible: MediaQuery.of(context).viewInsets.bottom == 0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text('Add student details below',style: TextStyle(color: Colors.grey.shade600),),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                      ),
                      child: TextFormField(
                        style: TextStyle(decoration: TextDecoration.none),
                        decoration: const InputDecoration(
                          labelText: nameKey,
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        validator: stringValidator,
                        onChanged: (value) => student?.name=value.trim(),
                      )
                  ),
                  Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                      ),
                      child: TextFormField(
                        style: TextStyle(decoration: TextDecoration.none),
                        decoration: InputDecoration(
                          labelText: dobKey,
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(left: 14),
                            child: DatePickerSuffix(
                              onSelect: (d) => setState(() {
                                student?.dob=Timestamp.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
                                dob=student!.dob.toDateTime.formatDDMMYY;
                              }),
                            ),
                          ),
                          enabledBorder: InputBorder.none,
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        readOnly: true,
                        key: ValueKey(student?.dob.toString()),
                        controller: TextEditingController(text:student!=null?dob :null ),
                        validator: stringValidator,
                        // onSaved: (value) {
                        //   student?.dob = value??'';
                        // }
                      )
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                    ),
                    child: GenderDropdownField(
                        value:  student!=null&&student!.gender.isEmpty?null: student?.gender,
                        validator: stringValidator,
                        onChanged: ( value) {
                          setState(() {
                            student?.gender=value?.trim()??'';
                          });
                        }),
                  ),
                  Expanded(child: SizedBox(height: 10,)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Animate(
                        effects: [
                          FadeEffect(
                            duration: Duration(milliseconds: 1600),
                          )
                        ], child: TextButton(
                      onPressed:addStudent,
                      style: TextButton.styleFrom(
                        backgroundColor:  primaryColor.withAlpha(900),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),

                        ),
                      ),
                      child: Center(
                        child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Click on student detail to update',style: TextStyle(color: Colors.grey.shade600),),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String,dynamic>>>(
                  stream:  firestore.collection(studentsKey).snapshots(),
                  builder: (context, snapshot) {
                    // print(snapshot.connectionState);
                    if(snapshot.connectionState==ConnectionState.waiting)
                      return LoadingPage();
                    if(snapshot.hasData&&snapshot.data!=null&&snapshot.data!.docs.isNotEmpty) {
                     List<Student>  list=snapshot.data!.docs.map((e) => Student.parse(e.data(),e.reference)).toList();
                      list.sort((a, b) => a.name.toLowerCase().characters.first.compareTo(b.name.toLowerCase().characters.first),);
                      return ListView.builder(
                        key: ObjectKey(list),
                        itemBuilder: (context, index) {
                          // final ref = snapshot.data!.docs[index].reference;
                          // Map<String, dynamic> data =
                          //     snapshot.data!.docs[index].data();
                          return Card.outlined(
                            key: ObjectKey(list[index]),
                            shadowColor: primaryColor.withAlpha(100),
                            elevation: 0.1,
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 15),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                          visualDensity: VisualDensity(
                                              vertical: -3, horizontal: -3),
                                          splashRadius: 8,
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            await Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                  appBar: AppBar(
                                                    automaticallyImplyLeading:
                                                        true,
                                                  ),
                                                  resizeToAvoidBottomInset:
                                                      false,
                                                  body: StudentForm(
                                                    student: list[index],
                                                  )),
                                            ));
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            size: 15,
                                            color: primaryColor,
                                          ))
                                    ],
                                  ),
                                  TextFormField(
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      labelText: nameKey,
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    initialValue: list[index].name,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: dobKey,
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    initialValue:list[index].dob.toDateTime.formatDDMMYY,
                                  ),
                                  TextFormField(
                                    decoration: InputDecoration(
                                      labelText: genderKey,
                                      labelStyle:
                                          TextStyle(color: primaryColor),
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                    readOnly: true,
                                    initialValue: list[index].gender,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: list.length,
                      );
                    }
                    return Center(
                      child: Text('No data available to show'),
                    );
                  }
                        ),
              ),
            ],
          ),
        ][selectedPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.plus_one),
              label: 'Add data',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'View data',
          ),
        ],
        currentIndex: selectedPageIndex,
        selectedItemColor: primaryColor.withAlpha(200),
        onTap: (value) => setState(() {
          selectedPageIndex=value;
          if(value==1) student=null;
          else student=Student.parse({}, null);
        }),
      ),
    );
  }

  void textContollerSetter(value) => textEditingController.text=value;

  Future<dynamic> showConfirmationDialog(BuildContext context) {
    return showAdaptiveDialog(
      context: context,
      builder: (context) => Scaffold(
          backgroundColor:Colors.transparent,
          body: Center(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Are you sure you want to proceed with editing this student data?'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => Navigator.pop(context,true),
                            child: Text('Yes'),
                        ),
                        TextButton(
                            onPressed: () => Navigator.pop(context,false),
                            child: Text('Cancel'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}

class DatePickerSuffix extends StatelessWidget {
  const DatePickerSuffix({super.key, required this.onSelect});
  final void Function(DateTime) onSelect;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:() async => await showDatePicker(
        context: context,
        firstDate: DateTime.now().subtract(Duration(days:365*90)),
        lastDate: DateTime.now().subtract(Duration(days:365*18)),
      ).then((value) {
        print(value);
        if(value!=null)
         onSelect(value);
      }
      ),
      child: Icon(
        Icons.date_range,
      ),
    );
  }
}

class GenderDropdownField extends StatelessWidget {
  const GenderDropdownField({super.key, this.onChanged, this.validator, this.value});
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      items:List.generate(
        genders.length,
            (index) => DropdownMenuItem(
          child: Text(genders[index]),
          value: genders[index],
        ),
      ),
      decoration: InputDecoration(
        labelText: genderKey,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        border: InputBorder.none,
      ),
      // initialValue: genderKey,
      onChanged: onChanged,
      validator:validator,
    );
  }
}

class CheckSuffix extends StatelessWidget {
  const CheckSuffix({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onTap, icon: Icon(Icons.check));
  }
}

class StudentForm extends StatefulWidget {
  const StudentForm({super.key, this.student, this.onTapDate});
  final Student? student;
  final VoidCallback? onTapDate;

  @override
  State<StudentForm> createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final formKey = GlobalKey<FormState>(debugLabel: 'updateForm');
  Student? student;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  updateStudent() async {
    if(formKey.currentState?.validate()==true){
      if(student!=null)
        try{
          await widget.student?.ref?.update(student!.json);
          Navigator.pop(context);
        }
        catch (e){
          print(e);
        }
    }

  }

  @override
  void initState() {
    student=widget.student;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          Visibility(
            visible: MediaQuery.of(context).viewInsets.bottom == 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Add student details below',style: TextStyle(color: Colors.grey.shade600),),
            ),
          ),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))
              ),
              child: TextFormField(
                initialValue: student?.name,
                style: TextStyle(decoration: TextDecoration.none),
                decoration: const InputDecoration(
                  labelText: nameKey,
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                validator: stringValidator,
                onChanged: (value) => student?.name=value,
              )
          ),
          Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200))
              ),
              child: TextFormField(
                style: TextStyle(decoration: TextDecoration.none),
                initialValue: student?.dob.toDateTime.formatDDMMYY,
                decoration: InputDecoration(
                  labelText: dobKey,
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: DatePickerSuffix(
                      onSelect: (d) => setState(() {
                      student?.dob=Timestamp.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch);
                        // dob= student?.dob.toDateTime.formatDDMMYY;
                      }),
                    ),
                  ),
                  enabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                readOnly: true,
                key: ValueKey(student?.dob.toString()),
                validator: stringValidator,
                // onSaved: (value) {
                //   student?.dob = value??'';
                // }
              )
          ),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200))
            ),
            child: GenderDropdownField(
                value:  student?.gender,
                validator: stringValidator,
                onChanged: ( value) {
                  setState(() {
                   student?.gender=value??'';
                  });
                }),
          ),
          Expanded(child: SizedBox(height: 10,)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
            child: Animate(
                effects: [
                  FadeEffect(
                    duration: Duration(milliseconds: 1600),
                  )
                ], child: TextButton(
              onPressed:updateStudent,
              style: TextButton.styleFrom(
                backgroundColor:  primaryColor.withAlpha(900),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),

                ),
              ),
              child: Center(
                child: Text("Submit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
