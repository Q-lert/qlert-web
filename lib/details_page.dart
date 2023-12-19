import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {

  final String reportId;

  const DetailsPage({super.key, required this.reportId});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {

  @override
  void initState() {

    super.initState();
  }

  void getLocation(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    print(placemarks);
    if(placemarks.isEmpty){
      address = "";
      return;
    }
    setState(() {
      address = placemarks[0].name!;
    });
  }

  String address = "Loading...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 400,
          child: Center(
            child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('reports')
                  .doc(widget.reportId)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loader while fetching data
                } else {
                  if (snapshot.hasError) {
                    print(snapshot.stackTrace);
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.hasData && snapshot.data!.exists) {
                      var reportData = snapshot.data!.data(); // Get the document data

                      GeoPoint location = reportData!['location'];

                      getLocation(location.latitude, location.longitude);

                      // Use the data retrieved from Firestore
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Report ID: ${snapshot.data!.id}'),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Date", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    Text(DateFormat.yMMMMEEEEd().format((reportData['time'] as Timestamp).toDate())),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Time", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                                    Text('Time: ${DateFormat.jm().format((reportData['time'] as Timestamp).toDate())}'),
                                  ],
                                )
                              ],
                            ),
                          ),
                          // Text('Reported at: $address'),
                          SizedBox(
                            height: 400,
                            width: 400,
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(location.latitude, location.longitude),
                                initialZoom: 15,

                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.example.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(point: LatLng(location.latitude, location.longitude), child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(50), color: Colors.white), child: Icon(Icons.car_crash_sharp, color: Colors.red.shade900,)))
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                          GestureDetector(
                            onTap: (){
                              launchUrl(Uri.parse('https://www.google.com/maps/@${location.latitude},${location.longitude},15z'));
                            },
                            child: Container(
                              width: 180,
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25.0),
                                border: Border.all(color: Colors.grey, width: 1),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Open in maps"),
                                  SizedBox(width: 5,),
                                  Icon(Icons.map)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20,),
                          const Text("Images",textAlign: TextAlign.start , style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.network(reportData['images'][0], width: 150,),
                              Image.network(reportData['images'][1], width: 150,),
                            ],
                          )
                        ],
                      );
                    } else {
                      return const Text('Document does not exist');
                    }
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}