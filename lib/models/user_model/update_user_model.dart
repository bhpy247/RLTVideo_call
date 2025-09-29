class UpdateUserModel {
  int? coins;
  int? energy;
  String? name;
  String? email;
  int? newLevel;
  int? newStars;
  String id;

  UpdateUserModel(
      {this.coins,
        this.energy,
        this.name,
        this.email,
        this.newLevel,
        this.newStars,
      this.id = ""});

  // UpdateUserModel.fromJson(Map<String, dynamic> json) {
  //   coins = json['coins'];
  //   energy = json['energy'];
  //   name = json['name'];
  //   email = json['email'];
  //   newLevel = json['newLevel'];
  //   newStars = json['newStars'];
  // }

  Map<String, dynamic> toJson() {
    return {
      if (coins != null) 'coins': coins,
      if (energy != null) 'energy': energy,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (newLevel != null) 'newLevel': newLevel,
      if (newStars != null) 'newStars': newStars,
    };
  }
}