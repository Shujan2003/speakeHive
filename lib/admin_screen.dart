import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  String formatDate(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }
  void logout(BuildContext context)async{

    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/auth');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Signed out"))
    );

  }

  Future<void> markAsResolved(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docId)
          .update({'status': 'Resolved'});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint marked as resolved")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
  Future<void>markAsRejected(BuildContext context,String docId)async{
    try{
      await FirebaseFirestore.instance
      .collection('complaints')
      .doc(docId)
      .update({'status':'Rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Complaint rejected")),
        );

    }catch(e)
    {
        ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(content: Text("Error:$e")),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 207, 184, 154),
      appBar: AppBar(
        title: const Text("Admin - All Complaints"
        ,style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        actions: [
          IconButton(onPressed: ()=>logout(context), icon: Icon(
            Icons.logout_rounded,color: Colors.white,),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final complaints = snapshot.data!.docs;

          if (complaints.isEmpty) {
            return const Center(child: Text("No complaints found"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              final data = complaints[index];
              final Map<String, dynamic> complaintData =
                  data.data() as Map<String, dynamic>;
              final isAnonymous = complaintData['anonymous'] ?? true;

              final submitter = isAnonymous
                  ? "Anonymous"
                  : (complaintData.containsKey('userName')
                  ? complaintData['userName'] ?? 'Unknown'
                  : 'Unknown');


              final docId = data.id;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complaintData['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(complaintData['description']),
                      const SizedBox(height: 8),
                      Text("Category: ${complaintData['category']}"),
                      Text("Submitted by: $submitter"),
                      Text("Submitted: ${formatDate(complaintData['timestamp'])}"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              complaintData['status'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor:
                                complaintData['status'] == 'Resolved'
                                    ? Colors.green
                                    :complaintData['status']=='Rejected'?
                                    Colors.red
                                    : Colors.orange,
                          ),
                          if (complaintData['status'] != 'Resolved' &&
                           complaintData['status'] != 'Rejected')
                           Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                                 children: [
                                   TextButton(
                                    onPressed: () => markAsResolved(context, docId),
                                    child: const Text("Mark Resolved"),
                                             ),
                                   TextButton(
                                 onPressed: () => markAsRejected(context, docId),
                                 child: const Text("Reject", style: TextStyle(color: Colors.red)),
                                             ),
                                           ],
                              ),

                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
