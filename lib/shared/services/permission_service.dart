// lib/shared/services/permission_service.dart
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService extends GetxService {
  // Observable permission statuses
  final RxMap<Permission, PermissionStatus> permissionStatuses =
      <Permission, PermissionStatus>{}.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await checkAllPermissions();
  }

  Future<void> checkAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.storage,
      Permission.notification,
      Permission.location,
      Permission.contacts,
      Permission.microphone,
    ];

    for (final permission in permissions) {
      final status = await permission.status;
      permissionStatuses[permission] = status;
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    permissionStatuses[permission] = status;
    return status.isGranted;
  }

  Future<Map<Permission, PermissionStatus>> requestMultiplePermissions(
      List<Permission> permissions,
      ) async {
    final statuses = await permissions.request();
    permissionStatuses.addAll(statuses);
    return statuses;
  }

  bool isPermissionGranted(Permission permission) {
    return permissionStatuses[permission]?.isGranted ?? false;
  }

  bool areAllPermissionsGranted(List<Permission> permissions) {
    return permissions.every(isPermissionGranted);
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  PermissionStatus? getPermissionStatus(Permission permission) {
    return permissionStatuses[permission];
  }
}
