class ContractRegionModel {
  final String contractRegionId;
  final String subdistrictId;
  final String phone;
  final String image;
  final bool master;
  final String mail;
  final String subdistrictName;

  ContractRegionModel({
    required this.contractRegionId,
    required this.subdistrictId,
    required this.phone,
    required this.image,
    required this.master,
    required this.mail,
    required this.subdistrictName,
  });

  ContractRegionModel.fromJson(Map<String, dynamic> json)
      : contractRegionId = json['contractRegionId'],
        subdistrictId = json['subdistrictId'],
        phone = json['phone'],
        image = json['image'],
        master = json['master'],
        mail = json['mail'],
        subdistrictName = json['subdistricts']['subdistrict'];

  ContractRegionModel.empty()
      : contractRegionId = "",
        subdistrictId = "",
        phone = "",
        image = "",
        master = false,
        mail = "",
        subdistrictName = "";
}
