class ChatUser {
  late  String image;
  late  String about;
  late  String name;
  late  String createdAt;
  late  String lastActive;
  late  bool isOnline;
  late  String id;
  late  String email;
  late  String pushToken;

  ChatUser({
    required this.image,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
    required this.id,
    required this.email,
    required this.pushToken,
  });

  ChatUser.fromJson(Map<String, dynamic> json) {
    image = json['image']?? '';
    about = json['about']?? '';
    name = json['name']?? '';
    createdAt = json['created_at']?? '';
    lastActive = json['last_active']?? '';
    isOnline = json['is_online']?? '';
    id = json['id']?? '';
    email = json['email']?? '';
    pushToken = json['push_token']?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image'] = this.image;
    data['about'] = this.about;
    data['name'] = this.name;
    data['created_at'] = this.createdAt;
    data['last_active'] = this.lastActive;
    data['is_online'] = this.isOnline;
    data['id'] = this.id;
    data['email'] = this.email;
    data['push_token'] = this.pushToken;
    return data;
  }
}
