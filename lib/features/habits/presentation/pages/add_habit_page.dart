import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:habit_tracker/core/theme/app_motion.dart';
import 'package:habit_tracker/core/theme/app_tokens.dart';
import 'package:habit_tracker/features/habits/domain/usecases/add_habit.dart';
import 'package:habit_tracker/features/habits/presentation/bloc/add_habit/add_habit_bloc.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/app_top_bar.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/bottom_action.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/hairline.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/points_picker.dart';
import 'package:habit_tracker/features/habits/presentation/widgets/toast.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AddHabitBloc>().add(
      AddHabitEvent.submitted(
        name: _nameController.text,
        description: _descriptionController.text,
        points: int.parse(_pointsController.text.trim()),
      ),
    );
  }

  /// Shows the counter only once the user is close to the limit.
  Widget? _counter(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) {
    if (maxLength == null || currentLength < maxLength * 0.8) return null;
    return Text(
      '$currentLength/$maxLength',
      style: context.tokens.text.bodySmall.copyWith(
        color: context.tokens.inkMuted,
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.space.s8),
      child: Text(
        text,
        style: tokens.text.kicker.copyWith(color: tokens.inkMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddHabitBloc, AddHabitState>(
      listener: (context, state) {
        switch (state) {
          case AddHabitSuccess():
            context.pop();
            showToast(context, 'Habit added');
          case AddHabitFailure(:final failure):
            showErrorSnackBar(context, failure.message);
          case AddHabitInitial() || AddHabitSubmitting():
            break;
        }
      },
      builder: (context, state) {
        final submitting = state is AddHabitSubmitting;
        final tokens = context.tokens;
        final text = tokens.text;
        final margin = tokens.space.screenMargin;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const AppTopBar(close: true),
                Expanded(
                  child: Form(
                    key: _formKey,
                    // Not a lazy list: Form.validate only sees built fields, so
                    // every field must stay mounted even when scrolled away.
                    // The header scrolls too, so the keyboard never squeezes
                    // the form.
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.fromLTRB(margin, 0, margin, 22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ADD', style: text.kicker),
                                const SizedBox(height: 6),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'New habit',
                                    style: text.headline.copyWith(fontSize: 44),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Hairline(),
                          Padding(
                            padding: EdgeInsets.all(margin),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _label(context, 'NAME'),
                                TextFormField(
                                  key: const Key('name-field'),
                                  controller: _nameController,
                                  enabled: !submitting,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLength: HabitRules.maxNameLength,
                                  buildCounter: _counter,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Drink 2L water',
                                  ),
                                  validator: (value) =>
                                      (value == null || value.trim().isEmpty)
                                      ? 'Please enter a name'
                                      : null,
                                ),
                                SizedBox(height: tokens.space.s24),
                                _label(context, 'DESCRIPTION'),
                                TextFormField(
                                  key: const Key('description-field'),
                                  controller: _descriptionController,
                                  enabled: !submitting,
                                  textInputAction: TextInputAction.next,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLength: HabitRules.maxDescriptionLength,
                                  buildCounter: _counter,
                                  minLines: 3,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    hintText: 'Why does this habit matter?',
                                    alignLabelWithHint: true,
                                  ),
                                ),
                                SizedBox(height: tokens.space.s24),
                                _label(context, 'POINTS PER COMPLETION'),
                                PointsPicker(
                                  controller: _pointsController,
                                  enabled: !submitting,
                                  onSubmitted: submitting ? null : _submit,
                                ),
                                SizedBox(height: tokens.space.s8),
                                Text(
                                  'Earned each time you mark it done.',
                                  style: text.bodySmall.copyWith(
                                    color: tokens.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BottomAction(
                  child: OutlinedButton(
                    onPressed: submitting ? null : _submit,
                    child: AnimatedSwitcher(
                      duration: AppMotion.of(context, AppMotion.fast),
                      child: submitting
                          ? Semantics(
                              key: const ValueKey('saving'),
                              liveRegion: true,
                              label: 'Saving',
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: tokens.accent,
                                ),
                              ),
                            )
                          : const Text('Save habit', key: ValueKey('save')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
