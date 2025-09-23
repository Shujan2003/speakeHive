import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubmitComplaintScreen extends StatefulWidget {
  const SubmitComplaintScreen({super.key});

  @override
  State<SubmitComplaintScreen> createState() => _SubmitComplaintScreenState();
}

class _SubmitComplaintScreenState extends State<SubmitComplaintScreen> {
  final formkey=GlobalKey<FormState>();

  String title="";
  String description="";
  String category="Hostel";
  String name = "";
  bool isAnonymous=false;

  final List<String> categories=['Hostel','Mess','Academics','Transport','Other'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  const Color.fromARGB(255, 207, 184, 154),
      appBar: AppBar(
        title: Text("Submit complaints",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        
        
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Form(
            key: formkey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Title",style: TextStyle(
                fontWeight: FontWeight.bold,color: Colors.black),),
              SizedBox(height: 10,),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter your complaint title',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 3)
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent,width: 3)
                  ),
                ),
                validator: (value) => value!.isEmpty?'Title is required':null,
                onSaved: (value) =>title=value!,
              ),
              SizedBox(height: 15,),
              Text("Description",style:TextStyle(
                fontWeight: FontWeight.bold,color: Colors.black) ,
              
              ),
              SizedBox(height: 10,),
              TextFormField(
                maxLines: 5,
                
                decoration: InputDecoration(
                  hintText: 'Describe your issues in detail',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white,width: 3),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent,width: 3)
                  )
                ),
                validator: (value) => value!.isEmpty?'Description is required':null,
                onSaved: (value) => description=value!,
              ),
              SizedBox(height: 20,),
              Text("Category",style: TextStyle(
                fontWeight: FontWeight.bold,color: Colors.black),),
              SizedBox(height: 10,),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white)
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent,width: 3)
                  )
                  ),
                  value:category,
                items: categories.map((cat)
                {
                  return DropdownMenuItem(value:cat,child: Text(cat));
                }).toList(),
                 onChanged: (value)=>setState(() {
                   category=value!;
                 })
                 ),
                 SizedBox(height: 20,),
                 CheckboxListTile(value: isAnonymous, 
                 
                 onChanged: (value)=> setState(() {
                   isAnonymous=value!;
                 }),
                 title: Text("Submit Anonymously", 
                 style: TextStyle(color: Colors.black)),
                 
                 ),
                 
                 SizedBox(height: 20,),
                 if(!isAnonymous)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Your Name", style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 10),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Enter your name',
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!isAnonymous && value!.isEmpty) {
                            return 'Name is required if not anonymous';
                          }
                          return null;
                        },
                        onSaved: (value) => name = value!,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),

                 Center(
                  child: ElevatedButton(
                    onPressed: ()async{
                      if(formkey.currentState!.validate())
                      {
                        formkey.currentState!.save();
                          try{
                            final currentUser = FirebaseAuth.instance.currentUser;
                            final Map<String,dynamic>complaintData = {
                            'title': title,
                            'description': description,
                            'category': category,
                            'anonymous': isAnonymous,
                            'timestamp': Timestamp.now(),
                            'status': 'Pending',
                            'userId': currentUser!.uid,
                          };

                          if (!isAnonymous) {
                            complaintData['userEmail'] = currentUser.email;
                            complaintData['userName'] = name;
                          }
                            await FirebaseFirestore.instance.collection('complaints')
                            .add(complaintData);


                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: 
                          Text("Complaint submitted")));

                        Navigator.pop(context);
                          }catch(e)
                          {
                            print("firbase error:$e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to submit complaint:$e")));
                          }
                            
                      }

                    }, 
                    style: ElevatedButton.styleFrom(
                      maximumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurple
                    ),
                    child: Text("Submit",
                    style: TextStyle(color: Colors.white),)))

            ],
          )),
        ),
      ),
    );
  }
}
