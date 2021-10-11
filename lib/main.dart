import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:barcode/barcode.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.robotoBlack();

    final http.Response response = await http.get(
      Uri.parse('https://images.unsplash.com/photo-1633113090286-3318ea2d24ae?i'
          'xid=MnwxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto'
          '=format&fit=crop&w=2070&q=80'),
    );
    final Uint8List imageBytes = response.bodyBytes;

    pdf.addPage(
      pw.Page(
        orientation: pw.PageOrientation.portrait,
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Stack(
            children: [
              pw.SizedBox(
                height: PdfPageFormat.a4.availableHeight,
                width: PdfPageFormat.a4.availableWidth,
                child: pw.Watermark.text("SEBUAH WATERMARK",),
              ),
              pw.SizedBox(
                height: PdfPageFormat.a4.availableHeight,
                width: PdfPageFormat.a4.availableWidth,
                child: pw.Column(
                  children: [
                    pw.SizedBox(
                      width: double.infinity,
                      child: pw.FittedBox(
                        child: pw.Text('Sebuah Judul',
                          style: pw.TextStyle(font: font),
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 20),
                    pw.Flexible(child: pw.FlutterLogo()),
                    pw.Flexible(child: pw.Image(pw.MemoryImage(imageBytes))),
                    pw.SizedBox(height: 20),
                    pw.SizedBox(
                      height: 200,
                      width: 200,
                      child: pw.BarcodeWidget(
                        data: "sebuah link",
                        barcode: Barcode.qrCode(),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
