import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_colors.dart';
import 'overtimeform_page.dart';
import 'overtimeformedit_page.dart';
import 'home_page.dart';
import '../utils/localizations.dart';
import '../utils/globals.dart';
import '../controllers/overtime_controller.dart';

class OvertimeListPage extends StatefulWidget {
  const OvertimeListPage({Key? key}) : super(key: key);

  @override
  State<OvertimeListPage> createState() => _OvertimeListPageState();
}

class _OvertimeListPageState extends State<OvertimeListPage> {
  final OvertimeController controller = OvertimeController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.deepGreen),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          },
        ),
        centerTitle: true,
        title: Text(
          AppLocalizations(globalLanguage).translate("overtimeList"),
          style: const TextStyle(
            color: AppColors.deepGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.deepGreen),
            onPressed: () {
              // Search functionality here
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.deepGreen, AppColors.lightGreen],
              ),
            ),
          ),
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: controller.fetchOvertimeUser(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final List<Map<String, dynamic>> overtimeList = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: overtimeList.length,
                    itemBuilder: (context, index) {
                      final overtime = overtimeList[index];

                      return Column(
                        children: [
                          if (index == 0) const SizedBox(height: 16),
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
                              child: Column(
                                children: [
                                  Row(children: [
                                    Text(
                                      formatLanguageDate(overtime['Ovt_Prop_Date']),
                                      style: const TextStyle(color: AppColors.mainGreen),
                                    ),
                                    const Spacer(),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: overtime['Status'] == 'Open/Draft'
                                              ? Colors.orange
                                              : Colors.green,
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Text(
                                          overtime['Status'] == 'Open/Draft'
                                              ? AppLocalizations(globalLanguage).translate("requested")
                                              : AppLocalizations(globalLanguage).translate("approved"),
                                          style: const TextStyle(
                                            color: AppColors.deepGreen,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (overtime['Status'] == 'Open/Draft') const SizedBox(width: 10),
                                    if (overtime['Status'] == 'Open/Draft') InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OvertimeEditFormPage(
                                                    overtimeData: overtime),
                                          ),
                                        );
                                      },
                                      child: Image.asset('assets/fill.png', height: 24, width: 24),
                                    ),
                                  ]),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(AppLocalizations(globalLanguage).translate("from"), style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5),
                                          Text(AppLocalizations(globalLanguage).translate("until"), style: const TextStyle(fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 5),
                                          Text(AppLocalizations(globalLanguage).translate("remark"), style: const TextStyle(fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      const Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(':'),
                                          SizedBox(height: 5),
                                          Text(':'),
                                          SizedBox(height: 5),
                                          Text(':'),
                                        ],
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(formatLanguageFullDate(overtime['Ovt_Date_Start'])),
                                          const SizedBox(height: 5),
                                          Text(formatLanguageFullDate(overtime['Ovt_Date_End']),),
                                          const SizedBox(height: 5),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              Text(
                                                overtime['Ovt_Noted'],
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (index == overtimeList.length - 1) const SizedBox(height: 76),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 100,
            right: 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Colors.white, AppColors.lightGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const OvertimeFormPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  AppLocalizations(globalLanguage).translate("addOvertime"),
                  style: const TextStyle(
                    color: AppColors.deepGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatLanguageDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final String formattedDate = DateFormat.yMMMMd(globalLanguage.toLanguageTag()).format(dateTime);
    return formattedDate;
  }

  String formatLanguageFullDate(String dateString) {
    final DateTime dateTime = DateTime.parse(dateString);
    final String formattedDate = DateFormat('dd MMM yyyy [HH:mm]', globalLanguage.toLanguageTag()).format(dateTime);
    return formattedDate;
  }
}
