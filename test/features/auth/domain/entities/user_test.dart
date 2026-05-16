import 'package:flutter_test/flutter_test.dart';
import 'package:bytebankapp/features/auth/domain/entities/user.dart';

void main() {
  group('User.initials', () {
    test('retorna iniciais do primeiro e último nome quando displayName tem dois nomes', () {
      const user = User(id: '1', email: 'test@test.com', displayName: 'João Silva');
      expect(user.initials, equals('JS'));
    });

    test('retorna inicial maiúscula quando displayName tem um único nome', () {
      const user = User(id: '1', email: 'test@test.com', displayName: 'João');
      expect(user.initials, equals('J'));
    });

    test('retorna inicial do e-mail quando displayName é nulo', () {
      const user = User(id: '1', email: 'david@test.com');
      expect(user.initials, equals('D'));
    });

    test('retorna inicial do e-mail quando displayName é string vazia', () {
      const user = User(id: '1', email: 'ana@test.com', displayName: '');
      expect(user.initials, equals('A'));
    });

    test('retorna iniciais em maiúsculas quando displayName está em minúsculas', () {
      const user = User(id: '1', email: 'test@test.com', displayName: 'maria oliveira');
      expect(user.initials, equals('MO'));
    });
  });

  group('User.firstName', () {
    test('retorna o primeiro nome quando displayName está definido', () {
      const user = User(id: '1', email: 'test@test.com', displayName: 'Carlos Mendes');
      expect(user.firstName, equals('Carlos'));
    });

    test('retorna apenas o nome quando displayName tem um único nome', () {
      const user = User(id: '1', email: 'test@test.com', displayName: 'Lucas');
      expect(user.firstName, equals('Lucas'));
    });

    test('retorna prefixo do e-mail quando displayName é nulo', () {
      const user = User(id: '1', email: 'beatriz@empresa.com');
      expect(user.firstName, equals('beatriz'));
    });

    test('retorna prefixo do e-mail quando displayName é string vazia', () {
      const user = User(id: '1', email: 'pedro@empresa.com', displayName: '');
      expect(user.firstName, equals('pedro'));
    });
  });
}
