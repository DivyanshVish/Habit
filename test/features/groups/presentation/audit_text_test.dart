import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/features/groups/domain/entities/group_entities.dart';
import 'package:habit_tracker/features/groups/presentation/utils/audit_text.dart';

AuditEntry _entry(
  String action, {
  String actor = 'a',
  Map<String, Object?> details = const {},
}) => AuditEntry(
  id: 'x',
  action: action,
  actorUid: actor,
  at: null,
  details: details,
);

void main() {
  const names = {'a': 'Ann', 'b': 'Bob'};

  test('says who did what', () {
    expect(
      describeAudit(_entry('group.created'), names),
      'Ann created the group',
    );
    expect(describeAudit(_entry('member.left'), names), 'Ann left the group');
    expect(
      describeAudit(_entry('group.archived'), names),
      'Ann archived the group',
    );
  });

  test('names the other person in the action', () {
    expect(
      describeAudit(_entry('member.removed', details: {'uid': 'b'}), names),
      'Ann removed Bob',
    );
    expect(
      describeAudit(_entry('group.ownership', details: {'to': 'b'}), names),
      'Ann made Bob the owner',
    );
    expect(
      describeAudit(
        _entry('member.role', details: {'uid': 'b', 'role': 'admin'}),
        names,
      ),
      'Ann made Bob an admin',
    );
    expect(
      describeAudit(
        _entry('member.role', details: {'uid': 'b', 'role': 'member'}),
        names,
      ),
      'Ann made Bob a member',
    );
  });

  test('join requests read naturally', () {
    expect(
      describeAudit(_entry('member.requested'), names),
      'Ann asked to join',
    );
    expect(
      describeAudit(
        _entry('member.request_approved', details: {'uid': 'b'}),
        names,
      ),
      'Ann let Bob in',
    );
    expect(
      describeAudit(
        _entry('member.request_rejected', details: {'uid': 'b'}),
        names,
      ),
      'Ann declined Bob',
    );
  });

  test('habits mention their name when the log has it', () {
    expect(
      describeAudit(_entry('habit.created', details: {'name': 'Run'}), names),
      'Ann added the habit "Run"',
    );
    expect(describeAudit(_entry('habit.created'), names), 'Ann added a habit');
  });

  test('people the group no longer knows are "Someone"', () {
    expect(
      describeAudit(_entry('member.left', actor: 'gone'), names),
      'Someone left the group',
    );
    expect(
      describeAudit(_entry('member.removed', details: {'uid': 'gone'}), names),
      'Ann removed Someone',
    );
    expect(
      describeAudit(_entry('member.left', actor: ''), names),
      'Someone left the group',
    );
  });

  test('an action from a newer version still reads as a sentence', () {
    expect(describeAudit(_entry('something.new'), names), 'Ann made a change');
  });

  test('a moved account reads naturally', () {
    expect(
      describeAudit(_entry('member.accountMoved'), names),
      'Ann moved to a new account',
    );
  });
}
