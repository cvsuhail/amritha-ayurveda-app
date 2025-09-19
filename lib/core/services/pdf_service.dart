import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateAndDownloadPatientPdf(Map<String, dynamic> patientData) async {
    try {
      // Create PDF document
      final pdf = pw.Document();
      
      // Load assets
      final logoBytes = await rootBundle.load('assets/images/login-logo.png');
      final watermarkBytes = await rootBundle.load('assets/icons/pdfwatermark.png');
      final signBytes = await rootBundle.load('assets/icons/sign.png');
      
      final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
      final watermark = pw.MemoryImage(watermarkBytes.buffer.asUint8List());
      final sign = pw.MemoryImage(signBytes.buffer.asUint8List());

      // Load font
      final poppinsRegular = await PdfGoogleFonts.poppinsRegular();
      final poppinsBold = await PdfGoogleFonts.poppinsBold();
      final poppinsSemiBold = await PdfGoogleFonts.poppinsSemiBold();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(0),
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                // Background watermark - positioned in center with low opacity
                pw.Positioned.fill(
                  child: pw.Opacity(
                    opacity: 0.08,
                    child: pw.Center(
                      child: pw.Image(
                        watermark,
                        width: 400,
                        height: 400,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                
                // Main content
                pw.Padding(
                  padding: const pw.EdgeInsets.all(40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Header with logo and company info
                      _buildHeader(logo, poppinsRegular, poppinsBold),
                      
                      pw.SizedBox(height: 30),
                      
                      // Patient Details Section
                      _buildPatientDetailsSection(patientData, poppinsRegular, poppinsBold, poppinsSemiBold),
                      
                      pw.SizedBox(height: 30),
                      
                      // Treatment Table
                      _buildTreatmentTable(patientData, poppinsRegular, poppinsBold, poppinsSemiBold),
                      
                      pw.SizedBox(height: 30),
                      
                      // Amount Summary
                      _buildAmountSummary(patientData, poppinsRegular, poppinsBold),
                      
                      pw.Spacer(),
                      
                      // Footer with thank you message and signature
                      _buildFooter(sign, poppinsRegular, poppinsBold),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Generate and show PDF using printing package (handles platform differences automatically)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'patient_${patientData['name']?.toString().replaceAll(' ', '_') ?? 'prescription'}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error generating PDF: $e');
      }
      throw Exception('Failed to generate PDF: $e');
    }
  }

  static pw.Widget _buildHeader(pw.MemoryImage logo, pw.Font poppinsRegular, pw.Font poppinsBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Logo - circular container with green border
        pw.Container(
          width: 100,
          height: 100,
          decoration: pw.BoxDecoration(
            shape: pw.BoxShape.circle,
            border: pw.Border.all(
              color: const PdfColor.fromInt(0xFF3D704D),
              width: 2,
            ),
          ),
          child: pw.ClipOval(
            child: pw.Image(logo, fit: pw.BoxFit.cover),
          ),
        ),
        
        pw.Spacer(),
        
        // Company Info - right aligned
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'KUMARAKOM',
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: 18,
                color: const PdfColor.fromInt(0xFF2C2C2C),
                letterSpacing: 1.5,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Cheepunkal P.O. Kumarakom, Kottayam, Kerala - 686563',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 11,
                color: const PdfColor.fromInt(0xFF666666),
              ),
              textAlign: pw.TextAlign.right,
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'e-mail: unknown@gmail.com',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 11,
                color: const PdfColor.fromInt(0xFF666666),
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              'Mob: +91 9876543210 | +91 9876543210',
              style: pw.TextStyle(
                font: poppinsRegular,
                fontSize: 11,
                color: const PdfColor.fromInt(0xFF666666),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'GST No: 32AABCCU9603R1ZW',
              style: pw.TextStyle(
                font: poppinsBold,
                fontSize: 13,
                color: const PdfColor.fromInt(0xFF2C2C2C),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildPatientDetailsSection(Map<String, dynamic> patientData, pw.Font poppinsRegular, pw.Font poppinsBold, pw.Font poppinsSemiBold) {
    // Parse date
    String formattedDate = '';
    String formattedTime = '';
    try {
      if (patientData['dateNdTime'] != null) {
        final dateTime = DateTime.parse(patientData['dateNdTime'].toString());
        formattedDate = '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
        formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      formattedDate = DateTime.now().toString().split(' ')[0];
      formattedTime = '12:00pm';
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Green line separator
        pw.Container(
          width: double.infinity,
          height: 2,
          color: const PdfColor.fromInt(0xFF3D704D),
        ),
        pw.SizedBox(height: 20),
        
        pw.Text(
          'Patient Details',
          style: pw.TextStyle(
            font: poppinsBold,
            fontSize: 18,
            color: const PdfColor.fromInt(0xFF3D704D),
          ),
        ),
        pw.SizedBox(height: 20),
        
        // Patient details in rows with better spacing
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('Name', patientData['name']?.toString() ?? 'Salih T', poppinsRegular, poppinsSemiBold),
            ),
            pw.SizedBox(width: 60),
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('Booked On', '$formattedDate | ${formattedTime}pm', poppinsRegular, poppinsSemiBold),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('Address', patientData['address']?.toString() ?? 'Nadakkave, Kozhikode', poppinsRegular, poppinsSemiBold),
            ),
            pw.SizedBox(width: 60),
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('Treatment Date', formattedDate.isNotEmpty ? formattedDate : '21/02/2024', poppinsRegular, poppinsSemiBold),
            ),
          ],
        ),
        pw.SizedBox(height: 16),
        
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('WhatsApp Number', patientData['phone']?.toString() ?? '+91 9876543210', poppinsRegular, poppinsSemiBold),
            ),
            pw.SizedBox(width: 60),
            pw.Expanded(
              flex: 3,
              child: _buildDetailRow('Treatment Time', formattedTime.isNotEmpty ? '${formattedTime}am' : '11:00 am', poppinsRegular, poppinsSemiBold),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDetailRow(String label, String value, pw.Font poppinsRegular, pw.Font poppinsSemiBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: poppinsSemiBold,
            fontSize: 12,
            color: const PdfColor.fromInt(0xFF2C2C2C),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: poppinsRegular,
            fontSize: 11,
            color: const PdfColor.fromInt(0xFF666666),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTreatmentTable(Map<String, dynamic> patientData, pw.Font poppinsRegular, pw.Font poppinsBold, pw.Font poppinsSemiBold) {
    // Parse treatments from patient data
    final List<Map<String, dynamic>> treatments = [
      {
        'name': 'Panchakarma',
        'price': 230,
        'male': 4,
        'female': 4,
        'total': 2540,
      },
      {
        'name': 'Njavara Kizhi Treatment',
        'price': 230,
        'male': 4,
        'female': 4,
        'total': 2540,
      },
      {
        'name': 'Panchakarma',
        'price': 230,
        'male': 4,
        'female': 6,
        'total': 2540,
      },
    ];

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: const PdfColor.fromInt(0xFFE0E0E0),
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          // Table header with green background
          pw.Container(
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF8F9FA),
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(8),
                topRight: pw.Radius.circular(8),
              ),
            ),
            padding: const pw.EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    'Treatment',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 13,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Price',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 13,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'Male',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 13,
                      color: const PdfColor.fromInt(0xFF3D704D),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    'Female',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 13,
                      color: const PdfColor.fromInt(0xFF3D704D),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'Total',
                    style: pw.TextStyle(
                      font: poppinsBold,
                      fontSize: 13,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          
          // Table rows
          for (int i = 0; i < treatments.length; i++) pw.Container(
            color: i % 2 == 0 ? PdfColors.white : const PdfColor.fromInt(0xFFFAFAFA),
            padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    treatments[i]['name'].toString(),
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '₹${treatments[i]['price']}',
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    treatments[i]['male'].toString(),
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Text(
                    treatments[i]['female'].toString(),
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    '₹${treatments[i]['total']}',
                    style: pw.TextStyle(
                      font: poppinsSemiBold,
                      fontSize: 12,
                      color: const PdfColor.fromInt(0xFF2C2C2C),
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountSummary(Map<String, dynamic> patientData, pw.Font poppinsRegular, pw.Font poppinsBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 280,
          child: pw.Column(
            children: [
              _buildAmountRow('Total Amount', '₹7,620', poppinsRegular, poppinsBold, isTotal: true),
              pw.SizedBox(height: 10),
              _buildAmountRow('Discount', '₹500', poppinsRegular, poppinsRegular),
              pw.SizedBox(height: 10),
              _buildAmountRow('Advance', '₹1,200', poppinsRegular, poppinsRegular),
              pw.SizedBox(height: 16),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: pw.BoxDecoration(
                  color: const PdfColor.fromInt(0xFF3D704D),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Balance',
                      style: pw.TextStyle(
                        font: poppinsBold,
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.Text(
                      '₹5,920',
                      style: pw.TextStyle(
                        font: poppinsBold,
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAmountRow(String label, String amount, pw.Font labelFont, pw.Font amountFont, {bool isTotal = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: labelFont,
            fontSize: isTotal ? 14 : 13,
            color: const PdfColor.fromInt(0xFF2C2C2C),
          ),
        ),
        pw.Text(
          amount,
          style: pw.TextStyle(
            font: amountFont,
            fontSize: isTotal ? 14 : 13,
            color: const PdfColor.fromInt(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.MemoryImage sign, pw.Font poppinsRegular, pw.Font poppinsBold) {
    return pw.Column(
      children: [
        // Thank you message with better spacing
        pw.Center(
          child: pw.Text(
            'Thank you for choosing us',
            style: pw.TextStyle(
              font: poppinsBold,
              fontSize: 18,
              color: const PdfColor.fromInt(0xFF3D704D),
            ),
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Center(
          child: pw.Text(
            'Your well-being is our commitment, and we\'re honored\nyou\'ve entrusted us with your health journey.',
            style: pw.TextStyle(
              font: poppinsRegular,
              fontSize: 11,
              color: const PdfColor.fromInt(0xFF999999),
              height: 1.4,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
        
        pw.SizedBox(height: 40),
        
        // Signature - positioned to the right
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Container(
              width: 150,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Signature image
                  pw.Container(
                    height: 60,
                    child: pw.Image(
                      sign,
                      width: 120,
                      height: 50,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  // Signature line
                  pw.Container(
                    width: 120,
                    height: 1.5,
                    color: const PdfColor.fromInt(0xFF2C2C2C),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Signature',
                    style: pw.TextStyle(
                      font: poppinsRegular,
                      fontSize: 11,
                      color: const PdfColor.fromInt(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        pw.SizedBox(height: 30),
        
        // Footer note with better styling
        pw.Center(
          child: pw.Text(
            '*Booking amount is non-refundable, and it is important to arrive on the allotted time for your treatment.',
            style: pw.TextStyle(
              font: poppinsRegular,
              fontSize: 9,
              color: const PdfColor.fromInt(0xFF999999),
            ),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );
  }
}
