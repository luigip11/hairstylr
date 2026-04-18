import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'booking_support.dart';

const _accentBlue = Color(0xFF355DDB);
const _accentBlueDark = Color(0xFF2748B4);
const _heroBlueTop = Color(0xFF7BC7FF);
const _heroBlueBottom = Color(0xFF4F83FF);

class PublicBookingScreen extends StatefulWidget {
  const PublicBookingScreen({super.key});

  @override
  State<PublicBookingScreen> createState() => _PublicBookingScreenState();
}

class _PublicBookingScreenState extends State<PublicBookingScreen> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = dateOnly(DateTime.now());
  late DateTime _visibleMonth;
  String? _selectedServiceId;
  TimeSlot? _selectedSlot;
  bool _submitting = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _visibleMonth = DateTime(_selectedDate.year, _selectedDate.month);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _bookAppointment(SalonService service) async {
    final selectedSlot = _selectedSlot;
    if (selectedSlot == null) {
      return;
    }

    setState(() {
      _submitting = true;
      _feedbackMessage = null;
    });

    final docId =
        '${dateKey(selectedSlot.start)}_${twoDigits(selectedSlot.start.hour)}${twoDigits(selectedSlot.start.minute)}';

    try {
      await FirebaseFirestore.instance
          .collection('appointments')
          .doc(docId)
          .set({
            'customerName': _nameController.text.trim(),
            'serviceId': service.id,
            'serviceName': service.name,
            'serviceDurationMinutes': service.durationMinutes ?? 0,
            'notes': _notesController.text.trim(),
            'status': 'requested',
            'scheduledFor': selectedSlot.start,
            'scheduledDateKey': dateKey(selectedSlot.start),
            'slotLabel': formatTimeRange(selectedSlot.start, selectedSlot.end),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) {
        return;
      }

      setState(() {
        _feedbackMessage =
            'Richiesta inviata per ${service.name} il ${formatDate(_selectedDate)} alle ${formatTime(selectedSlot.start)}.';
        _selectedSlot = null;
        _nameController.clear();
        _notesController.clear();
      });
    } on FirebaseException catch (error) {
      setState(() {
        _feedbackMessage = switch (error.code) {
          'permission-denied' =>
            'Prenotazione non consentita. Pubblica prima le regole Firestore aggiornate.',
          _ => 'Prenotazione non riuscita: ${error.message ?? error.code}',
        };
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
      if (_selectedDate.year != _visibleMonth.year ||
          _selectedDate.month != _visibleMonth.month) {
        _selectedDate = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
        _selectedSlot = null;
      }
    });
  }

  List<DateTime?> _calendarCells() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leading = firstDay.weekday - 1;
    final cells = <DateTime?>[];

    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }

    for (var day = 1; day <= daysInMonth; day++) {
      cells.add(DateTime(_visibleMonth.year, _visibleMonth.month, day));
    }

    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return cells;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('services')
            .where('active', isEqualTo: true)
            .snapshots(),
        builder: (context, servicesSnapshot) {
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('availability')
                .doc('default_week')
                .snapshots(),
            builder: (context, availabilitySnapshot) {
              final services = servicesSnapshot.hasData
                  ? servicesSnapshot.data!.docs
                        .map(SalonService.fromDocument)
                        .toList(growable: false)
                  : const <SalonService>[];
              final orderedServices = services.toList(growable: false)
                ..sort((left, right) {
                  const order = {
                    'piega': 0,
                    'taglio': 1,
                    'colore': 2,
                    'altro': 3,
                  };
                  return (order[left.id] ?? 999).compareTo(
                    order[right.id] ?? 999,
                  );
                });
              final availability = availabilitySnapshot.hasData
                  ? AvailabilitySchedule.fromDocument(
                      availabilitySnapshot.data!,
                    )
                  : null;

              if (_selectedServiceId == null && orderedServices.isNotEmpty) {
                _selectedServiceId = orderedServices.first.id;
              }

              final selectedService = orderedServices
                  .cast<SalonService?>()
                  .firstWhere(
                    (service) => service?.id == _selectedServiceId,
                    orElse: () => orderedServices.isNotEmpty
                        ? orderedServices.first
                        : null,
                  );

              final slots = availability != null
                  ? buildSlotsForDate(
                      _selectedDate,
                      availability.windowsForDate(_selectedDate),
                    )
                  : const <TimeSlot>[];

              final canSubmit =
                  !_submitting &&
                  selectedService != null &&
                  _selectedSlot != null &&
                  _nameController.text.trim().isNotEmpty;

              return SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 980;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _PosterHeader(
                            onAdminTap: () =>
                                Navigator.of(context).pushNamed('/admin'),
                          ),
                          const SizedBox(height: 20),
                          if (servicesSnapshot.connectionState ==
                                  ConnectionState.waiting ||
                              availabilitySnapshot.connectionState ==
                                  ConnectionState.waiting)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (selectedService == null ||
                              availability == null)
                            const _InfoPanel(
                              title: 'Setup iniziale richiesto',
                              body:
                                  'Servizi o disponibilita non ancora pronti. Entra nell area admin per inizializzare la piattaforma.',
                            )
                          else
                            Wrap(
                              spacing: 20,
                              runSpacing: 20,
                              children: [
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 60) * 0.6
                                      : constraints.maxWidth,
                                  child: _SectionShell(
                                    title: 'Scegli il giorno',
                                    subtitle: 'Visualizza gli slot disponibili',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _MonthHeader(
                                          visibleMonth: _visibleMonth,
                                          onPrevious: () => _changeMonth(-1),
                                          onNext: () => _changeMonth(1),
                                        ),
                                        const SizedBox(height: 16),
                                        _MonthGrid(
                                          dates: _calendarCells(),
                                          selectedDate: _selectedDate,
                                          onSelect: (date) {
                                            setState(() {
                                              _selectedDate = date;
                                              _visibleMonth = DateTime(
                                                date.year,
                                                date.month,
                                              );
                                              _selectedSlot = null;
                                              _feedbackMessage = null;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Servizi',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        Wrap(
                                          spacing: 12,
                                          runSpacing: 12,
                                          children: orderedServices
                                              .map(
                                                (service) => _ChoicePill(
                                                  label: service.name,
                                                  selected:
                                                      service.id ==
                                                      _selectedServiceId,
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedServiceId =
                                                          service.id;
                                                      _selectedSlot = null;
                                                      _feedbackMessage = null;
                                                    });
                                                  },
                                                ),
                                              )
                                              .toList(growable: false),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          'Orari disponibili',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                        const SizedBox(height: 12),
                                        if (slots.isEmpty)
                                          const Text(
                                            'Nessuno slot disponibile per il giorno selezionato.',
                                          )
                                        else
                                          Wrap(
                                            spacing: 10,
                                            runSpacing: 10,
                                            children: slots
                                                .map(
                                                  (slot) => _ChoicePill(
                                                    label: formatTimeRange(
                                                      slot.start,
                                                      slot.end,
                                                    ),
                                                    selected:
                                                        _selectedSlot?.start ==
                                                        slot.start,
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedSlot = slot;
                                                        _feedbackMessage = null;
                                                      });
                                                    },
                                                  ),
                                                )
                                                .toList(growable: false),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: isWide
                                      ? (constraints.maxWidth - 60) * 0.4
                                      : constraints.maxWidth,
                                  child: _SectionShell(
                                    title: 'Conferma prenotazione',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _SummaryRow(
                                          label: 'Giorno',
                                          value: formatDate(_selectedDate),
                                        ),
                                        _SummaryRow(
                                          label: 'Servizio',
                                          value: selectedService.name,
                                        ),
                                        _SummaryRow(
                                          label: 'Orario',
                                          value: _selectedSlot == null
                                              ? 'Seleziona uno slot'
                                              : formatTimeRange(
                                                  _selectedSlot!.start,
                                                  _selectedSlot!.end,
                                                ),
                                        ),
                                        const SizedBox(height: 18),
                                        TextField(
                                          controller: _nameController,
                                          decoration: const InputDecoration(
                                            labelText: 'Nome cliente',
                                          ),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                        const SizedBox(height: 14),
                                        TextField(
                                          controller: _notesController,
                                          minLines: 3,
                                          maxLines: 4,
                                          decoration: const InputDecoration(
                                            labelText:
                                                'Note facoltative (colore, domicilio, richieste)',
                                          ),
                                        ),
                                        if (_feedbackMessage != null) ...[
                                          const SizedBox(height: 16),
                                          Text(
                                            _feedbackMessage!,
                                            style: TextStyle(
                                              color:
                                                  _feedbackMessage!.startsWith(
                                                    'Richiesta',
                                                  )
                                                  ? _accentBlueDark
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 18),
                                        FilledButton(
                                          onPressed: canSubmit
                                              ? () => _bookAppointment(
                                                  selectedService,
                                                )
                                              : null,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: _accentBlue,
                                            disabledBackgroundColor:
                                                const Color(0xFFD7DDEE),
                                            minimumSize: const Size.fromHeight(
                                              56,
                                            ),
                                          ),
                                          child: Text(
                                            _submitting
                                                ? 'Invio in corso...'
                                                : 'Conferma appuntamento',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PosterHeader extends StatelessWidget {
  const _PosterHeader({required this.onAdminTap});

  final VoidCallback onAdminTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_heroBlueTop, _heroBlueBottom],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Hairstylr',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAdminTap,
                child: const Text(
                  'Area admin',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Prenota il tuo appuntamento a domicilio.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Calendario completo del mese, scelta servizio e conferma rapida in pochi tocchi.',
            style: TextStyle(
              color: Color(0xFFF1F7FF),
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.title,
    this.subtitle,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      title: title,
      subtitle: body,
      child: const SizedBox.shrink(),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.visibleMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime visibleMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
        Expanded(
          child: Text(
            '${monthLong(visibleMonth)} ${visibleMonth.year}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.dates,
    required this.selectedDate,
    required this.onSelect,
  });

  final List<DateTime?> dates;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    return Column(
      children: [
        Row(
          children: weekdayLabels
              .map(
                (label) => Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF6A768E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final date = dates[index];
            if (date == null) {
              return const SizedBox.shrink();
            }

            final isSelected = isSameDate(date, selectedDate);
            final isToday = isSameDate(date, dateOnly(DateTime.now()));

            return InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelect(date),
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected ? _accentBlue : const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isToday && !isSelected
                        ? _accentBlue.withValues(alpha: 0.75)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: isSelected ? _accentBlue : const Color(0xFF1A2850),
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? _accentBlue : const Color(0xFFF1F5FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? _accentBlue : const Color(0xFFD9E3FF),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? _accentBlue : const Color(0xFF294190),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF61706B)),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
