const express = require("express");
const Message = require("../models/Message");
const authMiddleware = require("../middleware/auth");

const router = express.Router();

// ============ SEND MESSAGE ============
router.post("/", authMiddleware, async (req, res) => {
  try {
    const { receiverId, text } = req.body;
    if (!receiverId || !text) {
      return res.status(400).json({ message: "ReceiverId and text are required" });
    }

    const message = new Message({
      senderId: req.userId,
      receiverId,
      text,
    });

    await message.save();

    res.status(201).json(message);
  } catch (error) {
    console.error("Send message error:", error);
    res.status(500).json({ message: "Error sending message", error: error.message });
  }
});

// ============ GET ALL USER MESSAGES ============
router.get("/", authMiddleware, async (req, res) => {
  try {
    const messages = await Message.find({
      $or: [{ senderId: req.userId }, { receiverId: req.userId }],
    }).sort({ createdAt: 1 }); // Sorted oldest first for conversational flow

    res.json(messages);
  } catch (error) {
    console.error("Get messages error:", error);
    res.status(500).json({ message: "Error fetching messages" });
  }
});

module.exports = router;
