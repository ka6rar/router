import 'package:flutter/material.dart';
import 'package:router/core/constants/style.dart';
import 'package:router/data/datasources/local/db_helper.dart';

class Backup extends StatefulWidget {
  const Backup({super.key});

  @override
  State<Backup> createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  @override

  DBHerper _dbHerper =  DBHerper();

  String sizeText = '';
  String messageStatus= '';

  @override
  void initState() {
    super.initState();
    _loadDbSize();
  }

  Future<void> _loadDbSize() async {
    await _dbHerper.printSmartDatabaseSize();
    setState(() {
      sizeText = _dbHerper.sizeDb!;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("إدارة النسخ الاحتياطية" , style: TextStyle(fontFamily: fontF , fontSize: 16),),
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.green.shade50 ,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(sizeText +  " :  مساحة البيانات ", style: const TextStyle(fontSize: 18 , fontFamily: fontF , color: Colors.green),),
                        Text(messageStatus , style: const TextStyle(fontSize: 18 , fontFamily: fontF , color: Colors.green),),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '📁 سيتم حفظ النسخة الاحتياطية في مجلد التنزيلات:',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: fontF,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.right,
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontF,
                            color: Colors.black87,
                          ),
                          textDirection: TextDirection.ltr,
                        ),

                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10,) ,
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(height: 16),
                  _buildBackupButton(
                    icon: Icons.backup,
                    label: 'استرجاع  احتياطية',
                    onPressed: () async {
                     await  _dbHerper.importDatabase();
                       setState(() {
                         messageStatus=   _dbHerper.messageStatus!  ;
                         print(messageStatus);
                       });
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildBackupButton(
                    icon: Icons.restore,
                    label: ' نسخة احتياطية',
                    onPressed: () async {
                      //TODO: كرار جبر
                      await  _dbHerper.exportDatabase();
                      setState(() {
                        messageStatus=   _dbHerper.messageStatus!  ;
                      });
                    },
                  ),
                ],
              )
            ],
          ),
        ],
      ),


    );
  }
  Widget _buildBackupButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.green.shade700, size: 28),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: fontF,
          color: Colors.green.shade800,
          fontSize: 13,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade50,
        foregroundColor: Colors.green.shade100,
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        shadowColor: Colors.green.shade100,
      ),
    );
  }

}
