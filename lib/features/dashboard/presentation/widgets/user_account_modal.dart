import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/domain/entities/user.dart';

class DashboardUserAvatar extends StatelessWidget {
  final User user;

  const DashboardUserAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return CircleAvatar(
      radius: 18,
      backgroundColor: t.primary,
      backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
      child: user.photoUrl == null
          ? Text(
              user.initials,
              style: TextStyle(
                color: t.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }
}

class UserAccountModal extends StatelessWidget {
  final User user;

  const UserAccountModal({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Hero(
            tag: 'user_avatar',
            child: CircleAvatar(
              radius: 36,
              backgroundColor: t.primary,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(
                      user.initials,
                      style: TextStyle(
                        color: t.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.displayName ?? user.firstName,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'Agência', value: '0001'),
          const SizedBox(height: 12),
          _AccountInfoRow(
            label: 'Conta',
            value: '${user.id.substring(0, 5).toUpperCase()}-7',
          ),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'Chave Pix', value: user.email),
          const SizedBox(height: 12),
          _AccountInfoRow(label: 'E-mail', value: user.email),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: t.primary,
                foregroundColor: t.white,
              ),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Flexible(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
