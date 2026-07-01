const express = require("express");
const Payment = require("../models/Payment");
const Bill = require("../models/Bill");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ============ CREATE PAYMENT ============
router.post("/", authMiddleware, async (req, res) => {
  try {
    const { billId, amount, paymentMethod, transactionId, notes } = req.body;

    // Validation
    if (!billId || !amount) {
      return res.status(400).json({ message: "BillId and amount are required" });
    }

    // Get bill
    const bill = await Bill.findById(billId);
    if (!bill) {
      return res.status(404).json({ message: "Bill not found" });
    }

    // Check if tenant owns this bill
    if (bill.tenantId.toString() !== req.userId && req.userRole === "tenant") {
      return res.status(403).json({ message: "Unauthorized" });
    }

    // Create payment
    const payment = new Payment({
      billId,
      tenantId: bill.tenantId,
      landlordId: bill.landlordId,
      amount,
      paymentMethod: paymentMethod || "bank_transfer",
      transactionId: transactionId || "",
      status: "completed",
      notes: notes || "",
    });

    await payment.save();

    // Update bill status to paid
    bill.status = "paid";
    bill.paidDate = Date.now();
    await bill.save();

    res.status(201).json({
      message: "Payment recorded successfully",
      payment,
    });
  } catch (error) {
    console.error("Create payment error:", error);
    res.status(500).json({ message: "Error creating payment", error: error.message });
  }
});

// ============ GET PAYMENTS ============
router.get("/", authMiddleware, async (req, res) => {
  try {
    let query;

    if (req.userRole === "landlord") {
      query = { landlordId: req.userId };
    } else if (req.userRole === "tenant") {
      query = { tenantId: req.userId };
    } else {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const payments = await Payment.find(query)
      .populate("billId")
      .populate("tenantId", "name email phone")
      .populate("landlordId", "name email phone")
      .sort({ paymentDate: -1 });

    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: "Error fetching payments" });
  }
});

// ============ GET PAYMENTS FOR SPECIFIC BILL ============
router.get("/bill/:billId", authMiddleware, async (req, res) => {
  try {
    const payments = await Payment.find({ billId: req.params.billId })
      .populate("billId")
      .populate("tenantId", "name email phone")
      .sort({ paymentDate: -1 });

    res.json(payments);
  } catch (error) {
    res.status(500).json({ message: "Error fetching bill payments" });
  }
});

module.exports = router;
