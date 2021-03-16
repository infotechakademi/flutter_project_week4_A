class User {
  int id;
  String idText;
  String name;
  //Address address;
  String phone;
  String website;

  User() {}

  User.fromJson(json) {
    if (json != null) {
      this.id = json["id"];
      this.idText = json["id"].toString();
      this.name = json["name"];
      this.phone = json["phone"];
      this.website = json["website"];
    }
  }

  @override
  String toString() {
    return this.name + " " + this.idText;
  }
}
