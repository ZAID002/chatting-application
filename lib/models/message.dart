class Message {
 late final String msg;
 late final String  toId;
 late final String read;
 late final Type type;
 late final String fromId;
 late final String sent;

  Message({required this.msg, required this.toId,required this.read,
    required this.type, required this.fromId, required this.sent});


  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
                                     //if else if type.image.name then true if image.text then false
    type = json['type'].toString()== Type.images.name ? Type.images:Type.text;
    fromId = json['fromId'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['fromId'] = fromId;
    data['sent'] = sent;
    return data;
  }
}
//An enum (enumeration) is a special data type that represents a fixed
// set of constant values. It improves type safety
// and makes code more readable and maintainable.
enum Type{text,images}

