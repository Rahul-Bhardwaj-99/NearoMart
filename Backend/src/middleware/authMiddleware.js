const jwt = require('jsonwebtoken');
const User = require('../models/User');

const authMiddleware = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');

  if (!token) {
    return res.status(401).json({ message: 'No token, authorization denied' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('invalidatedAt');
    if (!user || (user.invalidatedAt && decoded.iat * 1000 < user.invalidatedAt.getTime())) {
      return res.status(401).json({ message: 'Session has expired. Please sign in again.' });
    }
    req.user = decoded;
    next();
  } catch (error) {
    res.status(401).json({ message: 'Token is not valid' });
  }
};

authMiddleware.requireRole = (...allowedRoles) => (req, res, next) => {
  if (!req.user || !req.user.role) {
    return res.status(401).json({ message: 'Authentication required' });
  }

  const role = String(req.user.role).toUpperCase();
  if (!allowedRoles.map((r) => String(r).toUpperCase()).includes(role)) {
    return res.status(403).json({ message: 'You do not have permission to perform this action' });
  }

  next();
};

authMiddleware.optional = async (req, res, next) => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  if (!token) return next();

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('invalidatedAt');
    if (user && (!user.invalidatedAt || decoded.iat * 1000 >= user.invalidatedAt.getTime())) {
      req.user = decoded;
    }
  } catch (error) {
    // Public media can continue without an optional session.
  }
  next();
};

module.exports = authMiddleware;
