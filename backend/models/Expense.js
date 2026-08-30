const mongoose = require('mongoose');

const CATEGORIES = [
  'Food & Drinks',
  'Transportation',
  'Shopping',
  'Entertainment',
  'Bills',
  'Health',
  'Other'
];

const PAYMENT_METHODS = [
  'Cash',
  'Card',
  'UPI',
  'Bank Transfer'
];

const expenseSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true
    },
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0.01, 'Amount must be greater than zero']
    },
    category: {
      type: String,
      required: [true, 'Category is required'],
      enum: {
        values: CATEGORIES,
        message: 'Invalid category'
      }
    },
    payment: {
      type: String,
      required: [true, 'Payment method is required'],
      enum: {
        values: PAYMENT_METHODS,
        message: 'Invalid payment method'
      }
    },
    date: {
      type: Date,
      required: [true, 'Date is required']
    }
  },
  {
    timestamps: true
  }
);

expenseSchema.index({ date: -1 });
expenseSchema.index({ title: 'text' });

expenseSchema.set('toJSON', {
  virtuals: true,
  transform: (doc, ret) => {
    ret.id = ret._id.toString();
    delete ret._id;
    delete ret.__v;
    return ret;
  }
});

const Expense = mongoose.model('Expense', expenseSchema);

module.exports = {
  Expense,
  CATEGORIES,
  PAYMENT_METHODS
};
