import 'package:equatable/equatable.dart';

class ContactModel extends Equatable {
  const ContactModel(this.contactPhone);
  final String contactPhone;
  factory ContactModel.fromMap(Map<String, dynamic> map) =>
      ContactModel(map['contactPhone'] as String);
  Map<String, dynamic> toMap() => {'contactPhone': contactPhone};
  @override
  List<Object?> get props => [contactPhone];
}
