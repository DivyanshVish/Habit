# Habitry backend (Vercel)

Plain TypeScript handlers behind one HTTP endpoint, `POST /api/call`, run as
Vercel serverless functions. They use the Firebase Admin SDK, so they work on
the free Spark plan of Firebase (no Cloud Functions, no billing).

```
src/            handlers, pure logic (logic.ts, engine.ts), HTTP layer (http.ts)
api/call.ts     the endpoint
api/cron.ts     daily backstop that closes finished days
```

## One-time setup
1. Firebase console > Project settings > Service accounts > **Generate new
   private key**. Keep the file private. It has full access to your data and
   must never be committed or put in the app.
2. Install and log in: `npm i -g vercel` then `vercel login`.
3. From this folder (`functions/`) run `vercel` once to create the project.
   Answer `./` if it asks where your code is, and keep the default settings.
   (If you run it from the project root instead, answer `./functions`.)
4. Add two environment variables (Vercel dashboard > Settings > Environment
   Variables, for Production):
   - `FIREBASE_SERVICE_ACCOUNT` = the full contents of the JSON key file.
   - `CRON_SECRET` = any long random string.
   Add them with `vercel env add FIREBASE_SERVICE_ACCOUNT production` and
   `vercel env add CRON_SECRET production`.
5. `vercel --prod`, then note the address (for example
   `https://habitry.vercel.app`). A request without a login should answer 401:
   `curl -X POST <address>/api/call -H "content-type: application/json" -d '{"name":"ping"}'`
6. Deploy the rules and indexes (free): `firebase deploy --only firestore`.

## Run the app against it
```sh
flutter run --dart-define=API_BASE_URL=https://habitry.vercel.app
```

## Checks
```sh
npm install
npm run test:unit      # builds, then runs the Node tests (no network needed)
```

## What differs from a server that can react to database changes
- There are no triggers. The app calls `refreshCycle` when a screen opens and
  after each completion; it opens the day, recomputes it from the stored
  completions, and closes finished days. It only reads stored data, so calling
  it cannot change the numbers.
- A day is opened by the first request about it, so "who was eligible" is the
  member list at that moment.
- If nobody opens a habit for a day, the daily cron closes it, and the group
  streak counts that day as missed.
- There are no scheduled push reminders. Push is sent only for events caused by
  a request (invitation answered, group target reached).

## Reminders need a timer (one more free setup step)

Vercel's free cron only runs once a day, but reminders are due in 15 minute
windows. `GET /api/remind` sends the ones due now, so something has to call it
every 15 minutes with `Authorization: Bearer <CRON_SECRET>`. Any free pinger
works, for example cron-job.org:

1. Create a job with the URL `https://<your-project>.vercel.app/api/remind`
   and a schedule of every 15 minutes.
2. Add the header `Authorization: Bearer <your CRON_SECRET>`.

Without it, everything else works; only reminders never arrive. Reminders are
skipped during each person's quiet hours, use their own time zone, and say
nothing about the habit on the lock screen.

## After pulling these changes

```sh
firebase deploy --only firestore     # new rule for join requests, new indexes
cd functions && vercel --prod        # new server code
```
Index building takes a few minutes. A temporary "index is building" error right
after the deploy is normal.
