import express from 'express';
import cors from 'cors';
import crypto from 'crypto';

const app = express();
app.use(express.json());

// Allow Flutter Web (localhost) to call this API.
app.use(
  cors({
    origin: true,
    credentials: false,
    allowedHeaders: ['Content-Type', 'Accept', 'login_token', 'login-token'],
    methods: ['GET', 'POST', 'OPTIONS'],
  }),
);

// ---- In-memory data store (for assignment/demo) ----
const nowIso = () => new Date().toISOString();

let nextUserId = 2;
let nextOrderId = 2;

const users = [
  {
    id: 1,
    username: 'demo',
    email: 'demo@example.com',
    password: 'demo123',
    role_id: 1,
    profile_picture_url: '',
    created_at: nowIso(),
  },
];

const products = [
  {
    id: 1,
    name: 'Camera',
    description: 'Mirrorless camera for rent.',
    price_per_day: 50000,
    image_url: '',
    category: 'electronics',
    owner_id: 1,
    is_available: true,
  },
  {
    id: 2,
    name: 'Mountain Bike',
    description: 'Hardtail MTB, size M.',
    price_per_day: 75000,
    image_url: '',
    category: 'sports',
    owner_id: 1,
    is_available: true,
  },
];

const sessions = new Map(); // token -> userId
const orders = [
  {
    order_id: 1,
    product_id: 1,
    user_id: 1,
    start_date: '2026-05-01',
    end_date: '2026-05-03',
    total_price: 150000,
    status: 'completed',
  },
];

function readToken(req) {
  // submission.txt uses login_token (underscore).
  // Keep login-token as a fallback to avoid breaking older clients.
  return req.header('login_token') || req.header('login-token') || '';
}

function requireAuth(req, res, next) {
  const token = readToken(req);
  const userId = sessions.get(token);
  if (!token || !userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
  req.userId = userId;
  req.loginToken = token;
  next();
}

function issueToken() {
  return crypto.randomBytes(24).toString('hex');
}

// ---- Endpoints (match submission.txt) ----

app.post('/register', (req, res) => {
  const { username, email, password } = req.body || {};
  if (!username || !email || !password) {
    return res.status(400).json({ message: 'username, email, password required' });
  }
  if (users.some((u) => u.username === username)) {
    return res.status(409).json({ message: 'username already exists' });
  }
  const user = {
    id: nextUserId++,
    username,
    email,
    password,
    role_id: 2,
    profile_picture_url: '',
    created_at: nowIso(),
  };
  users.push(user);
  const token = issueToken();
  sessions.set(token, user.id);
  return res.json({
    id: user.id,
    username: user.username,
    email: user.email,
    role_id: user.role_id,
    login_token: token,
  });
});

app.post('/login', (req, res) => {
  const { username, password } = req.body || {};
  if (!username || !password) {
    return res.status(400).json({ message: 'username and password required' });
  }
  const user = users.find((u) => u.username === username && u.password === password);
  if (!user) {
    return res.status(401).json({ message: 'Invalid credentials' });
  }
  const token = issueToken();
  sessions.set(token, user.id);
  return res.json({
    id: user.id,
    username: user.username,
    email: user.email,
    role_id: user.role_id,
    login_token: token,
  });
});

app.post('/logout', requireAuth, (req, res) => {
  sessions.delete(req.loginToken);
  return res.json({ message: 'Logged out' });
});

app.post('/products', requireAuth, (req, res) => {
  const { category, search_query } = req.body || {};
  let filtered = [...products];
  if (category) filtered = filtered.filter((p) => p.category === category);
  if (search_query) {
    const q = String(search_query).toLowerCase();
    filtered = filtered.filter(
      (p) => p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q),
    );
  }
  return res.json({ products: filtered });
});

app.post('/products/:id', requireAuth, (req, res) => {
  const id = Number(req.params.id);
  const p = products.find((x) => x.id === id);
  if (!p) return res.status(404).json({ message: 'Not found' });
  const owner = users.find((u) => u.id === p.owner_id);
  return res.json({
    ...p,
    owner_username: owner?.username ?? '',
  });
});

app.post('/orders', requireAuth, (req, res) => {
  const { product_id, start_date, end_date } = req.body || {};
  if (!product_id || !start_date || !end_date) {
    return res.status(400).json({ message: 'product_id, start_date, end_date required' });
  }
  const p = products.find((x) => x.id === Number(product_id));
  if (!p) return res.status(404).json({ message: 'Product not found' });

  // Simple price calc: 1 day minimum for demo.
  const total_price = Number(p.price_per_day) || 0;

  const order = {
    order_id: nextOrderId++,
    product_id: Number(product_id),
    user_id: req.userId,
    start_date: String(start_date),
    end_date: String(end_date),
    total_price,
    status: 'created',
  };
  orders.push(order);
  return res.json(order);
});

app.post('/orders/history', requireAuth, (req, res) => {
  const myOrders = orders.filter((o) => o.user_id === req.userId);
  const mapped = myOrders.map((o) => {
    const p = products.find((x) => x.id === o.product_id);
    return {
      order_id: o.order_id,
      product_id: o.product_id,
      product_name: p?.name ?? '',
      start_date: o.start_date,
      end_date: o.end_date,
      total_price: o.total_price,
      status: o.status,
    };
  });
  return res.json({ orders: mapped });
});

app.post('/profile', requireAuth, (req, res) => {
  const user = users.find((u) => u.id === req.userId);
  if (!user) return res.status(404).json({ message: 'Not found' });
  return res.json({
    id: user.id,
    username: user.username,
    email: user.email,
    role_id: user.role_id,
    profile_picture_url: user.profile_picture_url,
    created_at: user.created_at,
  });
});

app.post('/profile/update', requireAuth, (req, res) => {
  const user = users.find((u) => u.id === req.userId);
  if (!user) return res.status(404).json({ message: 'Not found' });

  const { username, email, password, profile_picture_url } = req.body || {};
  if (username) user.username = String(username);
  if (email) user.email = String(email);
  if (password) user.password = String(password);
  if (profile_picture_url) user.profile_picture_url = String(profile_picture_url);

  return res.json({
    id: user.id,
    username: user.username,
    email: user.email,
    profile_picture_url: user.profile_picture_url,
  });
});

app.get('/', (_req, res) => {
  res.type('text').send('Rental Marketplace backend is running.');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Backend running on http://localhost:${PORT}`);
  console.log('Demo login: username=demo password=demo123');
});

