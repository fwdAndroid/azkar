import 'package:flutter/material.dart';

class SuratDetailsPage extends StatefulWidget {
  var snap;
  // int? number;
  // String? name;
  // String? englishName;
  // String? englishNameTranslation;
  // // RevelationType? revelationType;
  // List<Ayah>? ayahs;
  SuratDetailsPage({
    Key? key,
    required this.snap,
    // this.name,
    // this.ayahs,
    // this.englishName,
    // this.englishNameTranslation,
    // this.number,
  }) : super(key: key);

  @override
  State<SuratDetailsPage> createState() => _SuratDetailsPageState();
}

class _SuratDetailsPageState extends State<SuratDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: Text(
                        '',
                        style: TextStyle(
                          fontFamily: 'Gilroy',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                    Spacer(),
                    Icon(
                      Icons.share,
                      color: Color.fromARGB(255, 244, 244, 245),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.play_arrow,
                      color: Color.fromARGB(255, 244, 244, 245),
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(widget.snap.englishName!),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(8.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'Meaining of name ${widget.snap.englishNameTranslation!}',
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    height: MediaQuery.of(context).size.height * 0.65,
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          color: Color(0xff3F48CC),
                          height: 30,
                          child: Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontFamily: 'Gilroy',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.share,
                                color: Color.fromARGB(255, 244, 244, 245),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.play_arrow,
                                color: Color.fromARGB(255, 244, 244, 245),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: ListView.builder(
                              itemCount: widget.snap.ayahs.length,
                              itemBuilder: (context, index) => Text(
                                widget.snap.ayahs[index].text,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              // child: Text('Meaining of name ${widget.snap.ayahs}'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
