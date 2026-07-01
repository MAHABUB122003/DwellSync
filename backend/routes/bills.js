const express = require("express");
const Bill = require("../models/Bill");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ============ CREATE BILL (Landlord) ============
router.post("/", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res.status(403).json({ message: "Only landlords can create bills" });
    }

    const {
      tenantId,
      rentAmount,
      electricityBill,
      waterBill,
      gasBill,
      dueDate,
      notes,
    } = req.body;

    // Validation
    if (!tenantId || !dueDate) {
      return res.status(400).json({ message: "TenantId and dueDate are required" });
    }

    const bill = new Bill({
      tenantId,
      landlordId: req.userId,
      rentAmount: rentAmount || 0,
      electricityBill: electricityBill || 0,
      waterBill: waterBill || 0,
      gasBill: gasBill || 0,
      dueDate,
      notes: notes || "",
    });

    await bill.save();

    res.status(201).json({
      message: "Bill created successfully",
      bill,
    });
  } catch (error) {
    console.error("Create bill error:", error);
    res.status(500).json({ message: "Error creating bill", error: error.message });
  }
});

// ============ GET BILLS (Landlord gets all bills, Tenant gets own bills) ============
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

    const bills = await Bill.find(query)
      .populate("tenantId", "name email phone")
      .populate("landlordId", "name email phone")
      .sort({ billDate: -1 });

    res.json(bills);
  } catch (error) {
    res.status(500).json({ message: "Error fetching bills" });
  }
});

// ============ GET SINGLE BILL ============
router.get("/:billId", authMiddleware, async (req, res) => {
  try {
    const bill = await Bill.findById(req.params.billId)
      .populate("tenantId", "name email phone")
      .populate("landlordId", "name email phone");

    if (!bill) {
      return res.status(404).json({ message: "Bill not found" });
    }

    // Check if user has access
    if (
      bill.landlordId._id.toString() !== req.userId &&
      bill.tenantId._id.toString() !== req.userId
    ) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    res.json(bill);
  } catch (error) {
    res.status(500).json({ message: "Error fetching bill" });
  }
});

// ============ UPDATE BILL (Landlord) ============
router.put("/:billId", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res.status(403).json({ message: "Only landlords can update bills" });
    }

    const bill = await Bill.findById(req.params.billId);

    if (!bill) {
      return res.status(404).json({ message: "Bill not found" });
    }

    if (bill.landlordId.toString() !== req.userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    const {
      rentAmount,
      electricityBill,
      waterBill,
      gasBill,
      dueDate,
      status,
      notes,
    } = req.body;

    if (rentAmount !== undefined) bill.rentAmount = rentAmount;
    if (electricityBill !== undefined) bill.electricityBill = electricityBill;
    if (waterBill !== undefined) bill.waterBill = waterBill;
    if (gasBill !== undefined) bill.gasBill = gasBill;
    if (dueDate !== undefined) bill.dueDate = dueDate;
    if (status !== undefined) bill.status = status;
    if (notes !== undefined) bill.notes = notes;

    if (status === "paid" && !bill.paidDate) {
      bill.paidDate = Date.now();
    }

    await bill.save();

    res.json({
      message: "Bill updated successfully",
      bill,
    });
  } catch (error) {
    console.error("Update bill error:", error);
    res.status(500).json({ message: "Error updating bill", error: error.message });
  }
});

// ============ DELETE BILL (Landlord) ============
router.delete("/:billId", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res.status(403).json({ message: "Only landlords can delete bills" });
    }

    const bill = await Bill.findById(req.params.billId);

    if (!bill) {
      return res.status(404).json({ message: "Bill not found" });
    }

    if (bill.landlordId.toString() !== req.userId) {
      return res.status(403).json({ message: "Unauthorized" });
    }

    await Bill.findByIdAndDelete(req.params.billId);

    res.json({ message: "Bill deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: "Error deleting bill" });
  }
});

// ============ GET BILLS FOR TENANT (from landlord perspective) ============
router.get("/tenant/:tenantId", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res.status(403).json({ message: "Only landlords can access this" });
    }

    const bills = await Bill.find({
      tenantId: req.params.tenantId,
      landlordId: req.userId,
    })
      .populate("tenantId", "name email phone")
      .sort({ billDate: -1 });

    res.json(bills);
  } catch (error) {
    res.status(500).json({ message: "Error fetching tenant bills" });
  }
});

module.exports = router;
