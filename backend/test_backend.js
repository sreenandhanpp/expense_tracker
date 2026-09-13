const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const supertest = require('supertest');
const { app } = require('./app');

async function runTests() {
  console.log('Starting Backend End-to-End Tests with In-Memory MongoDB & Auth...');
  const mongod = await MongoMemoryServer.create({
    instance: {
      dbName: 'test_auth_db'
    }
  });
  const uri = mongod.getUri();

  await mongoose.connect(uri);
  console.log('Connected to In-Memory MongoDB');

  const request = supertest(app);
  let failed = false;

  const assert = (condition, message) => {
    if (!condition) {
      console.error(`❌ FAIL: ${message}`);
      failed = true;
    } else {
      console.log(`✅ PASS: ${message}`);
    }
  };

  try {
    // 1. GET /api/health (Public endpoint)
    const resHealth = await request.get('/api/health');
    assert(resHealth.status === 200 && resHealth.body.success === true, 'GET /api/health (Public)');

    // 2. Unauthenticated access check (Should fail with 401)
    const resUnauth = await request.get('/api/expenses');
    assert(resUnauth.status === 401 && resUnauth.body.success === false, 'GET /api/expenses (Unauthenticated rejected with 401)');

    // 3. Authenticate User 1 via POST /api/auth/google
    const resAuth1 = await request.post('/api/auth/google').send({
      idToken: 'mock-token-alice'
    });
    assert(resAuth1.status === 200 && resAuth1.body.data.token !== undefined, 'POST /api/auth/google (User 1 - Alice)');
    const tokenUser1 = resAuth1.body.data.token;
    const authHeaderUser1 = { Authorization: `Bearer ${tokenUser1}` };

    // 4. Authenticate User 2 via POST /api/auth/google
    const resAuth2 = await request.post('/api/auth/google').send({
      idToken: 'mock-token-bob'
    });
    assert(resAuth2.status === 200 && resAuth2.body.data.token !== undefined, 'POST /api/auth/google (User 2 - Bob)');
    const tokenUser2 = resAuth2.body.data.token;
    const authHeaderUser2 = { Authorization: `Bearer ${tokenUser2}` };

    // 5. GET /api/auth/me for User 1
    const resMe = await request.get('/api/auth/me').set(authHeaderUser1);
    assert(resMe.status === 200 && resMe.body.data.email === 'alice@example.com', 'GET /api/auth/me');

    // 6. GET /api/categories (Authenticated)
    const resCat = await request.get('/api/categories').set(authHeaderUser1);
    assert(resCat.status === 200 && resCat.body.data.includes('Food & Drinks'), 'GET /api/categories');

    // 7. GET /api/payment-methods (Authenticated)
    const resPay = await request.get('/api/payment-methods').set(authHeaderUser1);
    assert(resPay.status === 200 && resPay.body.data.includes('Card'), 'GET /api/payment-methods');

    // 8. User 1 creates Expense 1: Spotify ($20.98)
    const exp1Data = {
      title: 'Spotify',
      amount: 20.98,
      category: 'Entertainment',
      payment: 'Card',
      date: '2026-03-10T00:00:00.000Z'
    };
    const resCreate1 = await request.post('/api/expenses').set(authHeaderUser1).send(exp1Data);
    assert(resCreate1.status === 201 && resCreate1.body.data.id !== undefined, 'POST /api/expenses (Spotify by Alice)');
    const spotifyId = resCreate1.body.data.id;

    // 9. User 1 creates Expense 2: Dining out ($16.20)
    const exp2Data = {
      title: 'Dining out',
      amount: 16.20,
      category: 'Food & Drinks',
      payment: 'UPI',
      date: '2026-03-09T00:00:00.000Z'
    };
    const resCreate2 = await request.post('/api/expenses').set(authHeaderUser1).send(exp2Data);
    assert(resCreate2.status === 201 && resCreate2.body.data.title === 'Dining out', 'POST /api/expenses (Dining out by Alice)');
    const diningId = resCreate2.body.data.id;

    // 10. User 1 GET /api/expenses (Should return 2 expenses)
    const resList1 = await request.get('/api/expenses').set(authHeaderUser1);
    assert(resList1.status === 200 && resList1.body.data.length === 2, 'GET /api/expenses (User 1 has 2 expenses)');

    // 11. User 2 GET /api/expenses (User Isolation: Should return 0 expenses)
    const resList2 = await request.get('/api/expenses').set(authHeaderUser2);
    assert(resList2.status === 200 && resList2.body.data.length === 0, 'GET /api/expenses (User 2 has 0 expenses - Data Isolation Verified)');

    // 12. User 2 attempts to GET User 1\'s expense (Should return 404)
    const resUnauthorizedGet = await request.get(`/api/expenses/${spotifyId}`).set(authHeaderUser2);
    assert(resUnauthorizedGet.status === 404, 'GET /api/expenses/:id (User 2 cannot view User 1\'s expense)');

    // 13. Search filter for User 1
    const resSearch = await request.get('/api/expenses?search=SPOTIFY').set(authHeaderUser1);
    assert(resSearch.status === 200 && resSearch.body.data.length === 1 && resSearch.body.data[0].title === 'Spotify', 'GET /api/expenses?search=SPOTIFY');

    // 14. Update Expense for User 1
    const resUpdate = await request.put(`/api/expenses/${spotifyId}`).set(authHeaderUser1).send({
      title: 'Spotify Premium',
      amount: 25.00
    });
    assert(resUpdate.status === 200 && resUpdate.body.data.title === 'Spotify Premium' && resUpdate.body.data.amount === 25.00, 'PUT /api/expenses/:id');

    // 15. User 1 GET /api/summary
    const resSummary1 = await request.get('/api/summary?refDate=2026-03-10').set(authHeaderUser1);
    assert(resSummary1.status === 200 && resSummary1.body.data.totalSpending === 41.20, 'GET /api/summary (User 1)');

    // 16. User 2 GET /api/summary (Should be 0)
    const resSummary2 = await request.get('/api/summary?refDate=2026-03-10').set(authHeaderUser2);
    assert(resSummary2.status === 200 && resSummary2.body.data.totalSpending === 0, 'GET /api/summary (User 2 - 0 total spending)');

    // 17. User 1 GET /api/suggestions
    const resSugg = await request.get('/api/suggestions?query=spot').set(authHeaderUser1);
    assert(resSugg.status === 200 && resSugg.body.data.length === 1 && resSugg.body.data[0].title === 'Spotify Premium', 'GET /api/suggestions');

    // 18. User 1 DELETE expense
    const resDelete = await request.delete(`/api/expenses/${diningId}`).set(authHeaderUser1);
    assert(resDelete.status === 200 && resDelete.body.success === true, 'DELETE /api/expenses/:id');

    // 19. Validation Errors Test
    const resBadAmount = await request.post('/api/expenses').set(authHeaderUser1).send({
      title: 'Bad Amount',
      amount: -10,
      category: 'Food & Drinks',
      payment: 'Cash'
    });
    assert(resBadAmount.status === 400 && resBadAmount.body.success === false, 'Validation Error: negative amount');

    // 20. User Isolation Test
    const resAuthNewUser = await request.post('/api/auth/google').send({
      idToken: 'mock-token-newuser@gmail.com'
    });
    const tokenNewUser = resAuthNewUser.body.data.token;
    const resNewUserExpenses = await request.get('/api/expenses').set({ Authorization: `Bearer ${tokenNewUser}` });
    assert(resNewUserExpenses.status === 200 && resNewUserExpenses.body.data.length === 0, 'New user gets fresh start (0 expenses, no legacy data)');

  } catch (err) {
    console.error('Test execution error:', err);
    failed = true;
  } finally {
    await mongoose.disconnect();
    await mongod.stop();
  }

  if (failed) {
    console.error('❌ SOME TESTS FAILED');
    process.exit(1);
  } else {
    console.log('🎉 ALL BACKEND TESTS PASSED SUCCESSFULLY!');
  }
}

runTests();
