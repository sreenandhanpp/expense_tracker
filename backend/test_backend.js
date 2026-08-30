const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const supertest = require('supertest');
const { app } = require('./app');
const { Expense } = require('./models/Expense');

async function runTests() {
  console.log('Starting Backend End-to-End Tests with In-Memory MongoDB...');
  const mongod = await MongoMemoryServer.create();
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
    // 1. GET /api/health
    const resHealth = await request.get('/api/health');
    assert(resHealth.status === 200 && resHealth.body.success === true, 'GET /api/health');

    // 2. GET /api/categories
    const resCat = await request.get('/api/categories');
    assert(resCat.status === 200 && resCat.body.data.includes('Food & Drinks'), 'GET /api/categories');

    // 3. GET /api/payment-methods
    const resPay = await request.get('/api/payment-methods');
    assert(resPay.status === 200 && resPay.body.data.includes('Card'), 'GET /api/payment-methods');

    // 4. POST /api/expenses (Create Expense 1: Spotify)
    const exp1Data = {
      title: 'Spotify',
      amount: 20.98,
      category: 'Entertainment',
      payment: 'Card',
      date: '2026-03-10T00:00:00.000Z'
    };
    const resCreate1 = await request.post('/api/expenses').send(exp1Data);
    assert(resCreate1.status === 201 && resCreate1.body.data.id !== undefined, 'POST /api/expenses (Spotify)');
    const spotifyId = resCreate1.body.data.id;

    // 5. POST /api/expenses (Create Expense 2: Dining out)
    const exp2Data = {
      title: 'Dining out',
      amount: 16.20,
      category: 'Food & Drinks',
      payment: 'UPI',
      date: '2026-03-09T00:00:00.000Z'
    };
    const resCreate2 = await request.post('/api/expenses').send(exp2Data);
    assert(resCreate2.status === 201 && resCreate2.body.data.title === 'Dining out', 'POST /api/expenses (Dining out)');
    const diningId = resCreate2.body.data.id;

    // 6. GET /api/expenses (List all)
    const resList = await request.get('/api/expenses');
    assert(resList.status === 200 && resList.body.data.length === 2, 'GET /api/expenses (all)');

    // 7. GET /api/expenses?search=spotify (Search filter case-insensitive)
    const resSearch = await request.get('/api/expenses?search=SPOTIFY');
    assert(resSearch.status === 200 && resSearch.body.data.length === 1 && resSearch.body.data[0].title === 'Spotify', 'GET /api/expenses?search=SPOTIFY');

    // 8. GET /api/expenses?category=Entertainment
    const resCategory = await request.get('/api/expenses?category=Entertainment');
    assert(resCategory.status === 200 && resCategory.body.data.length === 1, 'GET /api/expenses?category=Entertainment');

    // 9. GET /api/expenses?payment=UPI
    const resPayment = await request.get('/api/expenses?payment=UPI');
    assert(resPayment.status === 200 && resPayment.body.data.length === 1 && resPayment.body.data[0].payment === 'UPI', 'GET /api/expenses?payment=UPI');

    // 10. GET /api/expenses/:id
    const resGetSingle = await request.get(`/api/expenses/${spotifyId}`);
    assert(resGetSingle.status === 200 && resGetSingle.body.data.id === spotifyId, 'GET /api/expenses/:id');

    // 11. PUT /api/expenses/:id (Update Spotify to Spotify Premium)
    const resUpdate = await request.put(`/api/expenses/${spotifyId}`).send({
      title: 'Spotify Premium',
      amount: 25.00
    });
    assert(resUpdate.status === 200 && resUpdate.body.data.title === 'Spotify Premium' && resUpdate.body.data.amount === 25.00, 'PUT /api/expenses/:id');

    // 12. GET /api/summary
    const resSummary = await request.get('/api/summary?refDate=2026-03-10');
    assert(resSummary.status === 200 && resSummary.body.data.totalSpending === 41.20, 'GET /api/summary');

    // 13. GET /api/summary/trends
    const resTrends = await request.get('/api/summary/trends?refDate=2026-03-10');
    assert(resTrends.status === 200 && resTrends.body.data.values.length === 7, 'GET /api/summary/trends');

    // 14. GET /api/suggestions?query=spot
    const resSugg = await request.get('/api/suggestions?query=spot');
    assert(resSugg.status === 200 && resSugg.body.data.length === 1 && resSugg.body.data[0].title === 'Spotify Premium', 'GET /api/suggestions?query=spot');

    // 15. DELETE /api/expenses/:id
    const resDelete = await request.delete(`/api/expenses/${diningId}`);
    assert(resDelete.status === 200 && resDelete.body.success === true, 'DELETE /api/expenses/:id');

    // 16. Validation Errors Test
    const resBadAmount = await request.post('/api/expenses').send({
      title: 'Bad Amount',
      amount: -10,
      category: 'Food & Drinks',
      payment: 'Cash'
    });
    assert(resBadAmount.status === 400 && resBadAmount.body.success === false, 'Validation Error: negative amount');

    const resBadId = await request.get('/api/expenses/invalid_object_id');
    assert(resBadId.status === 404 && resBadId.body.success === false, 'Error: invalid ObjectId');

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
