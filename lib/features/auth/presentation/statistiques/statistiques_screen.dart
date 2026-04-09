import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../emprunts/emprunts_provider.dart';

class StatistiquesScreen extends ConsumerWidget {
  const StatistiquesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Statistiques'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(summaryProvider);
          ref.invalidate(empruntsParDocumentProvider);
          ref.invalidate(documentsParCategorieProvider);
          ref.invalidate(retardsParMoisProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              summaryAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator()),
                error: (e, _) =>
                    Center(child: Text('Erreur: $e')),
                data: (summary) => _SummaryCards(summary: summary),
              ),
              const SizedBox(height: 24),

              // Most borrowed books
              _SectionTitle('📚 Livres les plus empruntés'),
              const SizedBox(height: 12),
              const _TopBooksChart(),
              const SizedBox(height: 24),

              // Documents by category
              _SectionTitle('🗂 Documents par catégorie'),
              const SizedBox(height: 12),
              const _CategoryPieChart(),
              const SizedBox(height: 24),

              // Overdue by month
              _SectionTitle('⚠️ Retards par mois'),
              const SizedBox(height: 12),
              const _RetardsChart(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Summary Cards ────────────────────────────────────────────────
class _SummaryCards extends StatelessWidget {
  final Map<String, int> summary;
  const _SummaryCards({required this.summary});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _SummaryCard(
          label: 'Documents',
          value: summary['totalDocuments'] ?? 0,
          icon: Icons.library_books,
          color: Colors.indigo,
        ),
        _SummaryCard(
          label: 'Utilisateurs',
          value: summary['totalUsers'] ?? 0,
          icon: Icons.people_outline,
          color: Colors.teal,
        ),
        _SummaryCard(
          label: 'Emprunts actifs',
          value: summary['empruntsActifs'] ?? 0,
          icon: Icons.book_outlined,
          color: Colors.green,
        ),
        _SummaryCard(
          label: 'En retard',
          value: summary['empruntsEnRetard'] ?? 0,
          icon: Icons.warning_outlined,
          color: Colors.red,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Top Books Horizontal Bar Chart ──────────────────────────────
class _TopBooksChart extends ConsumerWidget {
  const _TopBooksChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(empruntsParDocumentProvider);

    return _ChartCard(
      child: dataAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const _EmptyChart(
                message: 'Aucun emprunt enregistré.');
          }

          final entries = data.entries.toList();

          return Column(
            children: List.generate(entries.length, (i) {
              final entry = entries[i];
              final maxVal = entries
                  .map((e) => e.value)
                  .reduce((a, b) => a > b ? a : b);
              final ratio = entry.value / maxVal;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        entry.key.length > 12
                            ? '${entry.key.substring(0, 12)}…'
                            : entry.key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.indigo.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: ratio,
                            child: Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.indigo
                                    .withOpacity(0.6 + (0.4 * ratio)),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ─── Category Pie Chart ───────────────────────────────────────────
class _CategoryPieChart extends ConsumerWidget {
  const _CategoryPieChart();

  static const _categoryColors = {
    'livre': Colors.indigo,
    'magazine': Colors.teal,
    'dvd': Colors.orange,
    'support_pedagogique': Colors.purple,
  };

  static const _categoryLabels = {
    'livre': 'Livres',
    'magazine': 'Magazines',
    'dvd': 'DVDs',
    'support_pedagogique': 'Supports',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(documentsParCategorieProvider);

    return _ChartCard(
      child: dataAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const _EmptyChart(
                message: 'Aucun document enregistré.');
          }

          final total =
              data.values.fold(0, (sum, val) => sum + val);
          final sections = data.entries.map((entry) {
            final color =
                _categoryColors[entry.key] ?? Colors.grey;
            return PieChartSectionData(
              value: entry.value.toDouble(),
              color: color,
              title:
                  '${((entry.value / total) * 100).toStringAsFixed(0)}%',
              radius: 80,
              titleStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            );
          }).toList();

          return Row(
            children: [
              // Pie chart
              SizedBox(
                height: 180,
                width: 180,
                child: PieChart(
                  PieChartData(
                    sections: sections,
                    centerSpaceRadius: 30,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((entry) {
                    final color =
                        _categoryColors[entry.key] ?? Colors.grey;
                    final label =
                        _categoryLabels[entry.key] ?? entry.key;
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '$label (${entry.value})',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Overdue Bar Chart ────────────────────────────────────────────
class _RetardsChart extends ConsumerWidget {
  const _RetardsChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(retardsParMoisProvider);

    return _ChartCard(
      child: dataAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
        data: (data) {
          if (data.isEmpty) {
            return const _EmptyChart(
                message: 'Aucun retard enregistré. 🎉');
          }

          final entries = data.entries.toList();
          final maxVal = entries
              .map((e) => e.value)
              .reduce((a, b) => a > b ? a : b)
              .toDouble();

          return SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxVal + 1,
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value.toDouble(),
                        color: Colors.red[300],
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final index = val.toInt();
                        if (index >= entries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            entries[index].key,
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: true),
                borderData: FlBorderData(show: false),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final Widget child;
  const _ChartCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  final String message;
  const _EmptyChart({required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(message,
            style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}