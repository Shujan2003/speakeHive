import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyComplaints extends StatelessWidget {
  const MyComplaints({super.key});

  String formatDate(Timestamp timestamp)
  {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Complaints",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
     body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore
        .instance.collection('complaints')
        .where('userId',isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .orderBy('timestamp',descending: true)
        .snapshots(),
        builder: (context,snapshot)
        {
          if (snapshot.hasError) {
  print("Firestore error: ${snapshot.error}");
  return Center(child: Text("Something went wrong!\n${snapshot.error}"));
}

          if(snapshot.connectionState==ConnectionState.waiting)
          {
            return Center(child: CircularProgressIndicator());
          }
          final complaits = snapshot.data!.docs;
          if(complaits.isEmpty)
          {
            return Center(child: Text("No complaints submitted yet"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(15),
            itemCount: complaits.length,
            itemBuilder: (context,index)
            {
              final data=complaits[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical:8),
                child: ListTile(
                  title: Text(data['title']
                  ,style:TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['description']),
                      SizedBox(height: 5,),
                      Text("Category:${data['category']}"),
                      
                      Text("Submitted:${formatDate(data['timestamp'])}"),
                       Text(
                              data['anonymous'] == true ? "Submitted by: Anonymous" : "Submitted by: You",
                              style: TextStyle(fontStyle: FontStyle.italic),
                             ),
                    ],
                  ),
                  trailing: Chip(
                    label: Text(data['status'],
                    style: TextStyle(color: Colors.white),),
                    backgroundColor: data['status']=='Resolved'?Colors.green
                    :data['status']=='Rejected'?Colors.red
                    : Colors.orange,
                    ),
                ),
              );
            });
        },

      ),
    );
  }
}