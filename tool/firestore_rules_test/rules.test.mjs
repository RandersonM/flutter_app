import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  Timestamp,
  addDoc,
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';

const OWNER = 'alice';
const OTHER = 'bob';

let env;

const db = (uid) =>
  uid ? env.authenticatedContext(uid).firestore() : env.unauthenticatedContext().firestore();

const seed = (path, data) =>
  env.withSecurityRulesDisabled((ctx) => setDoc(doc(ctx.firestore(), path), data));

const daysAgo = (days) => Timestamp.fromMillis(Date.now() - days * 24 * 60 * 60 * 1000);

// ── Payloads exactly as the app writes them ──────────────────────────────
// Keep these in sync with the Dart serializers named next to each builder.

// UserProfileRepository.saveProfile (set merge).
const profile = (overrides = {}) => ({
  gender: 'male',
  age: 30,
  height_cm: 175,
  weight_kg: 72.5,
  waist_cm: null,
  chest_cm: null,
  arm_cm: null,
  hip_cm: null,
  thigh_cm: null,
  activity_level: 'moderate',
  goal: 'maintain',
  updated_at: serverTimestamp(),
  ...overrides,
});

// NotificationService.saveTokenToFirestore (set, no merge).
const token = (overrides = {}) => ({
  fcmToken: 'fcm-token-value',
  platform: 'ios',
  updatedAt: serverTimestamp(),
  ...overrides,
});

// CrewModel.toFirestore + FirestoreService.createUserDocument.
const crew = (overrides = {}) => ({
  name: 'Straw Hats',
  captain: null,
  viceCaptain: null,
  rolesFilled: [],
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  jollyRogerUrl: 'https://i.imgur.com/jolly.png',
  boatImageUrl: null,
  boatName: 'Going Merry',
  description: 'Nakama',
  members: [],
  tags: ['east blue'],
  userId: OWNER,
  ...overrides,
});

// Same keys on update, minus userId (FirestoreService.updateDocument).
const crewUpdate = (overrides = {}) => {
  const { userId, ...rest } = crew(overrides);
  return { ...rest, createdAt: daysAgo(30), ...overrides };
};

// CustomCharacterModel.toFirestoreWithEnglishKeys.
const characterFields = (overrides = {}) => ({
  name: 'Zoro',
  nickname: 'Pirate Hunter',
  devilFruit: null,
  haki: ['armament'],
  affiliations: ['Straw Hats'],
  occupation: ['swordsman'],
  image: 'https://i.imgur.com/zoro.png',
  fightingStyle: { name: 'Santoryu', type: 'swords', weapons: ['Wado'], attacks: null },
  bounty: '1111000000',
  signo: 'scorpio',
  crew: 'Straw Hats',
  status: 'alive',
  race: 'human',
  age: 21,
  birthDate: Timestamp.fromDate(new Date('2003-11-11')),
  description: 'Lost again.',
  ...overrides,
});

const characterCreate = (overrides = {}) => ({
  ...characterFields(),
  userId: OWNER,
  createdAt: serverTimestamp(),
  updatedAt: serverTimestamp(),
  ...overrides,
});

// planner_repository._goalModelToDocument + createUserDocument.
const goal = (overrides = {}) => ({
  title: 'Read One Piece',
  description: 'From chapter 1',
  deadline: Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)),
  createdAt: serverTimestamp(),
  category: 'personal',
  status: 'notStarted',
  progress: 0,
  tags: ['manga'],
  notes: null,
  userId: OWNER,
  updatedAt: serverTimestamp(),
  ...overrides,
});

// WorkoutAssessmentModel.toJson with the service's Timestamp.fromDate(now).
const assessment = (overrides = {}) => ({
  id: null,
  user_id: OWNER,
  month_year: '2026-10',
  gender: 'male',
  age: 30,
  height: 175,
  weight: 72.5,
  waist: 80,
  bmi: 23.7,
  waist_to_height_ratio: 0.46,
  body_fat_percentage: 15.2,
  health_score: 82,
  workout_days_goal: 4,
  activity_level: 'moderate',
  goal: 'maintain',
  workout_days: [1, 3, 5],
  workout_plan: null,
  created_at: Timestamp.now(),
  updated_at: Timestamp.now(),
  ...overrides,
});

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-opfan',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});

beforeEach(() => env.clearFirestore());

after(() => env.cleanup());

describe('users/{uid}', () => {
  it('lets the owner save their body profile, with nulls', async () => {
    await assertSucceeds(setDoc(doc(db(OWNER), `users/${OWNER}`), profile(), { merge: true }));
    await assertSucceeds(getDoc(doc(db(OWNER), `users/${OWNER}`)));
  });

  it('keeps legacy profile fields untouched on a merge', async () => {
    await seed(`users/${OWNER}`, { email: 'a@b.c', display_name: 'Alice', age: 20 });
    await assertSucceeds(setDoc(doc(db(OWNER), `users/${OWNER}`), profile(), { merge: true }));
  });

  it('hides a profile from other users and guests', async () => {
    await seed(`users/${OWNER}`, { age: 30 });
    await assertFails(getDoc(doc(db(OTHER), `users/${OWNER}`)));
    await assertFails(getDoc(doc(db(null), `users/${OWNER}`)));
  });

  it('rejects unknown keys, wrong types and a client-chosen timestamp', async () => {
    const ref = doc(db(OWNER), `users/${OWNER}`);
    await assertFails(setDoc(ref, profile({ isAdmin: true }), { merge: true }));
    await assertFails(setDoc(ref, profile({ age: 'thirty' }), { merge: true }));
    await assertFails(setDoc(ref, profile({ updated_at: daysAgo(10) }), { merge: true }));
  });
});

describe('user_tokens/{uid}', () => {
  it('lets a user save and refresh their own FCM token', async () => {
    await assertSucceeds(setDoc(doc(db(OWNER), `user_tokens/${OWNER}`), token()));
    await assertSucceeds(
      setDoc(doc(db(OWNER), `user_tokens/${OWNER}`), token({ platform: 'android' })),
    );
  });

  it('rejects writing or reading another user token', async () => {
    await seed(`user_tokens/${OWNER}`, { fcmToken: 't' });
    await assertFails(setDoc(doc(db(OTHER), `user_tokens/${OWNER}`), token()));
    await assertFails(getDoc(doc(db(OTHER), `user_tokens/${OWNER}`)));
  });

  it('rejects extra keys, unknown platforms and empty tokens', async () => {
    const ref = doc(db(OWNER), `user_tokens/${OWNER}`);
    await assertFails(setDoc(ref, token({ topic: 'all' })));
    await assertFails(setDoc(ref, token({ platform: 'web' })));
    await assertFails(setDoc(ref, token({ fcmToken: '' })));
  });
});

describe('crews', () => {
  beforeEach(() => seed('crews/c1', { ...crewUpdate(), updatedAt: daysAgo(1), userId: OWNER }));

  it('lets the owner create a crew the way the app does', async () => {
    await assertSucceeds(addDoc(collection(db(OWNER), 'crews'), crew()));
  });

  it('lets any signed-in user browse crews, but not guests', async () => {
    await assertSucceeds(getDoc(doc(db(OTHER), 'crews/c1')));
    await assertSucceeds(getDocs(collection(db(OTHER), 'crews')));
    await assertFails(getDoc(doc(db(null), 'crews/c1')));
  });

  it('lets the owner update every crew field and delete', async () => {
    const member = { characterId: 'ch1', name: 'Zoro', nickname: null, role: 'swordsman', bounty: '0' };
    await assertSucceeds(
      updateDoc(
        doc(db(OWNER), 'crews/c1'),
        crewUpdate({ members: [member], rolesFilled: ['swordsman'], captain: '' }),
      ),
    );
    await assertSucceeds(deleteDoc(doc(db(OWNER), 'crews/c1')));
  });

  it("rejects another user's update or delete", async () => {
    await assertFails(updateDoc(doc(db(OTHER), 'crews/c1'), crewUpdate({ name: 'Stolen' })));
    await assertFails(deleteDoc(doc(db(OTHER), 'crews/c1')));
  });

  it('rejects handing a crew to another user', async () => {
    await assertFails(updateDoc(doc(db(OWNER), 'crews/c1'), { ...crewUpdate(), userId: OTHER }));
  });

  it('rejects creating a crew in someone else name', async () => {
    await assertFails(addDoc(collection(db(OWNER), 'crews'), crew({ userId: OTHER })));
  });

  it('rejects junk: extra keys, inline images, huge names and back-dated createdAt', async () => {
    const crews = collection(db(OWNER), 'crews');
    await assertFails(addDoc(crews, crew({ hacked: true })));
    await assertFails(addDoc(crews, crew({ jollyRogerUrl: `data:image/png;base64,${'A'.repeat(5000)}` })));
    await assertFails(addDoc(crews, crew({ name: 'x'.repeat(101) })));
    await assertFails(addDoc(crews, crew({ createdAt: daysAgo(365) })));
    await assertFails(addDoc(crews, crew({ name: '' })));
  });

  it('honours legacy crews that store the owner in ownerId', async () => {
    await seed('crews/legacy', { ...crewUpdate(), ownerId: OWNER });
    await assertSucceeds(updateDoc(doc(db(OWNER), 'crews/legacy'), crewUpdate({ name: 'Renamed' })));
    await assertFails(updateDoc(doc(db(OTHER), 'crews/legacy'), crewUpdate({ name: 'Stolen' })));
  });
});

describe('custom_characters', () => {
  beforeEach(() =>
    seed('custom_characters/d1', { ...characterFields(), userId: OWNER, createdAt: daysAgo(10), updatedAt: daysAgo(10) }),
  );

  it('lets the owner create and query characters the way the app does', async () => {
    await assertSucceeds(addDoc(collection(db(OWNER), 'custom_characters'), characterCreate()));
    await assertSucceeds(
      addDoc(
        collection(db(OWNER), 'custom_characters'),
        characterCreate({ nickname: null, haki: null, fightingStyle: null, birthDate: null, bounty: '' }),
      ),
    );
    const own = query(collection(db(OWNER), 'custom_characters'), where('userId', '==', OWNER));
    await assertSucceeds(getDocs(own));
  });

  it('lets the owner edit and delete', async () => {
    await assertSucceeds(
      updateDoc(
        doc(db(OWNER), 'custom_characters/d1'),
        { ...characterFields({ crew: 'Heart Pirates' }), updatedAt: serverTimestamp() },
      ),
    );
    await assertSucceeds(deleteDoc(doc(db(OWNER), 'custom_characters/d1')));
  });

  it('hides characters from other users, including an unfiltered query', async () => {
    await assertFails(getDoc(doc(db(OTHER), 'custom_characters/d1')));
    await assertFails(getDocs(collection(db(OTHER), 'custom_characters')));
    await assertFails(
      updateDoc(doc(db(OTHER), 'custom_characters/d1'), { ...characterFields(), updatedAt: serverTimestamp() }),
    );
  });

  it('rejects another owner, extra keys, inline images and changing userId', async () => {
    const chars = collection(db(OWNER), 'custom_characters');
    await assertFails(addDoc(chars, characterCreate({ userId: OTHER })));
    await assertFails(addDoc(chars, characterCreate({ power: 9000 })));
    await assertFails(addDoc(chars, characterCreate({ image: `data:image/png;base64,${'A'.repeat(5000)}` })));
    await assertFails(
      updateDoc(doc(db(OWNER), 'custom_characters/d1'), { userId: OTHER, updatedAt: serverTimestamp() }),
    );
  });
});

describe('planner', () => {
  beforeEach(() => seed('planner/d1', { ...goal(), createdAt: daysAgo(5), updatedAt: daysAgo(5) }));

  it('lets the owner create and query goals the way the app does', async () => {
    await assertSucceeds(addDoc(collection(db(OWNER), 'planner'), goal()));
    const own = query(collection(db(OWNER), 'planner'), where('userId', '==', OWNER));
    await assertSucceeds(getDocs(own));
  });

  it('lets the owner record progress, edit and delete', async () => {
    const ref = doc(db(OWNER), 'planner/d1');
    await assertSucceeds(
      updateDoc(ref, {
        progress: 42.5,
        notes: '[17/10/2026 10:00] 42.5%: halfway',
        status: 'inProgress',
        updatedAt: serverTimestamp(),
      }),
    );
    const { userId, ...editable } = goal({ title: 'Read all of One Piece', createdAt: daysAgo(5) });
    await assertSucceeds(updateDoc(ref, editable));
    await assertSucceeds(deleteDoc(ref));
  });

  it('hides goals from other users and blocks their changes', async () => {
    await assertFails(getDoc(doc(db(OTHER), 'planner/d1')));
    await assertFails(getDocs(collection(db(OTHER), 'planner')));
    await assertFails(updateDoc(doc(db(OTHER), 'planner/d1'), { progress: 100, updatedAt: serverTimestamp() }));
  });

  it('rejects invalid categories, statuses, progress and owners', async () => {
    const goals = collection(db(OWNER), 'planner');
    await assertFails(addDoc(goals, goal({ category: 'crime' })));
    await assertFails(addDoc(goals, goal({ status: 'done' })));
    await assertFails(addDoc(goals, goal({ progress: 150 })));
    await assertFails(addDoc(goals, goal({ userId: OTHER })));
    await assertFails(updateDoc(doc(db(OWNER), 'planner/d1'), { userId: OTHER, updatedAt: serverTimestamp() }));
  });
});

describe('workout_assessments', () => {
  beforeEach(() =>
    seed('workout_assessments/w1', { ...assessment(), id: null, created_at: daysAgo(20), updated_at: daysAgo(20) }),
  );

  it('lets the owner create and query their month', async () => {
    await assertSucceeds(addDoc(collection(db(OWNER), 'workout_assessments'), assessment()));
    const own = query(
      collection(db(OWNER), 'workout_assessments'),
      where('user_id', '==', OWNER),
      where('month_year', '==', '2026-10'),
    );
    await assertSucceeds(getDocs(own));
  });

  it('lets the owner save the whole assessment, workout days and plan', async () => {
    const ref = doc(db(OWNER), 'workout_assessments/w1');
    await assertSucceeds(updateDoc(ref, assessment({ id: 'w1', weight: 71 })));
    await assertSucceeds(updateDoc(ref, { workout_days: [1, 2, 3], updated_at: Timestamp.now() }));
    await assertSucceeds(
      updateDoc(ref, {
        workout_plan: { splits: [{ name: 'A', exercises: [{ name: 'Squat', volume: '4x8' }] }] },
        updated_at: Timestamp.now(),
      }),
    );
  });

  it('hides assessments from other users and blocks reassigning them', async () => {
    await assertFails(getDoc(doc(db(OTHER), 'workout_assessments/w1')));
    await assertFails(updateDoc(doc(db(OWNER), 'workout_assessments/w1'), { user_id: OTHER, updated_at: Timestamp.now() }));
  });

  it('rejects back-dated records, foreign ids and malformed months', async () => {
    const assessments = collection(db(OWNER), 'workout_assessments');
    await assertFails(addDoc(assessments, assessment({ created_at: daysAgo(400) })));
    await assertFails(addDoc(assessments, assessment({ month_year: 'october' })));
    await assertFails(addDoc(assessments, assessment({ extra: 1 })));
    await assertFails(updateDoc(doc(db(OWNER), 'workout_assessments/w1'), assessment({ id: 'other-doc' })));
  });
});

describe('featuredCharacters', () => {
  it('is publicly readable and never client-writable', async () => {
    await seed('featuredCharacters/luffy', { name: 'Luffy' });
    await assertSucceeds(getDoc(doc(db(null), 'featuredCharacters/luffy')));
    await assertFails(setDoc(doc(db(OWNER), 'featuredCharacters/zoro'), { userId: OWNER }));
    await assertFails(updateDoc(doc(db(OWNER), 'featuredCharacters/luffy'), { name: 'X' }));
  });
});

describe('collections without client access', () => {
  const removed = [
    'formData',
    'duels',
    'userSettings',
    'userFavorites',
    'userActivity',
    'onePieceCharacters',
    'devilFruits',
    'ai_usage',
  ];

  for (const name of removed) {
    it(`denies ${name}`, async () => {
      await seed(`${name}/d1`, { userId: OWNER });
      await assertFails(getDoc(doc(db(OWNER), `${name}/d1`)));
      await assertFails(setDoc(doc(db(OWNER), `${name}/d2`), { userId: OWNER }));
    });
  }
});
