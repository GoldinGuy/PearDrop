import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:peardrop/src/utilities/file_select.dart';
import 'package:peardrop/src/utilities/nearby_device.dart';
import 'package:peardrop/src/widgets/linear_progress_indicator.dart';
import 'package:peardrop/src/widgets/progress_indicator.dart';

import '../home.dart';
import '../home.dart';

typedef void FileReceiveCallBack();
typedef void ResetCallBack();
typedef void CancelCallBack();
// typedef void SetPearPanelCallback(bool isOpen, PearPanel panel);
typedef void SetPearPanelCallback(bool isOpen);

class SlidingPanel extends StatelessWidget {
  SlidingPanel(
      {this.peerDevice,
      this.sc,
      this.filePath,
      // this.pearPanel,
      this.setPearPanel,
      this.accept,
      this.cancel,
      this.reset});

  final String filePath;
  final Device peerDevice;
  final ScrollController sc;
  final FileReceiveCallBack accept;
  // final PearPanel pearPanel;
  final ResetCallBack reset;
  final CancelCallBack cancel;
  final SetPearPanelCallback setPearPanel;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          controller: sc,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'bob',

                    // peerDevice.getName() + ' would like to share',
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                        color: Colors.grey[50],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                              child: Icon(
                                Icons.description,
                                size: 20,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[200],
                              ),
                              padding: EdgeInsets.all(10),
                              margin: EdgeInsets.fromLTRB(15, 5, 15, 16),
                              child: Text(FileSelect().nameFromPath(filePath),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Color(0xff559364),
                                  )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
                        child: GestureDetector(
                          onTap: () {
                            // setPearPanel(false, PearPanel.receiving);
                            setPearPanel(false);
                            accept();
                          },
                          child: Container(
                            width: 80,
                            height: 45,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xff91c27d),
                                  Color(0xff559364),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(5, 5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Accept',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
              ],
            ),
          ],
        ));
    // if (pearPanel == PearPanel.sharing) {
    //   return MediaQuery.removePadding(
    //       context: context,
    //       removeTop: true,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.grey[200],
    //           borderRadius: const BorderRadius.only(
    //               topLeft: Radius.circular(20.0),
    //               topRight: Radius.circular(20.0)),
    //           boxShadow: <BoxShadow>[
    //             BoxShadow(
    //               color: Colors.black12,
    //               blurRadius: 4.0,
    //               offset: const Offset(0.0, 4.0),
    //             ),
    //           ],
    //         ),
    //         child: ListView(
    //           controller: sc,
    //           children: <Widget>[
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 CloseButton(
    //                     color: Colors.black,
    //                     onPressed: () {
    //                       setPearPanel(false, PearPanel.sharing);
    //                       cancel();
    //                     })
    //               ],
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(left: 20, top: 0, bottom: 3),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: <Widget>[
    //                   Text(
    //                     "File Sharing",
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.w600,
    //                       fontSize: 19.0,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(left: 20, top: 3, bottom: 15),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: <Widget>[
    //                   Padding(
    //                     padding: EdgeInsets.only(right: 5),
    //                     child: Icon(
    //                       Icons.description,
    //                       size: 20,
    //                     ),
    //                   ),
    //                   Text(
    //                     filePath,
    //                     overflow: TextOverflow.ellipsis,
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 15.0,
    //                       color: Color(0xff559364),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Padding(
    //               padding:
    //                   EdgeInsets.only(bottom: 20, top: 15, left: 15, right: 15),
    //               child: PercentageProgressIndicator(),
    //             ),
    //             Container(
    //                 width: MediaQuery.of(context).size.width,
    //                 height: 115.0,
    //                 decoration: BoxDecoration(
    //                   color: Colors.grey[50],
    //                   borderRadius: const BorderRadius.only(
    //                       topLeft: Radius.circular(25.0),
    //                       topRight: Radius.circular(25.0)),
    //                   boxShadow: <BoxShadow>[
    //                     BoxShadow(
    //                       color: Colors.black12,
    //                       blurRadius: 4.0,
    //                       offset: const Offset(0.0, 4.0),
    //                     ),
    //                   ],
    //                 ),
    //                 child: Padding(
    //                   padding: EdgeInsets.all(20),
    //                   child: Row(
    //                     children: [
    //                       Column(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Row(
    //                             children: [
    //                               Text('Transferring to ',
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w600,
    //                                       fontSize: 14,
    //                                       color: Colors.black)),
    //                               Text(
    //                                   // peerDevice.getName(),
    //                                   'bob',
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w700,
    //                                       fontSize: 14,
    //                                       color: Colors.black)),
    //                             ],
    //                           ),
    //                           // TODO: display actual estimated time
    //                           Padding(
    //                             padding: EdgeInsets.only(top: 10, right: 10),
    //                             child: Row(children: [
    //                               Container(
    //                                 decoration: BoxDecoration(
    //                                   borderRadius: BorderRadius.circular(15),
    //                                   color: Colors.grey[200],
    //                                 ),
    //                                 margin: EdgeInsets.only(right: 10),
    //                                 padding: EdgeInsets.all(10),
    //                                 child: Text('14s',
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.w700,
    //                                         fontSize: 14,
    //                                         color: Colors.grey[600])),
    //                               ),
    //                               Text('2.3 Mb/s',
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w700,
    //                                       fontSize: 14,
    //                                       color: Colors.grey[600])),
    //                             ]),
    //                           )
    //                         ],
    //                       ),
    //                       // TODO: determine whether icon is necessary or not
    //                       // Padding(
    //                       //     padding:
    //                       //         EdgeInsets.only(left: 30, top: 5, right: 5),
    //                       //     child: Icon(
    //                       //       peerDevice.getIcon(),
    //                       //       color: Color(0xff91c27d),
    //                       //       size: 55,
    //                       //     ))
    //                     ],
    //                   ),
    //                 )),
    //           ],
    //         ),
    //       ));
    // } else if (pearPanel == PearPanel.receiving) {
    //   return MediaQuery.removePadding(
    //       context: context,
    //       removeTop: true,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.grey[200],
    //           borderRadius: const BorderRadius.only(
    //               topLeft: Radius.circular(20.0),
    //               topRight: Radius.circular(20.0)),
    //           boxShadow: <BoxShadow>[
    //             BoxShadow(
    //               color: Colors.black12,
    //               blurRadius: 4.0,
    //               offset: const Offset(0.0, 4.0),
    //             ),
    //           ],
    //         ),
    //         child: ListView(
    //           controller: sc,
    //           children: <Widget>[
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.end,
    //               children: [
    //                 CloseButton(
    //                   color: Colors.black,
    //                   onPressed: () => setPearPanel(false, PearPanel.sharing),
    //                 )
    //               ],
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(left: 20, top: 0, bottom: 3),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: <Widget>[
    //                   Text(
    //                     "File Receiving",
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.w600,
    //                       fontSize: 19.0,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Padding(
    //               padding: EdgeInsets.only(left: 20, top: 3, bottom: 15),
    //               child: Row(
    //                 mainAxisAlignment: MainAxisAlignment.start,
    //                 children: <Widget>[
    //                   Padding(
    //                     padding: EdgeInsets.only(right: 5),
    //                     child: Icon(
    //                       Icons.description,
    //                       size: 20,
    //                     ),
    //                   ),
    //                   Text(
    //                     FileSelect().nameFromPath(filePath),
    //                     overflow: TextOverflow.ellipsis,
    //                     style: TextStyle(
    //                       fontWeight: FontWeight.w500,
    //                       fontSize: 15.0,
    //                       color: Color(0xff559364),
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Padding(
    //               padding:
    //                   EdgeInsets.only(bottom: 20, top: 15, left: 15, right: 15),
    //               child: PercentageProgressIndicator(),
    //             ),
    //             Container(
    //                 width: MediaQuery.of(context).size.width,
    //                 height: 115.0,
    //                 decoration: BoxDecoration(
    //                   color: Colors.grey[50],
    //                   borderRadius: const BorderRadius.only(
    //                       topLeft: Radius.circular(25.0),
    //                       topRight: Radius.circular(25.0)),
    //                   boxShadow: <BoxShadow>[
    //                     BoxShadow(
    //                       color: Colors.black12,
    //                       blurRadius: 4.0,
    //                       offset: const Offset(0.0, 4.0),
    //                     ),
    //                   ],
    //                 ),
    //                 child: Padding(
    //                   padding: EdgeInsets.all(20),
    //                   child: Row(
    //                     children: [
    //                       Column(
    //                         mainAxisAlignment: MainAxisAlignment.end,
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Row(
    //                             children: [
    //                               Text('Receiving from ',
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w600,
    //                                       fontSize: 14,
    //                                       color: Colors.black)),
    //                               Text('bob',

    //                                   // peerDevice.getName(),
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w700,
    //                                       fontSize: 14,
    //                                       color: Colors.black)),
    //                             ],
    //                           ),
    //                           // TODO: display actual estimated time
    //                           Padding(
    //                             padding: EdgeInsets.only(top: 10, right: 10),
    //                             child: Row(children: [
    //                               Container(
    //                                 decoration: BoxDecoration(
    //                                   borderRadius: BorderRadius.circular(15),
    //                                   color: Colors.grey[200],
    //                                 ),
    //                                 margin: EdgeInsets.only(right: 10),
    //                                 padding: EdgeInsets.all(10),
    //                                 child: Text('14s',
    //                                     style: TextStyle(
    //                                         fontWeight: FontWeight.w700,
    //                                         fontSize: 14,
    //                                         color: Colors.grey[600])),
    //                               ),
    //                               Text('2.3 Mb/s',
    //                                   style: TextStyle(
    //                                       fontWeight: FontWeight.w700,
    //                                       fontSize: 14,
    //                                       color: Colors.grey[600])),
    //                             ]),
    //                           )
    //                         ],
    //                       ),
    //                       // TODO: determine whether icon is necessary or not
    //                       // Padding(
    //                       //     padding:
    //                       //         EdgeInsets.only(left: 30, top: 5, right: 5),
    //                       //     child: Icon(
    //                       //       peerDevice.getIcon(),
    //                       //       color: Color(0xff91c27d),
    //                       //       size: 55,
    //                       //     ))
    //                     ],
    //                   ),
    //                 )),
    //           ],
    //         ),
    //       ));
    // } else if (pearPanel == PearPanel.accepting) {
    //   return MediaQuery.removePadding(
    //       context: context,
    //       removeTop: true,
    //       child: ListView(
    //         controller: sc,
    //         children: <Widget>[
    //           Padding(
    //             padding: EdgeInsets.all(25),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: <Widget>[
    //                 Text(
    //                   'bob',

    //                   // peerDevice.getName() + ' would like to share',
    //                   style: TextStyle(
    //                     fontWeight: FontWeight.normal,
    //                     fontSize: 16.0,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: <Widget>[
    //               Column(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: <Widget>[
    //                     Container(
    //                       width: MediaQuery.of(context).size.width,
    //                       padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
    //                       color: Colors.grey[50],
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           Padding(
    //                             padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
    //                             child: Icon(
    //                               Icons.description,
    //                               size: 20,
    //                             ),
    //                           ),
    //                           Center(
    //                             child: Text(FileSelect().nameFromPath(filePath),
    //                                 style: TextStyle(fontSize: 14)),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Container(
    //                       width: MediaQuery.of(context).size.width,
    //                       padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
    //                       child: GestureDetector(
    //                         onTap: () {
    //                           setPearPanel(false, PearPanel.receiving);
    //                           accept();
    //                         },
    //                         child: Container(
    //                           width: 80,
    //                           height: 45,
    //                           decoration: BoxDecoration(
    //                             gradient: LinearGradient(
    //                               colors: [
    //                                 Color(0xff91c27d),
    //                                 Color(0xff559364),
    //                               ],
    //                               begin: Alignment.topLeft,
    //                               end: Alignment.bottomRight,
    //                             ),
    //                             borderRadius: BorderRadius.circular(20),
    //                             boxShadow: [
    //                               BoxShadow(
    //                                 color: Colors.black12,
    //                                 offset: Offset(5, 5),
    //                                 blurRadius: 10,
    //                               )
    //                             ],
    //                           ),
    //                           child: Center(
    //                             child: Text(
    //                               'Accept',
    //                               style: TextStyle(
    //                                 color: Colors.white,
    //                                 fontSize: 18,
    //                                 fontWeight: FontWeight.w500,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ]),
    //             ],
    //           ),
    //         ],
    //       ));
    // } else {
    //   return MediaQuery.removePadding(
    //       context: context,
    //       removeTop: true,
    //       child: ListView(
    //         controller: sc,
    //         children: <Widget>[
    //           Padding(
    //             padding: EdgeInsets.all(25),
    //             child: Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: <Widget>[
    //                 Text(
    //                   'File Receieved',
    //                   style: TextStyle(
    //                     fontWeight: FontWeight.normal,
    //                     fontSize: 16.0,
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //           Column(
    //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //             children: <Widget>[
    //               Column(
    //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                   children: <Widget>[
    //                     Container(
    //                       width: MediaQuery.of(context).size.width,
    //                       padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
    //                       color: Colors.grey[50],
    //                       child: Row(
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         children: [
    //                           Padding(
    //                             padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
    //                             child: Icon(
    //                               Icons.description,
    //                               size: 20,
    //                             ),
    //                           ),
    //                           Center(
    //                             child: Text(FileSelect().nameFromPath(filePath),
    //                                 style: TextStyle(fontSize: 14)),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                     Container(
    //                       width: MediaQuery.of(context).size.width,
    //                       padding: EdgeInsets.fromLTRB(40, 17, 40, 5),
    //                       child: GestureDetector(
    //                         onTap: () {
    //                           reset();
    //                         },
    //                         child: Container(
    //                           width: 80,
    //                           height: 45,
    //                           decoration: BoxDecoration(
    //                             gradient: LinearGradient(
    //                               colors: [
    //                                 Color(0xff91c27d),
    //                                 Color(0xff559364),
    //                               ],
    //                               begin: Alignment.topLeft,
    //                               end: Alignment.bottomRight,
    //                             ),
    //                             borderRadius: BorderRadius.circular(20),
    //                             boxShadow: [
    //                               BoxShadow(
    //                                 color: Colors.black12,
    //                                 offset: Offset(5, 5),
    //                                 blurRadius: 10,
    //                               )
    //                             ],
    //                           ),
    //                           child: Center(
    //                             child: Text(
    //                               'Complete Transfer',
    //                               style: TextStyle(
    //                                 color: Colors.white,
    //                                 fontSize: 18,
    //                                 fontWeight: FontWeight.w500,
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //                       ),
    //                     ),
    //                   ]),
    //             ],
    //           ),
    //         ],
    //       ));
    // }
  }
}
