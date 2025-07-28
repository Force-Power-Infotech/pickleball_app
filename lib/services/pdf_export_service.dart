import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../models/match.dart';

class PdfExportService {
  static Future<void> exportScorecard(Match match) async {
    final pdf = pw.Document();

    bool isDuceAtPoint(ScorePoint point, Match match) {
      final duceThreshold = match.targetScore - 1;
      if (point.teamAScore < duceThreshold || point.teamBScore < duceThreshold) {
        return false;
      }
      return point.teamAScore == point.teamBScore;
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Spacer(),
                  pw.Text(
                    'Date: ' + (match.endTime?.toLocal().toString().split(' ')[0] ?? ''),
                    style: pw.TextStyle(fontSize: 12, font: pw.Font.helvetica()),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Pickleball Match Scorecard',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, font: pw.Font.helvetica()),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Team A: ' + match.teamADisplayName, style: pw.TextStyle(fontSize: 14, font: pw.Font.helvetica())),
              pw.Text('Team B: ' + match.teamBDisplayName, style: pw.TextStyle(fontSize: 14, font: pw.Font.helvetica())),
              pw.SizedBox(height: 8),
                pw.Text('Final Score: ${match.teamAScore} - ${match.teamBScore}', style: pw.TextStyle(fontSize: 14, font: pw.Font.helvetica())),
              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text(
                  'Rally Breakdown',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: pw.Font.helvetica()),
                ),
              ),
              pw.SizedBox(height: 8),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    constraints: const pw.BoxConstraints(minHeight: 20),
                    child: pw.Text('Rally', style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 11), textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    constraints: const pw.BoxConstraints(minHeight: 20),
                    child: pw.Text(match.teamADisplayName, style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 11), textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    constraints: const pw.BoxConstraints(minHeight: 20),
                    child: pw.Text(match.teamBDisplayName, style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 11), textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    constraints: const pw.BoxConstraints(minHeight: 20),
                    child: pw.Text('Server', style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 11), textAlign: pw.TextAlign.center),
                  ),
                  pw.Container(
                    alignment: pw.Alignment.center,
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    constraints: const pw.BoxConstraints(minHeight: 20),
                    child: pw.Text('Current Score', style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 11), textAlign: pw.TextAlign.center),
                  ),
                ],
              ),
              ...List.generate(match.scoreHistory.length, (i) {
                final point = match.scoreHistory[i];
                pw.Widget teamACell, teamBCell;
                const cellPadding = pw.EdgeInsets.symmetric(vertical: 10);
                const cellMinHeight = pw.BoxConstraints(minHeight: 28);
                pw.Widget duceIndicator = pw.SizedBox(width: 0, height: 0);
                if (isDuceAtPoint(point, match)) {
                  duceIndicator = pw.Container(
                    width: 14,
                    height: 14,
                    margin: const pw.EdgeInsets.only(right: 4),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.yellow,
                      shape: pw.BoxShape.circle,
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      'D',
                      style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                      ),
                    ),
                  );
                }
                if (point.winningTeam == ServingTeam.teamA) {
                  teamACell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: PdfColors.lightGreen300,
                    padding: cellPadding,
                    constraints: cellMinHeight,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (isDuceAtPoint(point, match)) duceIndicator,
                        pw.Text('W', style: pw.TextStyle(font: pw.Font.helvetica(), color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  );
                  teamBCell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: PdfColors.red200,
                    padding: cellPadding,
                    constraints: cellMinHeight,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (isDuceAtPoint(point, match)) duceIndicator,
                        pw.Text('L', style: pw.TextStyle(font: pw.Font.helvetica(), color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  );
                } else {
                  teamACell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: PdfColors.red200,
                    padding: cellPadding,
                    constraints: cellMinHeight,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (isDuceAtPoint(point, match)) duceIndicator,
                        pw.Text('L', style: pw.TextStyle(font: pw.Font.helvetica(), color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  );
                  teamBCell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: PdfColors.lightGreen300,
                    padding: cellPadding,
                    constraints: cellMinHeight,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        if (isDuceAtPoint(point, match)) duceIndicator,
                        pw.Text('W', style: pw.TextStyle(font: pw.Font.helvetica(), color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ],
                    ),
                  );
                }
                // Server cell logic: show server details for doubles, simple for singles
                pw.Widget serverCell;
                const serverCellPadding = pw.EdgeInsets.symmetric(vertical: 10);
                const serverCellMinHeight = pw.BoxConstraints(minHeight: 28);
                final serverCellColor = point.servingTeam == ServingTeam.teamA
                    ? PdfColor.fromInt(0xFF00C853)
                    : PdfColor.fromInt(0xFF007AFF);
                if (match.matchType == MatchType.doubles) {
                  // Just show A S1, A S2, B S1, B S2 (no dots)
                  String serverLabel = point.serverNumber == 2 ? 'S2' : 'S1';
                  serverCell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: serverCellColor,
                    padding: serverCellPadding,
                    constraints: serverCellMinHeight,
                    child: pw.Text(
                      '${point.servingTeam == ServingTeam.teamA ? 'A' : 'B'} $serverLabel',
                      style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                } else {
                  // Singles: just show A/B
                  serverCell = pw.Container(
                    alignment: pw.Alignment.center,
                    color: serverCellColor,
                    padding: serverCellPadding,
                    constraints: serverCellMinHeight,
                    child: pw.Text(
                      point.servingTeam == ServingTeam.teamA ? 'A' : 'B',
                      style: pw.TextStyle(
                        font: pw.Font.helvetica(),
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                final currentScoreCell = pw.Container(
                  alignment: pw.Alignment.center,
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  constraints: const pw.BoxConstraints(minHeight: 20),
                  child: pw.Text(
                    '${point.teamAScore} - ${point.teamBScore}',
                    style: pw.TextStyle(font: pw.Font.helvetica(), fontWeight: pw.FontWeight.bold, fontSize: 10),
                    textAlign: pw.TextAlign.center,
                  ),
                );
                return pw.TableRow(
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      constraints: const pw.BoxConstraints(minHeight: 20),
                      child: pw.Text((i + 1).toString(), style: pw.TextStyle(font: pw.Font.helvetica(), fontSize: 10), textAlign: pw.TextAlign.center),
                    ),
                    teamACell,
                    teamBCell,
                    serverCell,
                    currentScoreCell,
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    String sanitize(String name) => name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final teamA = sanitize(match.teamADisplayName);
    final teamB = sanitize(match.teamBDisplayName);
    final filename = 'scorecard_${teamA}_vs_${teamB}.pdf';
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }
}
