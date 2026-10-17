import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../providers/providers.dart';
import '../widgets/common.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key});
  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  static const _options = [5, 10, 15, 20, 25];
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  int _points = 10;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(addHabitProvider)(
        name: _name.text,
        description: _desc.text,
        points: _points,
      );
      if (!mounted) return;
      Navigator.pop(context);
      showToast(context, 'Habit added');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Could not save');
    }
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t.toUpperCase(), style: kicker(C.n700)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(leading: const BackButton()),
    body: Form(
      key: _form,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ADD', style: kicker()),
                  const SizedBox(height: 6),
                  Text('New habit', style: heading(44)),
                ],
              ),
            ),
          ),
          const Hairline(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(26),
              children: [
                _label('Name'),
                TextFormField(
                  controller: _name,
                  maxLength: 40,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Drink 2L water',
                    counterText: '',
                  ),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? 'A habit needs a name.' : null,
                ),
                const SizedBox(height: 22),
                _label('Description'),
                TextFormField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: "Why it matters, or how you'll do it",
                  ),
                ),
                const SizedBox(height: 22),
                _label('Points per completion'),
                _PointsPicker(
                  options: _options,
                  value: _points,
                  onChanged: (v) => setState(() => _points = v),
                ),
                const SizedBox(height: 8),
                Text(
                  'Earned each time you mark it done.',
                  style: body(13, color: C.n700),
                ),
              ],
            ),
          ),
          BottomAction(
            child: OutlinedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: C.accent,
                      ),
                    )
                  : const Text('Save habit'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PointsPicker extends StatelessWidget {
  const _PointsPicker({
    required this.options,
    required this.value,
    required this.onChanged,
  });
  final List<int> options;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: C.divider),
      borderRadius: BorderRadius.circular(4),
    ),
    clipBehavior: Clip.antiAlias,
    child: Row(
      children: [
        for (final v in options)
          Expanded(
            child: InkWell(
              onTap: () => onChanged(v),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: v == value ? C.accent100 : null,
                  border: Border(
                    bottom: BorderSide(
                      color: v == value ? C.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  '$v',
                  style: heading(
                    20,
                    w: FontWeight.w600,
                    color: v == value ? C.accent700 : C.text,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
