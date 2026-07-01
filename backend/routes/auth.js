const express = require("express");
const jwt = require("jsonwebtoken");
const path = require("path");
const multer = require("multer");
const User = require("../models/User");
const authMiddleware = require("../middleware/auth");

const upload = multer({
  storage: multer.diskStorage({
    destination: (req, file, cb) => cb(null, path.join(__dirname, "..", "uploads")),
    filename: (req, file, cb) => {
      const ext = path.extname(file.originalname) || "";
      const uniqueName = `${Date.now()}-${Math.round(Math.random() * 1e9)}${ext}`;
      cb(null, uniqueName);
    },
  }),
});

const router = express.Router();

// Generate JWT Token
const generateToken = (user) => {
  return jwt.sign(
    { id: user._id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: "30d" }
  );
};

// Generate random invite code
const generateInviteCode = () => {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
  let code = "";
  for (let i = 0; i < 6; i++) {
    code += chars[Math.floor(Math.random() * chars.length)];
  }
  return code;
};

// Format user response (handles _id -> id mapping)
const formatUser = (user) => {
  return {
    id: user._id,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    landlordId: user.landlordId,
    inviteCode: user.inviteCode,
    photoUrl: user.photoUrl || null,
    isVerified: user.isVerified,
    createdAt: user.createdAt,
  };
};

// ============ REGISTER ============
router.post("/register", async (req, res) => {
  try {
    const { name, email, password, phone, role, inviteCode } = req.body;

    // Validation
    if (!name || !email || !password || !phone || !role) {
      return res.status(400).json({ message: "All fields are required" });
    }

    if (role !== "tenant" && role !== "landlord") {
      return res.status(400).json({ message: "Invalid role" });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: "Email already registered" });
    }

    let landlordId = null;
    let userInviteCode = null;

    // If tenant, verify invite code and link to landlord
    if (role === "tenant") {
      if (!inviteCode) {
        return res
          .status(400)
          .json({ message: "Invite code is required for tenant registration" });
      }

      const landlord = await User.findOne({
        role: "landlord",
        inviteCode: inviteCode.toUpperCase(),
      });

      if (!landlord) {
        return res.status(400).json({ message: "Invalid invite code" });
      }

      landlordId = landlord._id;
    }

    // If landlord, generate invite code
    if (role === "landlord") {
      userInviteCode = generateInviteCode();
      // Ensure uniqueness
      let existing = await User.findOne({ inviteCode: userInviteCode });
      while (existing) {
        userInviteCode = generateInviteCode();
        existing = await User.findOne({ inviteCode: userInviteCode });
      }
    }

    // Create new user
    const newUser = new User({
      name,
      email: email.toLowerCase(),
      password,
      phone,
      role,
      landlordId,
      inviteCode: userInviteCode,
      photoUrl: req.body.photoUrl || null,
    });

    await newUser.save();

    const token = generateToken(newUser);

    res.status(201).json({
      message: "User registered successfully",
      token,
      user: formatUser(newUser),
    });
  } catch (error) {
    console.error("Registration error:", error.stack || error);
    res
      .status(500)
      .json({ message: "Registration failed", error: error.message });
  }
});

// ============ LOGIN ============
router.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validation
    if (!email || !password) {
      return res.status(400).json({ message: "Email and password required" });
    }

    // Find user
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    // Check password
    const isPasswordValid = await user.matchPassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = generateToken(user);

    res.json({
      message: "Login successful",
      token,
      user: formatUser(user),
    });
  } catch (error) {
    console.error("Login error:", error);
    res.status(500).json({ message: "Login failed", error: error.message });
  }
});

// ============ GET CURRENT USER ============
router.get("/me", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(formatUser(user));
  } catch (error) {
    res.status(500).json({ message: "Error fetching user" });
  }
});

// ============ GET ALL TENANTS (for landlord) ============
router.get("/tenants", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res
        .status(403)
        .json({ message: "Only landlords can access tenants" });
    }

    const tenants = await User.find({
      role: "tenant",
      landlordId: req.userId,
    }).select("-password");

    res.json(tenants.map(formatUser));
  } catch (error) {
    res.status(500).json({ message: "Error fetching tenants" });
  }
});

// ============ VERIFY INVITE CODE ============
router.get("/invite/:code", async (req, res) => {
  try {
    const landlord = await User.findOne({
      role: "landlord",
      inviteCode: req.params.code.toUpperCase(),
    }).select("name email phone _id");

    if (!landlord) {
      return res.status(404).json({ message: "Invalid invite code" });
    }

    res.json({
      valid: true,
      landlordId: landlord._id,
      landlordName: landlord.name,
    });
  } catch (error) {
    res.status(500).json({ message: "Error verifying invite code" });
  }
});

// ============ REGENERATE INVITE CODE (Landlord) ============
router.put("/invite/regenerate", authMiddleware, async (req, res) => {
  try {
    if (req.userRole !== "landlord") {
      return res
        .status(403)
        .json({ message: "Only landlords can regenerate invite codes" });
    }

    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    let newCode = generateInviteCode();
    let existing = await User.findOne({ inviteCode: newCode });
    while (existing) {
      newCode = generateInviteCode();
      existing = await User.findOne({ inviteCode: newCode });
    }

    user.inviteCode = newCode;
    await user.save();

    res.json({
      message: "Invite code regenerated",
      inviteCode: newCode,
    });
  } catch (error) {
    res.status(500).json({ message: "Error regenerating invite code" });
  }
});
// ============ UPDATE CURRENT USER PROFILE ==========
router.put("/me", authMiddleware, upload.single("photo"), async (req, res) => {
  try {
    const { name, phone, photoUrl } = req.body;
    const user = await User.findById(req.userId);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (name !== undefined) user.name = name;
    if (phone !== undefined) user.phone = phone;

    if (req.file) {
      const host = req.get("host");
      const protocol = req.protocol;
      user.photoUrl = `${protocol}://${host}/uploads/${req.file.filename}`;
    } else if (photoUrl !== undefined) {
      user.photoUrl = photoUrl || null;
    }

    await user.save();

    res.json(formatUser(user));
  } catch (error) {
    res.status(500).json({ message: "Error updating profile", error: error.message });
  }
});
// ============ GET SPECIFIC USER ============
router.get("/:userId", authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.params.userId).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(formatUser(user));
  } catch (error) {
    res.status(500).json({ message: "Error fetching user" });
  }
});

module.exports = router;
