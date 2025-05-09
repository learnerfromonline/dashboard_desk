import 'package:dashboard_desk/model/side_menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
 final menu= <SideMenuModel>[
  SideMenuModel(icon:Icons.home, title: "Home"),
  SideMenuModel(icon:Icons.image, title: "Image Compressor"),
  SideMenuModel(icon:Icons.picture_as_pdf, title: "Image to PDF Converter"),
  SideMenuModel(icon:Icons.video_camera_back_rounded, title: "Online Video Player"),
  SideMenuModel(icon:Icons.meeting_room, title: "Online Meetings"),
  SideMenuModel(icon:Icons.calculate, title: "Calculations"),
  SideMenuModel(icon:Icons.compress_outlined, title: "PDF Compressor"),

 ];
}