const mongoose = require("mongoose");

const BillSchema = new mongoose.Schema({
  tenantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  landlordId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  rentAmount: {
    type: Number,
    required: true,
    default: 0,
  },
  electricityBill: {
    type: Number,
    required: true,
    default: 0,
  },
  waterBill: {
    type: Number,
    required: true,
    default: 0,
  },
  gasBill: {
    type: Number,
    required: true,
    default: 0,
  },
  totalAmount: {
    type: Number,
    required: true,
  },
  dueDate: {
    type: Date,
    required: true,
  },
  billDate: {
    type: Date,
    default: Date.now,
  },
  paidDate: {
    type: Date,
    default: null,
  },
  status: {
    type: String,
    enum: ["pending", "paid", "overdue", "cancelled"],
    default: "pending",
  },
  notes: {
    type: String,
    default: "",
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

// Calculate totalAmount before validation so required check passes
BillSchema.pre("validate", function () {
  // Ensure numeric values and compute totals synchronously
  this.rentAmount = Number(this.rentAmount) || 0;
  this.electricityBill = Number(this.electricityBill) || 0;
  this.waterBill = Number(this.waterBill) || 0;
  this.gasBill = Number(this.gasBill) || 0;
  this.totalAmount =
    this.rentAmount +
    this.electricityBill +
    this.waterBill +
    this.gasBill;
  this.updatedAt = Date.now();
});

module.exports = mongoose.model("Bill", BillSchema);
