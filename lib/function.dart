import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';

final _credentials = ServiceAccountCredentials.fromJson({
  "type": "service_account",
  "project_id": "login-page-data-1916c",
  "private_key_id": "7307b003fb83ea56a0062b1fb8e64b4fc3bba4ec",
  "private_key": "-----BEGIN PRIVATE KEY-----\n"
      "MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCUn3ULy94tMj1A\n"
      "2zQA59tncWSD9y4PqvGIq2hyg7zBAfZXSDg1mYCrNFphV2vijgV+H9MgqN9VCi/n\n"
      "eFjerq2x2kJfIBQsDhddmG0N1BDf/YshEk8JQENt5CUT1UNaJ7f1r99z+smsUuQy\n"
      "fu00hxfgD1tHJ5+P85eV+lx05Ac8ZsL8VztMKFnhVe6EF+2/J1omKMQtBDf2fFpj\n"
      "Ik97p1+hrlaJA3Y4PluZR8GO9GDR+kwBWdWckDY0SPeZTj1IsHrqFt0MDG7GyMoq\n"
      "qp8hZQX/EUpoFyS/oCgmD911Wj7ghci8FrZxwQV08gym8BZF974ZjSgwC5SpyHvH\n"
      "cWYBjkA3AgMBAAECggEAKQrH1dQcrLp889YUzFM64ZwMt+ygia8ZODath0Id8+bI\n"
      "0l2dOCAFykGQ2+S6ZDv4BFZhhVldIyzHAdLYJ9ZxHPY68e335BqYFT6sju8LIe/w\n"
      "Zdeaf+GBPW2NV6bDDLh/Mpe4y1xsKOxTHCa09pZ/314eRM4KYERSjhYvRhBadzE1\n"
      "o3GwNL/u6bIgOkja7HBhcKXEim3pBT2/RMCFWCvZ2u235h87I3c9UOO7A43ApV/h\n"
      "O1P4gtQUKdLRG1SFirbMLmAEWBuI1HWpXV7TOG3DR3A+0+1iWs7EBSnjshzZN2Ap\n"
      "0HcMP4tGNIqEAwloZuCOixg2eTBQBrVI18BgOgGw4QKBgQDPe8Yw5YzG6eOUTWP9\n"
      "CM3mRtxOnQTZRslv5+fvg/WXzOjAevokORy0eDtyZrtF0KV1UDnTLo7vDDMV+QoN\n"
      "FfUJOFt2fOXqwq+kdd75vztmCWZq4xw6JgDe4CpEOdtYKK2H/FRfMRzjqizL1F+Z\n"
      "J70AJAqeoe/YKq4XWzXpsAuiCQKBgQC3YDY7u6zOxxypa8nnpByogZVug/B/NDqI\n"
      "cq/y0DZgnd28Bdgwt5uhTKg4FQ9C2bemA+oBXyTo7C5IZy56KP7Y90udcNpmtQw/\n"
      "1Py/9W25WPH90Oibx79/Twk0PE71XpGmyKFQ2bozuxZh3z8pZxeOk9c3dvvkdNfq\n"
      "iHLvZf5gPwKBgQCRmlO4Jq8HPEV34mODw7Tyn9Gk3W30qEdeX8kU/W7Q63x+7w4x\n"
      "c17giut02gEb+lLSo80glTC7Mr168vyJuFnv8XvGB9o1SBCIgitK6lddwMT9x4kc\n"
      "iWTdA0TGAjAaitlUb9ApyUZzwg2TsOKxkQCCY8iMECpHcZQgUeLgrqlLOQKBgQCj\n"
      "+hkFGTHSRiLPLWADD7HAzP+/L6SjWyTsVwIXczDs/L4HIILOLaGxf0b9v3dCJEYg\n"
      "4mciit4KmwhYHkxlWLtrcNfhFcV3CnbFrcPGM8XGdE8Q1PrsMpZ/VUG5wCQrLkG4\n"
      "jrgSAGCNWcMOCgAFGfbqvDE7m95r0EAzrYh5ow7xKQKBgQCPt3BabLyOOKBsqXvb\n"
      "78vQE2LOVDk0igEZlTuvjn4TYX57hb6NdypfTSkOE4OTqQ803s0N4y5ce8PQGGg8\n"
      "O99LHdX0Q3nqk6qLs5SflFJMBO91m3l5CFGWspPsRebTirXO4V0DOrpL6j3Qu4J7\n"
      "ecd5UOF3OMZh+Fwghq0DaGP5iA==\n"
      "-----END PRIVATE KEY-----",
  "client_email": "excel-464@login-page-data-1916c.iam.gserviceaccount.com",
  "client_id": "107223080170259050845",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url":
      "https://www.googleapis.com/robot/v1/metadata/x509/excel-464%40login-page-data-1916c.iam.gserviceaccount.com"
});

final _scopes = [SheetsApi.spreadsheetsScope];

void accessSheet(String enrollmentNumber) async {
  final client = await clientViaServiceAccount(_credentials, _scopes);
  final sheetsApi = SheetsApi(client);

  // Assuming Sheet ID and other details
  final sheetId = '18LnwWTR5eBIM0yeiGljxhb8uVBDdHbHdu7ZI3o4y4kk';
  final range = 'C:C'; // Column where enrollment numbers are stored

  // Fetch the column data to locate the enrollment number
  ValueRange response = await sheetsApi.spreadsheets.values.get(sheetId, range);

  int? rowIndex;
  for (int i = 0; i < response.values!.length; i++) {
    if (response.values?[i][0] == enrollmentNumber) {
      rowIndex = i + 1;
      break;
    }
  }
  if (rowIndex == null) {
    print('Enrollment number not found');
    return;
  }

  // Find the column for the date
  final dateRange = 'D1:Z1';
  ValueRange dateResponse =
      await sheetsApi.spreadsheets.values.get(sheetId, dateRange);
  var today = DateTime.now();
  var formattedDate = "${today.month.toString().padLeft(
        2,
      )}/${today.day.toString()}/${today.year}";
  print(formattedDate);
  int? dateColumnIndex;
  for (int i = 0; i < dateResponse.values![0].length; i++) {
    if (dateResponse.values![0][i] == formattedDate) {
      dateColumnIndex = i;
      break;
    }
  }
  if (dateColumnIndex == null) {
    print('Date not found in the sheet');
    return;
  }

  // Convert column index to letter
  String columnLetter =
      String.fromCharCode('D'.codeUnitAt(0) + dateColumnIndex);

  // Mark the attendance at the determined cell
  final cellToUpdate = '$columnLetter$rowIndex';
  var value = ValueRange();
  value.values = [
    ['1']
  ];
  await sheetsApi.spreadsheets.values
      .update(value, sheetId, cellToUpdate, valueInputOption: 'RAW');
  print('Attendance marked at $cellToUpdate');

  client.close();
}

void main() {
  var today = DateTime.now();
  var formattedDate = "${today.month.toString().padLeft(
        2,
      )}/${today.day.toString()}/${today.year}";
  print(formattedDate);
}
