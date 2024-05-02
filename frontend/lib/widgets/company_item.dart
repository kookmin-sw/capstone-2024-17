import 'package:flutter/material.dart';
import 'package:frontend/screen/verify_company_screen.dart';
import 'package:frontend/widgets/rounded_img.dart';

class CompanyItem extends StatelessWidget {
  // final int id;
  final String companyName;
  final String logoInfo;
  final String domain;

  const CompanyItem({
    super.key,
    // required this.id,
    required this.companyName,
    required this.logoInfo,
    required this.domain,
  });

  @override
  Widget build(BuildContext context) {
    Image logoImage = Image.network(logoInfo, fit: BoxFit.cover);
    return GestureDetector(
      onTap: () {
        print('탭됨: $companyName');
        Future.delayed(Duration.zero, () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => VerifyCompanyScreen(
                        companyName: companyName,
                        logoImage: logoImage,
                        domain: domain,
                      )));
        });
      },
      child: Card(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                child: RoundedImg(image: logoImage, size: 50),
              ),
              const SizedBox(width: 10,),
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
