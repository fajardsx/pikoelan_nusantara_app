import 'package:equatable/equatable.dart';

/// Model status permission CRUD actions.
class PermissionStatusEntity extends Equatable {
  final bool canAdd;
  final bool canEdit;
  final bool canDel;

  const PermissionStatusEntity({
    required this.canAdd,
    required this.canEdit,
    required this.canDel,
  });

  factory PermissionStatusEntity.fromJson(Map<String, dynamic> json) {
    return PermissionStatusEntity(
      canAdd: json['canAdd'] as bool? ?? false,
      canEdit: json['canEdit'] as bool? ?? false,
      canDel: json['canDel'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'canAdd': canAdd,
    'canEdit': canEdit,
    'canDel': canDel,
  };

  @override
  List<Object?> get props => [canAdd, canEdit, canDel];
}
