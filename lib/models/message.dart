class Message {
  Message({
    required this.msg,
    required this.toId,
    required this.read,
    required this.sent,
    required this.fromId,
    required this.type,
  });

  late final String msg;
  late final String toId;
  late final String read;
  late final String sent;
  late final String fromId;
  late final Type type;

  Message.fromJson(Map<String, dynamic> json)
      : msg = json['msg'].toString(),
        toId = json['toId'].toString(),
        read = json['read'].toString(),
        sent = json['sent'].toString(),
        fromId = json['fromId'].toString() {
    final typeString = json['type'].toString().toLowerCase();
    if (typeString == 'text') {
      type = Type.text;
    } else if (typeString == 'image') {
      type = Type.image;
    } else {
      throw ArgumentError('Invalid message type: $typeString');
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    return data;
  }
}

enum Type { text, image }
