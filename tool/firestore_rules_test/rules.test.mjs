import { readFileSync } from 'node:fs';
import { after, before, beforeEach, describe, it } from 'node:test';
import {
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from '@firebase/rules-unit-testing';
import {
  collection,
  deleteDoc,
  doc,
  getDoc,
  getDocs,
  query,
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

before(async () => {
  env = await initializeTestEnvironment({
    projectId: 'demo-opfan',
    firestore: { rules: readFileSync(new URL('../../firestore.rules', import.meta.url), 'utf8') },
  });
});

beforeEach(() => env.clearFirestore());

after(() => env.cleanup());

describe('users/{uid}', () => {
  it('lets the owner read and write their profile', async () => {
    await assertSucceeds(setDoc(doc(db(OWNER), `users/${OWNER}`), { age: 30 }));
    await assertSucceeds(getDoc(doc(db(OWNER), `users/${OWNER}`)));
  });

  it('hides a profile from other users and guests', async () => {
    await seed(`users/${OWNER}`, { age: 30 });
    await assertFails(getDoc(doc(db(OTHER), `users/${OWNER}`)));
    await assertFails(getDoc(doc(db(null), `users/${OWNER}`)));
  });
});

describe('user_tokens/{uid}', () => {
  it('lets a user save their own FCM token', async () => {
    await assertSucceeds(
      setDoc(doc(db(OWNER), `user_tokens/${OWNER}`), { fcmToken: 't', platform: 'ios' }),
    );
  });

  it('rejects writing or reading another user token', async () => {
    await seed(`user_tokens/${OWNER}`, { fcmToken: 't' });
    await assertFails(setDoc(doc(db(OTHER), `user_tokens/${OWNER}`), { fcmToken: 'x' }));
    await assertFails(getDoc(doc(db(OTHER), `user_tokens/${OWNER}`)));
  });
});

describe('crews', () => {
  beforeEach(() => seed('crews/c1', { name: 'Straw Hats', userId: OWNER }));

  it('lets any signed-in user browse crews, but not guests', async () => {
    await assertSucceeds(getDoc(doc(db(OTHER), 'crews/c1')));
    await assertSucceeds(getDocs(collection(db(OTHER), 'crews')));
    await assertFails(getDoc(doc(db(null), 'crews/c1')));
  });

  it("rejects another user's update or delete", async () => {
    await assertFails(updateDoc(doc(db(OTHER), 'crews/c1'), { name: 'Stolen' }));
    await assertFails(deleteDoc(doc(db(OTHER), 'crews/c1')));
  });

  it('lets the owner update and delete', async () => {
    await assertSucceeds(updateDoc(doc(db(OWNER), 'crews/c1'), { name: 'Mugiwara' }));
    await assertSucceeds(deleteDoc(doc(db(OWNER), 'crews/c1')));
  });

  it('rejects handing a crew to another user', async () => {
    await assertFails(updateDoc(doc(db(OWNER), 'crews/c1'), { userId: OTHER }));
  });

  it('rejects creating a crew in someone else name', async () => {
    await assertSucceeds(setDoc(doc(db(OWNER), 'crews/c2'), { name: 'Mine', userId: OWNER }));
    await assertFails(setDoc(doc(db(OWNER), 'crews/c3'), { name: 'Theirs', userId: OTHER }));
  });

  it('honours legacy crews that store the owner in ownerId', async () => {
    await seed('crews/legacy', { name: 'Old', ownerId: OWNER });
    await assertSucceeds(updateDoc(doc(db(OWNER), 'crews/legacy'), { name: 'Renamed' }));
    await assertFails(updateDoc(doc(db(OTHER), 'crews/legacy'), { name: 'Stolen' }));
  });
});

for (const collectionName of ['custom_characters', 'planner']) {
  describe(collectionName, () => {
    beforeEach(() => seed(`${collectionName}/d1`, { title: 'x', userId: OWNER }));

    it('lets the owner query their own documents', async () => {
      const own = query(collection(db(OWNER), collectionName), where('userId', '==', OWNER));
      await assertSucceeds(getDocs(own));
    });

    it('hides documents from other users, including an unfiltered query', async () => {
      await assertFails(getDoc(doc(db(OTHER), `${collectionName}/d1`)));
      await assertFails(getDocs(collection(db(OTHER), collectionName)));
    });

    it("rejects another user's update or delete", async () => {
      await assertFails(updateDoc(doc(db(OTHER), `${collectionName}/d1`), { title: 'y' }));
      await assertFails(deleteDoc(doc(db(OTHER), `${collectionName}/d1`)));
    });

    it('lets the owner create, update and delete, without changing userId', async () => {
      await assertSucceeds(setDoc(doc(db(OWNER), `${collectionName}/d2`), { userId: OWNER }));
      await assertFails(setDoc(doc(db(OWNER), `${collectionName}/d3`), { userId: OTHER }));
      await assertSucceeds(updateDoc(doc(db(OWNER), `${collectionName}/d1`), { title: 'y' }));
      await assertFails(updateDoc(doc(db(OWNER), `${collectionName}/d1`), { userId: OTHER }));
      await assertSucceeds(deleteDoc(doc(db(OWNER), `${collectionName}/d1`)));
    });
  });
}

describe('workout_assessments', () => {
  beforeEach(() =>
    seed('workout_assessments/w1', { user_id: OWNER, month_year: '2026-10' }),
  );

  it('lets the owner query and update their month', async () => {
    const own = query(
      collection(db(OWNER), 'workout_assessments'),
      where('user_id', '==', OWNER),
      where('month_year', '==', '2026-10'),
    );
    await assertSucceeds(getDocs(own));
    await assertSucceeds(updateDoc(doc(db(OWNER), 'workout_assessments/w1'), { weight: 80 }));
  });

  it('hides assessments from other users and blocks reassigning them', async () => {
    await assertFails(getDoc(doc(db(OTHER), 'workout_assessments/w1')));
    await assertFails(updateDoc(doc(db(OWNER), 'workout_assessments/w1'), { user_id: OTHER }));
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
  ];

  for (const name of removed) {
    it(`denies ${name}`, async () => {
      await seed(`${name}/d1`, { userId: OWNER });
      await assertFails(getDoc(doc(db(OWNER), `${name}/d1`)));
      await assertFails(setDoc(doc(db(OWNER), `${name}/d2`), { userId: OWNER }));
    });
  }
});
