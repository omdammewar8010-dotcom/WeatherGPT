import 'package:flutter_test/flutter_test.dart';
import 'package:ner_landslideguard/features/authentication/data/models/user_model.dart';
import 'package:ner_landslideguard/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('Auth Model & RBAC Unit Tests', () {
    test('UserModel.demoCitizen has citizen role and Tawang district', () {
      final citizen = UserModel.demoCitizen;
      expect(citizen.role, UserRole.citizen);
      expect(citizen.isCitizen, isTrue);
      expect(citizen.isFieldOfficer, isFalse);
      expect(citizen.district, 'Tawang');
      expect(citizen.state, 'Arunachal Pradesh');
    });

    test('UserModel.demoOfficer has field officer role and badge number', () {
      final officer = UserModel.demoOfficer;
      expect(officer.role, UserRole.fieldOfficer);
      expect(officer.isFieldOfficer, isTrue);
      expect(officer.badgeNumber, isNotNull);
    });

    test('UserModel.demoAdmin has authorityAdmin role', () {
      final admin = UserModel.demoAdmin;
      expect(admin.role, UserRole.authorityAdmin);
      expect(admin.isAuthorityAdmin, isTrue);
      expect(admin.district, 'Papum Pare');
    });

    test('UserRole.fromString maps string representations safely', () {
      expect(UserRole.fromString('citizen'), UserRole.citizen);
      expect(UserRole.fromString('field_officer'), UserRole.fieldOfficer);
      expect(UserRole.fromString('authority_admin'), UserRole.authorityAdmin);
      expect(UserRole.fromString('admin'), UserRole.authorityAdmin);
      expect(UserRole.fromString(null), UserRole.citizen);
    });
  });
}
