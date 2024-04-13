import 'package:flutter/material.dart';
import 'package:frontend/screen/verify_company_screen.dart';

class CompanyItem extends StatelessWidget {
  // final int id;
  final String companyName;
  // final Image? logoImage;

  const CompanyItem({
    super.key,
    // required this.id,
    required this.companyName,
    // required this.logoImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('탭됨: $companyName');
        Future.delayed(Duration.zero, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyCompanyScreen(
                        // companyId: id,
                        companyName: companyName,
                        // logoImage: logoImage ?? Image.asset('assets/logo.png'),
                      )));
        });
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /*
              Container(
                padding: const EdgeInsets.all(10),
                
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      (logoImage ?? Image.asset('assets/logo.png')).image,
                ),
                
              ),
              */
              Expanded(
                child: Text(
                  companyName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
