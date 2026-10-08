// =============================================================================
// lab04_start.dart — Week 4 Lab: "The Unbreakable Screen"
// IMT01303305 Visual Programming · Module 1 · UI Layer
//
// SETUP (once, about two minutes)
//   flutter create lab04
//   copy this file      → lab04/lib/lab04_start.dart
//   copy lab04_test.dart → lab04/test/lab04_test.dart
//   Needs Flutter 3.22 or newer (flutter --version).
//
// HOW TO RUN IT
//   flutter run -t lib/lab04_start.dart -d chrome     (or -d windows / -d macos)
//
//   The panel on the left is a device harness. Pick a screen size, rotate it,
//   swap the data, open a keyboard, switch to dark mode, add a notch. No
//   emulator profiles needed. On a real phone or an Android emulator, set
//   kLabHarness = false below and use the device itself.
//
//   flutter test test/lab04_test.dart
//   Runs the nine tests automatically (sixteen cases). Right now every one fails.
//
// THIS FILE COMPILES AND RUNS. Open it on "Small phone" and count the
// yellow-and-black stripes. Then change one setting at a time and count again.
//
// YOUR TASK  (full brief: weeks/W04_Layout_and_Responsiveness.md, section 4)
//   Make MenuScreen pass all nine tests — in the harness AND in flutter test.
//
//     1  Small phone, 320 dp        4  Landscape, all three       7  500 items
//     2  Large phone, 430 dp        5  A 200-character name       8  Keyboard open
//     3  Tablet, 800 dp             6  Zero items                 9  Dark mode
//
//   Bonus: "Notch + gesture bar" — nothing you can tap sits under the
//   gesture bar.
//
// RULES
//   • Fix the constraint relationship, not the number. A new hard-coded width
//     or height that makes the stripes disappear is not a fix.
//   • Every text that can be long gets maxLines and an overflow strategy.
//   • No shrinkWrap: true on a long list. A list you do not control is lazy.
//   • The breakpoint uses LayoutBuilder and CHANGES the structure at 600 dp.
//   • Zero items shows an empty state — icon, message, action — and that
//     widget gets key: const Key('empty-state') so the tests can find it.
//   • Keep the class names and the Keys already in the file. The tests use them.
//   • For every fix, be ready to say which part of the rule was broken:
//     constraints go down, sizes go up, parent sets position.
//
// There are more than ten defects. Several are the same mistake in a new place.
// Read the overflow message — widget, axis, pixels — BEFORE you change code.
//
// NOT this week's problem: navigation and state management. Leave _qty where
// it is. Do not edit the harness at the bottom of the file.
//
// Done when: you run all nine tests in the harness in front of a classmate,
// with no stripes and no clipped text, and flutter test is green.
// Commit: feat: responsive menu screen with adaptive breakpoints and empty state
// =============================================================================

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// true  → run inside the device harness (desktop or web: -d chrome / -d windows).
/// false → run the bare app on an emulator or a real phone.
const bool kLabHarness = true;

void main() => runApp(kLabHarness ? const LabHarness() : const Lab04App());

// -----------------------------------------------------------------------------
// Data. Week 7 replaces all of this with a repository. Leave it alone.
// -----------------------------------------------------------------------------

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
    this.promo = false,
  });

  final String id;
  final String name;
  final String category;
  final int price;
  final String description;
  final bool promo;
}

const String kStoreName = 'Warung Digital — Kampus Kota Makassar';
const String kStoreHours = 'Buka setiap hari · 08.00–21.00';

/// Filter chips. 'Semua' and 'Promo' are filters, the rest are real categories.
const List<String> kCategories = [
  'Semua',
  'Makanan',
  'Minuman',
  'Camilan',
  'Promo',
  'Paket Hemat',
];

const List<MenuItem> kMenu = [
  MenuItem(id: 'm1', name: 'Nasi Goreng Spesial', category: 'Makanan', price: 18000, promo: true),
  MenuItem(id: 'm2', name: 'Mie Ayam Bakso', category: 'Makanan', price: 15000),
  MenuItem(id: 'm3', name: 'Sate Ayam (10 tusuk)', category: 'Makanan', price: 25000),
  MenuItem(id: 'm4', name: 'Ayam Geprek Sambal Matah', category: 'Makanan', price: 20000, promo: true),
  MenuItem(id: 'm5', name: 'Pisang Goreng Keju', category: 'Camilan', price: 12000),
  MenuItem(id: 'm6', name: 'Es Teh Manis', category: 'Minuman', price: 5000),
  MenuItem(id: 'm7', name: 'Kopi Susu Gula Aren', category: 'Minuman', price: 12000),
  MenuItem(id: 'm8', name: 'Paket Hemat Ayam + Es Teh', category: 'Paket Hemat', price: 23000, promo: true),
];

/// Exactly 200 characters. Test 5.
const String kLongName =
    'Nasi Goreng Spesial Kampung dengan Telur Mata Sapi, Ayam Suwir Pedas, '
    'Sate Usus, Kerupuk Udang Sidoarjo, Acar Timun Segar, Sambal Matah Bali, '
    'dan Taburan Bawang Goreng Renyah Khas Kota Makassar Sulsel';

const List<MenuItem> kLongNameMenu = [
  MenuItem(id: 'long', name: kLongName, category: 'Makanan', price: 45000, promo: true),
  ...kMenu,
];

const List<String> _kinds = ['Makanan', 'Minuman', 'Camilan', 'Paket Hemat'];

/// Test 7. In Module 3 this list comes from your PHP API and could be any size.
final List<MenuItem> kBigMenu = List<MenuItem>.generate(
  500,
  (i) => MenuItem(
    id: 'g$i',
    name: 'Menu ${i + 1}',
    category: _kinds[i % _kinds.length],
    price: 5000 + (i % 20) * 1000,
    promo: i % 9 == 0,
  ),
);

// -----------------------------------------------------------------------------
// Week 3 leftovers: spacing, theme, helpers. These are already correct.
// -----------------------------------------------------------------------------

abstract final class Gap {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
}

abstract final class AppTheme {
  static const Color _seed = Color(0xFF00696E);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
    );
  }
}

/// 18000 → 'Rp 18.000'
String rupiah(int value) {
  final digits = value.toString();
  final out = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
    out.write(digits[i]);
  }
  return 'Rp $out';
}

IconData iconFor(String category) => switch (category) {
      'Makanan' => Icons.rice_bowl,
      'Minuman' => Icons.local_cafe,
      'Camilan' => Icons.cookie,
      'Paket Hemat' => Icons.lunch_dining,
      _ => Icons.restaurant,
    };

class Lab04App extends StatelessWidget {
  const Lab04App({
    super.key,
    this.items = kMenu,
    this.themeMode = ThemeMode.system,
  });

  final List<MenuItem> items;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warung Digital',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Lets you drag horizontal lists with a mouse in Chrome or on desktop.
      scrollBehavior: const MaterialScrollBehavior()
          .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
      home: MenuScreen(items: items),
    );
  }
}

// -----------------------------------------------------------------------------
// The screen. Everything from here to the harness is yours to fix.
// -----------------------------------------------------------------------------

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key, required this.items});

  final List<MenuItem> items;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _query = '';
  String _category = kCategories.first;
  final Map<String, int> _qty = {};

  List<MenuItem> get _visible => widget.items.where((item) {
        final matchesQuery =
            _query.isEmpty || item.name.toLowerCase().contains(_query.toLowerCase());
        final matchesCategory = switch (_category) {
          'Semua' => true,
          'Promo' => item.promo,
          _ => item.category == _category,
        };
        return matchesQuery && matchesCategory;
      }).toList();

  int get _count => _qty.values.fold(0, (sum, n) => sum + n);

  int get _total {
    var total = 0;
    for (final item in widget.items) {
      total += (_qty[item.id] ?? 0) * item.price;
    }
    return total;
  }

  void _add(MenuItem item) {
    setState(() => _qty[item.id] = (_qty[item.id] ?? 0) + 1);
  }

  void _order() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pesanan dikirim: $_count item')),
    );
    setState(() => _qty.clear());
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final promos = widget.items.where((item) => item.promo).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(title: const Text('Menu')),
          bottomNavigationBar: CartBar(
            count: _count,
            total: _total,
            onOrder: _order,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const StoreHeader(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Gap.md),
                      child: TextField(
                        key: const Key('search-field'),
                        decoration: const InputDecoration(
                          hintText: 'Cari menu…',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ),
                    const SizedBox(height: Gap.sm),
                    CategoryBar(
                      selected: _category,
                      onSelected: (category) => setState(() => _category = category),
                    ),
                    if (promos.isNotEmpty) PromoStrip(items: promos),
                  ],
                ),
              ),
              if (visible.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    key: const Key('empty-state'),
                    padding: const EdgeInsets.all(Gap.xl),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 64, color: Colors.grey),
                        const SizedBox(height: Gap.sm),
                        Text(
                          'Menu tidak ditemukan',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                )
              else if (isTablet)
                SliverPadding(
                  padding: const EdgeInsets.all(Gap.md),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: Gap.md,
                      crossAxisSpacing: Gap.md,
                      childAspectRatio: 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MenuCard(
                        item: visible[index],
                        quantity: _qty[visible[index].id] ?? 0,
                        onAdd: () => _add(visible[index]),
                      ),
                      childCount: visible.length,
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => MenuTile(
                      item: visible[index],
                      quantity: _qty[visible[index].id] ?? 0,
                      onAdd: () => _add(visible[index]),
                    ),
                    childCount: visible.length,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class StoreHeader extends StatelessWidget {
  const StoreHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(Gap.md),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.storefront, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: Gap.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kStoreName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Gap.xs),
                Text(
                  kStoreHours,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Gap.md),
          Icon(Icons.star_rounded, size: 20, color: cs.tertiary),
          const SizedBox(width: Gap.xs),
          Text(
            '4.8',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class CategoryBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md),
        itemCount: kCategories.length,
        itemBuilder: (context, index) {
          final cat = kCategories[index];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: Gap.xs),
            child: FilterChip(
              label: Text(
                cat,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(cat),
            ),
          );
        },
      ),
    );
  }
}

class PromoStrip extends StatelessWidget {
  final List<MenuItem> items;

  const PromoStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.md),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: Gap.sm),
            child: PromoCard(item: items[index]),
          );
        },
      ),
    );
  }
}

class PromoCard extends StatelessWidget {
  final MenuItem item;

  const PromoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 200,
      child: Card(
        color: cs.tertiaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(Gap.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'PROMO HARI INI',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: Gap.xs),
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: cs.onTertiaryContainer,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Gap.xs),
              Text(
                rupiah(item.price),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: cs.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;

  const MenuTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.md,
        vertical: Gap.xs,
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Gap.sm),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.description.isNotEmpty) ...[
                      const SizedBox(height: Gap.xs),
                      Text(
                        item.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: Gap.xs),
                    Text(
                      rupiah(item.price),
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.sm),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;

  const MenuCard({
    super.key,
    required this.item,
    required this.quantity,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gap.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: Gap.xs),
                    Text(
                      item.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    rupiah(item.price),
                    style: Theme.of(context).textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: onAdd,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartBar extends StatelessWidget {
  final int count;
  final int total;
  final VoidCallback onOrder;

  const CartBar({
    super.key,
    required this.count,
    required this.total,
    required this.onOrder,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.md,
            vertical: Gap.sm,
          ),
          child: Row(
            children: [
              Icon(Icons.shopping_bag_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: Gap.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$count item',
                      style: Theme.of(context).textTheme.labelMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      rupiah(total),
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Gap.xs),
              FilledButton(
                key: const Key('order-button'),
                onPressed: count > 0 ? onOrder : null,
                child: const Text('Pesan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// LAB HARNESS — do not edit below this line.
// =============================================================================

enum _Device {
  small('Small phone', Size(320, 568)),
  large('Large phone', Size(430, 932)),
  tablet('Tablet', Size(800, 1280));

  const _Device(this.label, this.size);

  final String label;
  final Size size;
}

enum _Data {
  normal('Normal'),
  longName('200-char name'),
  empty('Zero items'),
  big('500 items');

  const _Data(this.label);

  final String label;

  List<MenuItem> get items => switch (this) {
        _Data.normal => kMenu,
        _Data.longName => kLongNameMenu,
        _Data.empty => const <MenuItem>[],
        _Data.big => kBigMenu,
      };
}

class LabHarness extends StatefulWidget {
  const LabHarness({super.key});

  @override
  State<LabHarness> createState() => _LabHarnessState();
}

class _LabHarnessState extends State<LabHarness> {
  _Device _device = _Device.small;
  _Data _data = _Data.normal;
  bool _landscape = false;
  bool _keyboard = false;
  bool _dark = false;
  bool _insets = false;

  Size get _screen => _landscape ? _device.size.flipped : _device.size;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 04 · device harness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: const Color(0xFF455A64)),
      home: Builder(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 280, child: _panel(context)),
                const VerticalDivider(width: 1),
                Expanded(child: _stage(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(BuildContext context) {
    final text = Theme.of(context).textTheme;

    Widget group(String title, List<Widget> chips) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.labelLarge),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Lab 04 · device harness', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Try every combination. Keep the debug console open: '
          '"A RenderFlex overflowed by … pixels" names the widget, the axis and the amount.',
          style: text.bodySmall,
        ),
        const SizedBox(height: 20),
        group('Screen', [
          for (final d in _Device.values)
            ChoiceChip(
              label: Text(d.label),
              selected: _device == d,
              onSelected: (_) => setState(() => _device = d),
            ),
        ]),
        group('Orientation', [
          ChoiceChip(
            label: const Text('Portrait'),
            selected: !_landscape,
            onSelected: (_) => setState(() => _landscape = false),
          ),
          ChoiceChip(
            label: const Text('Landscape'),
            selected: _landscape,
            onSelected: (_) => setState(() => _landscape = true),
          ),
        ]),
        group('Data', [
          for (final d in _Data.values)
            ChoiceChip(
              label: Text(d.label),
              selected: _data == d,
              onSelected: (_) => setState(() => _data = d),
            ),
        ]),
        group('Conditions', [
          FilterChip(
            label: const Text('Keyboard open'),
            selected: _keyboard,
            onSelected: (v) => setState(() => _keyboard = v),
          ),
          FilterChip(
            label: const Text('Dark mode'),
            selected: _dark,
            onSelected: (v) => setState(() => _dark = v),
          ),
          FilterChip(
            label: const Text('Notch + gesture bar'),
            selected: _insets,
            onSelected: (v) => setState(() => _insets = v),
          ),
        ]),
        Text(
          'Screen: ${_screen.width.toInt()} × ${_screen.height.toInt()} dp',
          style: text.bodySmall,
        ),
      ],
    );
  }

  Widget _stage(BuildContext context) {
    final size = _screen;
    final keyboard = _keyboard ? (_landscape ? 180.0 : 260.0) : 0.0;
    final padding = !_insets
        ? EdgeInsets.zero
        : _landscape
            ? const EdgeInsets.only(left: 32, bottom: 20)
            : const EdgeInsets.only(top: 32, bottom: 20);
    // While the keyboard is up, phones report no bottom padding.
    final safe = keyboard > 0 ? padding.copyWith(bottom: 0) : padding;
    final media = MediaQuery.of(context).copyWith(
      size: size,
      padding: safe,
      viewPadding: safe,
      viewInsets: EdgeInsets.only(bottom: keyboard),
    );

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D1F),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox.fromSize(
                  size: size,
                  child: MediaQuery(
                    data: media,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Lab04App(
                            key: ValueKey(_data),
                            items: _data.items,
                            themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
                          ),
                        ),
                        if (padding.top > 0)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            height: padding.top,
                            child: const IgnorePointer(child: _FakeStatusBar()),
                          ),
                        if (padding.left > 0)
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: padding.left,
                            child: const IgnorePointer(
                              child: ColoredBox(color: Color(0xFF000000)),
                            ),
                          ),
                        if (safe.bottom > 0)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: safe.bottom,
                            child: const IgnorePointer(child: _FakeGestureBar()),
                          ),
                        if (keyboard > 0)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: keyboard,
                            child: const IgnorePointer(child: _FakeKeyboard()),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FakeStatusBar extends StatelessWidget {
  const _FakeStatusBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('9:41', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ),
        Center(
          child: Container(
            width: 84,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF000000),
              borderRadius: BorderRadius.circular(11),
            ),
          ),
        ),
      ],
    );
  }
}

class _FakeGestureBar extends StatelessWidget {
  const _FakeGestureBar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 120,
        height: 5,
        decoration: BoxDecoration(
          color: const Color(0x99000000),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _FakeKeyboard extends StatelessWidget {
  const _FakeKeyboard();

  static const List<String> _rows = ['qwertyuiop', 'asdfghjkl', 'zxcvbnm'];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF2B2F33),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            for (final row in _rows)
              Expanded(
                child: Row(
                  children: [
                    for (final letter in row.split('')) Expanded(child: _Key(letter)),
                  ],
                ),
              ),
            const Expanded(
              child: Row(
                children: [
                  Expanded(flex: 2, child: _Key('123')),
                  Expanded(flex: 6, child: _Key('spasi')),
                  Expanded(flex: 2, child: _Key('⏎')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF4A4F55),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                label,
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}