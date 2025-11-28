import 'package:flutter/material.dart';

import '../../domain/entities/power_up_entity.dart';
import '../../domain/entities/enums.dart';

/// HUD widget showing active power-ups
class ActivePowerUpsHud extends StatelessWidget {
  final List<ActivePowerUp> activePowerUps;

  const ActivePowerUpsHud({
    super.key,
    required this.activePowerUps,
  });

  @override
  Widget build(BuildContext context) {
    final validPowerUps = activePowerUps.where((p) => !p.isExpired).toList();

    if (validPowerUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      top: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: validPowerUps.map((powerUp) {
          return ActivePowerUpIndicator(powerUp: powerUp);
        }).toList(),
      ),
    );
  }
}

/// Individual active power-up indicator
class ActivePowerUpIndicator extends StatelessWidget {
  final ActivePowerUp powerUp;

  const ActivePowerUpIndicator({
    super.key,
    required this.powerUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getPowerUpColor(powerUp.type),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _getPowerUpColor(powerUp.type).withOpacity(0.3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            powerUp.type.emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 8),
          if (powerUp.usesRemaining != null)
            // Use-based indicator
            Text(
              'x${powerUp.usesRemaining}',
              style: TextStyle(
                color: _getPowerUpColor(powerUp.type),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            )
          else
            // Time-based indicator
            SizedBox(
              width: 40,
              height: 8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: powerUp.remainingPercent,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation(
                    _getPowerUpColor(powerUp.type),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.slowMotion:
        return Colors.purple;
      case PowerUpType.doublePoints:
        return Colors.amber;
      case PowerUpType.shrink:
        return Colors.green;
      case PowerUpType.ghost:
        return Colors.grey;
      case PowerUpType.magnet:
        return Colors.red;
    }
  }
}

/// Compact power-up status for game HUD
class PowerUpStatusCompact extends StatelessWidget {
  final List<ActivePowerUp> activePowerUps;

  const PowerUpStatusCompact({
    super.key,
    required this.activePowerUps,
  });

  @override
  Widget build(BuildContext context) {
    final validPowerUps = activePowerUps.where((p) => !p.isExpired).toList();

    if (validPowerUps.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: validPowerUps.map((powerUp) {
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getPowerUpColor(powerUp.type).withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(powerUp.type.emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 2),
              if (powerUp.usesRemaining != null)
                Text(
                  'x${powerUp.usesRemaining}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                Text(
                  '${powerUp.remainingSeconds.toInt()}s',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getPowerUpColor(PowerUpType type) {
    switch (type) {
      case PowerUpType.shield:
        return Colors.blue;
      case PowerUpType.slowMotion:
        return Colors.purple;
      case PowerUpType.doublePoints:
        return Colors.amber;
      case PowerUpType.shrink:
        return Colors.green;
      case PowerUpType.ghost:
        return Colors.grey;
      case PowerUpType.magnet:
        return Colors.red;
    }
  }
}
