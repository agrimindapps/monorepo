# Enhanced Settings Components for Plantis

This directory contains enhanced settings components with plant-themed design and improved UX/UI for the Plantis app.

## 🌱 Components Overview

### 1. EnhancedSettingsItem
Enhanced version of the standard settings item with multiple types and improved interactions.

#### Features:
- **Type variants**: normal, premium, danger, info, success
- **Loading states**: Built-in loading indicators
- **Animations**: Smooth scale and hover animations
- **Haptic feedback**: Light impact on interactions
- **Premium indicators**: Special badges for premium features
- **Enhanced theming**: Plant-themed colors and styling

#### Usage:
```dart
EnhancedSettingsItem(
  icon: Icons.notifications_active,
  title: 'Notificações',
  subtitle: 'Configure quando ser notificado sobre tarefas',
  type: SettingsItemType.normal, // or premium, danger, info, success
  badge: 'NOVO', // Optional badge for premium items
  loading: false, // Show loading state
  onTap: () => context.push('/notifications-settings'),
  onLongPress: () => showContextMenu(), // Optional long press action
)
```

### 2. Premium Components

#### PremiumBadge
Plant-themed premium badge with customizable size and animation.

```dart
PremiumBadge(
  text: 'PRO',
  size: PremiumBadgeSize.medium,
  animated: true,
)
```

#### FeatureAvailabilityIndicator
Circular indicator showing feature availability status.

```dart
FeatureAvailabilityIndicator(
  isAvailable: true,
  isPremium: false,
  tooltip: 'Recurso disponível',
  onTap: () => showFeatureInfo(),
)
```

#### UpgradePrompt
Engaging upgrade prompt with plant-themed design.

```dart
UpgradePrompt(
  title: 'Desbloqueie o Poder das Plantas 🌱',
  description: 'Transforme seu jardim com recursos premium.',
  buttonText: 'Assinar Premium',
  onUpgrade: () => context.push('/premium'),
  features: [
    'Plantas ilimitadas',
    'Backup automático na nuvem',
    'Relatórios avançados',
  ],
)
```

#### PlantThemedPremiumIndicator
Animated indicator with plant-themed styling.

```dart
PlantThemedPremiumIndicator(
  isActive: false,
  label: 'GRÁTIS',
  onTap: () => showPremiumInfo(),
)
```

### 3. Settings Cards

#### SettingsCard
Interactive card with expandable content and category-based theming.

```dart
SettingsCard(
  title: 'Configurações do App',
  subtitle: 'Personalize sua experiência no Plantis',
  icon: Icons.settings,
  category: SettingsCardCategory.general,
  initiallyExpanded: false,
  children: [
    // EnhancedSettingsItem widgets here
  ],
)
```

#### QuickSettingsCard
Compact card for immediate actions.

```dart
QuickSettingsCard(
  title: 'Backup',
  icon: Icons.cloud_upload,
  color: PlantisColors.water,
  badge: '3', // Optional notification badge
  onTap: () => performBackup(),
)
```

## 🎨 Design System Integration

### Design Tokens
Extended design tokens provide consistent spacing, typography, and styling:

```dart
// Spacing
PlantisDesignTokens.spacing4 // 16px
PlantisDesignTokens.spacing6 // 24px

// Border Radius
PlantisDesignTokens.radiusLG // 12px
PlantisDesignTokens.radiusXL // 16px

// Animation Duration
PlantisDesignTokens.durationFast // 150ms
PlantisDesignTokens.durationMedium // 300ms

// Component specific
PlantisDesignTokens.settingsItemHeight // 56px
PlantisDesignTokens.cardPadding // 16px
```

### Settings Theme
Comprehensive theme configuration for settings components:

```dart
// Apply settings theme
Theme(
  data: SettingsTheme.applySettingsCustomizations(baseTheme),
  child: SettingsPage(),
)

// Get theme for brightness
final theme = SettingsTheme.getTheme(Brightness.light);
```

### Color Categories
Settings cards use category-based coloring:

- **General**: Primary green (`SettingsCardCategory.general`)
- **Account**: Leaf green (`SettingsCardCategory.account`)
- **Premium**: Sun yellow (`SettingsCardCategory.premium`)
- **Privacy**: Water blue (`SettingsCardCategory.privacy`)
- **Development**: Soil brown (`SettingsCardCategory.development`)

## 📱 Responsive Design

All components are designed to work across different screen sizes:

- **Mobile**: Optimized touch targets and spacing
- **Tablet**: Expanded layout with appropriate padding
- **Desktop**: Hover states and mouse interactions

## ♿ Accessibility

Components include accessibility features:

- **Semantic labels**: Proper accessibility labels
- **Touch targets**: Minimum 44px touch areas
- **High contrast**: WCAG compliant color ratios
- **Screen reader**: Compatible with screen readers
- **Haptic feedback**: Appropriate haptic responses

## 🔧 Technical Implementation

### Animation System
Components use coordinated animations:

- **Scale animations**: Press feedback (0.98x scale)
- **Hover animations**: Slight scale up (1.02x)
- **Expand animations**: Smooth content reveal
- **Glow effects**: Premium feature highlighting

### State Management
Enhanced state handling:

- **Loading states**: Built-in loading indicators
- **Disabled states**: Proper disabled styling
- **Interactive states**: Hover, pressed, focused

### Performance
Optimized for smooth performance:

- **Widget rebuilds**: Minimized unnecessary rebuilds
- **Animation controllers**: Proper disposal
- **Memory usage**: Efficient widget tree

## 🌿 Plant-Themed Design Language

The components follow a cohesive plant-themed design:

### Visual Elements
- **Green color palette**: Various shades of green
- **Natural gradients**: Soft, organic gradients
- **Leaf icons**: Eco-friendly iconography
- **Organic shapes**: Rounded corners and smooth curves

### Semantic Meanings
- **Leaf green**: Growth and life (account features)
- **Sun yellow**: Premium and energy (premium features)
- **Water blue**: Flow and protection (privacy/security)
- **Soil brown**: Foundation and development (dev tools)
- **Flower pink**: Beauty and special features (promotions)

### Animation Inspiration
- **Growth curves**: Organic ease-out animations
- **Leaf fall**: Natural gravity-based movements
- **Water flow**: Smooth, continuous animations
- **Sun rise**: Gentle, warming transitions

## 📋 Best Practices

### Component Usage
1. **Consistent types**: Use appropriate `SettingsItemType` for content
2. **Logical grouping**: Group related settings in cards
3. **Clear hierarchy**: Use proper heading levels
4. **Meaningful icons**: Choose descriptive icons

### Performance Tips
1. **Lazy loading**: Load expensive content when needed
2. **Animation limits**: Don't over-animate the interface
3. **State cleanup**: Properly dispose animation controllers
4. **Widget caching**: Cache expensive widgets when possible

### Accessibility Guidelines
1. **Touch targets**: Ensure 44px minimum touch areas
2. **Color contrast**: Maintain WCAG AA standards
3. **Screen readers**: Provide semantic labels
4. **Keyboard navigation**: Support keyboard interactions

## 🔄 Migration Guide

### From Standard Components

#### Old SettingsItem → New EnhancedSettingsItem
```dart
// Old
SettingsItem(
  icon: Icons.notifications,
  title: 'Notificações',
  subtitle: 'Configure notificações',
  onTap: onTap,
)

// New
EnhancedSettingsItem(
  icon: Icons.notifications_active,
  title: 'Notificações',
  subtitle: 'Configure notificações',
  type: SettingsItemType.normal,
  onTap: onTap,
)
```

#### Old SettingsSection → New SettingsCard
```dart
// Old
SettingsSection(
  title: 'App Settings',
  children: [...],
)

// New
SettingsCard(
  title: 'App Settings',
  subtitle: 'Customize your experience',
  icon: Icons.settings,
  category: SettingsCardCategory.general,
  children: [...],
)
```

This enhanced settings system provides a cohesive, beautiful, and functional user experience while maintaining the unique plant-themed identity of the Plantis app.