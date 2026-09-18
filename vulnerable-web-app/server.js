const express = require('express');
const crypto = require('crypto');

const app = express();
const PORT = 3000;

app.use(express.urlencoded({ extended: true }));
app.use(express.json());

/*
 * ============================================================
 * SECURITY CONFIGURATION
 * ============================================================
 */

const SESSION_COOKIE = 'vapt_session';
const CSRF_COOKIE = 'vapt_csrf';

const sessions = new Map();

/*
 * Demo users for local VAPT training only.
 * Production applications must use a real database and
 * securely hashed passwords.
 */
const users = [
  {
    id: 1,
    username: 'bhola',
    password: process.env.VAPT_USER_PASSWORD,
    role: 'user'
  },
  {
    id: 2,
    username: 'admin',
    password: process.env.VAPT_ADMIN_PASSWORD,
    role: 'admin'
  }
];

/*
 * ============================================================
 * SECURITY HEADERS
 * ============================================================
 */

app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('Referrer-Policy', 'no-referrer');
  res.setHeader(
    'Content-Security-Policy',
    "default-src 'self'; script-src 'self'; object-src 'none'; frame-ancestors 'none'"
  );

  next();
});

/*
 * ============================================================
 * HELPER FUNCTIONS
 * ============================================================
 */

function createToken() {
  return crypto.randomBytes(32).toString('hex');
}

function escapeHtml(value = '') {
  return String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

function getSession(req) {
  const sessionId = req.headers.cookie
    ?.split(';')
    .map(item => item.trim())
    .find(item => item.startsWith(`${SESSION_COOKIE}=`))
    ?.split('=')[1];

  if (!sessionId) {
    return null;
  }

  return sessions.get(sessionId) || null;
}

function requireAuth(req, res, next) {
  const session = getSession(req);

  if (!session) {
    return res.status(401).json({
      error: 'Authentication required'
    });
  }

  req.session = session;
  next();
}

function requireAdmin(req, res, next) {
  const session = getSession(req);

  if (!session) {
    return res.status(401).json({
      error: 'Authentication required'
    });
  }

  if (session.role !== 'admin') {
    return res.status(403).json({
      error: 'Admin authorization required'
    });
  }

  req.session = session;
  next();
}

function getCsrfToken(req) {
  const session = getSession(req);
  return session ? session.csrfToken : null;
}

function requireCsrf(req, res, next) {
  const session = getSession(req);

  if (!session) {
    return res.status(401).json({
      error: 'Authentication required'
    });
  }

  const suppliedToken =
    req.body._csrf ||
    req.headers['x-csrf-token'];

  if (
    !suppliedToken ||
    suppliedToken !== session.csrfToken
  ) {
    return res.status(403).json({
      error: 'Invalid CSRF token'
    });
  }

  next();
}

/*
 * ============================================================
 * GLOBAL ERROR HANDLER
 * ============================================================
 *
 * F-01 remediation:
 * Do not expose stack traces, source paths or internal
 * implementation details to the client.
 */

app.use((req, res, next) => {
  next();
});

/*
 * ============================================================
 * HOME
 * ============================================================
 */

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Web VAPT Lab</title>
      </head>
      <body>
        <h1>Web VAPT Training Lab</h1>

        <h2>Application Modules</h2>

        <ul>
          <li><a href="/login">Login</a></li>
          <li><a href="/register">Register</a></li>
          <li><a href="/profile">User Profile</a></li>
          <li><a href="/products">Products</a></li>
          <li><a href="/comments">Comments</a></li>
          <li><a href="/upload">File Upload</a></li>
          <li><a href="/admin">Admin Panel</a></li>
          <li><a href="/api/users">REST API</a></li>
        </ul>
      </body>
    </html>
  `);
});

/*
 * ============================================================
 * LOGIN
 * ============================================================
 */

app.get('/login', (req, res) => {
  res.send(`
    <h1>Login</h1>

    <form method="POST" action="/login">

      <input
        name="username"
        placeholder="Username"
        required
      >

      <input
        name="password"
        type="password"
        placeholder="Password"
        required
      >

      <button type="submit">Login</button>

    </form>

  `);
});

app.post('/login', (req, res) => {
  try {
    const { username, password } = req.body || {};

    const user = users.find(
      item =>
        item.username === username &&
        item.password === password
    );

    if (!user) {
      return res.status(401).send('Invalid username or password');
    }

    const sessionId = createToken();
    const csrfToken = createToken();

    sessions.set(sessionId, {
      userId: user.id,
      username: user.username,
      role: user.role,
      csrfToken
    });

    res.setHeader(
      'Set-Cookie',
      `${SESSION_COOKIE}=${sessionId}; HttpOnly; SameSite=Strict; Path=/`
    );

    res.send(`
      <h1>Login Successful</h1>
      <p>Welcome ${escapeHtml(user.username)}</p>
      <p>Role: ${escapeHtml(user.role)}</p>
      <a href="/profile">Profile</a>
    `);

  } catch (error) {
    console.error('Login error:', error);
    res.status(500).send('Internal server error');
  }
});

/*
 * ============================================================
 * PROFILE
 * ============================================================
 *
 * F-02 remediation:
 * Authentication required.
 */

app.get('/profile', requireAuth, (req, res) => {
  res.send(`
    <h1>User Profile</h1>
    <p>User ID: ${req.session.userId}</p>
    <p>Username: ${escapeHtml(req.session.username)}</p>
    <p>Role: ${escapeHtml(req.session.role)}</p>
  `);
});

/*
 * ============================================================
 * PRODUCTS
 * ============================================================
 */

app.get('/products', (req, res) => {
  res.send(`
    <h1>Products</h1>
    <p>Product 1</p>
    <p>Product 2</p>
  `);
});

/*
 * ============================================================
 * COMMENTS
 * ============================================================
 *
 * F-06 remediation:
 * User input is HTML encoded before being inserted into HTML.
 */

app.get('/comments', (req, res) => {
  const comment = escapeHtml(req.query.comment || '');

  res.send(`
    <h1>Comments</h1>

    <form method="GET">

      <input
        name="comment"
        placeholder="Enter comment"
      >

      <button type="submit">Submit</button>

    </form>

    <p>Comment: ${comment}</p>
  `);
});

/*
 * ============================================================
 * FILE UPLOAD
 * ============================================================
 */

app.get('/upload', (req, res) => {
  res.send(`
    <h1>File Upload</h1>
    <p>Upload functionality is disabled in this training build.</p>
  `);
});

/*
 * ============================================================
 * ADMIN
 * ============================================================
 *
 * F-03 remediation:
 * Authentication + role-based authorization.
 */

app.get('/admin', requireAdmin, (req, res) => {
  res.send(`
    <h1>Admin Panel</h1>
    <p>Authorized administrator: ${escapeHtml(req.session.username)}</p>
    <p>Training environment</p>
  `);
});

/*
 * ============================================================
 * REGISTER
 * ============================================================
 */

app.get('/register', (req, res) => {
  const session = getSession(req);

  if (!session) {
    return res.status(401).send(
      'Login required before registration.'
    );
  }

  res.send(`
    <h1>Register</h1>

    <form method="POST" action="/register">

      <input
        name="username"
        placeholder="Username"
        required
      >

      <input
        name="password"
        type="password"
        placeholder="Password"
        required
      >

      <input
        type="hidden"
        name="_csrf"
        value="${escapeHtml(session.csrfToken)}"
      >

      <button type="submit">Register</button>

    </form>
  `);
});

/*
 * ============================================================
 * REGISTER POST
 * ============================================================
 *
 * F-07 remediation:
 * CSRF token required.
 */

app.post('/register', requireCsrf, (req, res) => {
  const { username } = req.body;

  res.send(`
    <h1>Registration Successful</h1>

    <p>Username: ${escapeHtml(username)}</p>

    <p>Account created successfully.</p>

    <a href="/login">Go to Login</a>
  `);
});

/*
 * ============================================================
 * REST API
 * ============================================================
 *
 * F-04 remediation:
 * Authentication required.
 *
 * F-05 remediation:
 * Bearer token is explicitly validated.
 *
 * Note:
 * This training implementation uses the session token as
 * an opaque Bearer token. It is NOT JWT.
 */

app.get('/api/users', (req, res) => {
  const authorization =
    req.headers.authorization || '';

  if (authorization.startsWith('Bearer ')) {

    const token =
      authorization.substring('Bearer '.length);

    if (!sessions.has(token)) {
      return res.status(401).json({
        error: 'Invalid bearer token'
      });
    }

    const session = sessions.get(token);

    if (session.role !== 'admin') {
      return res.status(403).json({
        error: 'Admin authorization required'
      });
    }

    return res.json(
      users.map(user => ({
        id: user.id,
        username: user.username,
        role: user.role
      }))
    );
  }

  const session = getSession(req);

  if (!session) {
    return res.status(401).json({
      error: 'Authentication required'
    });
  }

  if (session.role !== 'admin') {
    return res.status(403).json({
      error: 'Admin authorization required'
    });
  }

  res.json(
    users.map(user => ({
      id: user.id,
      username: user.username,
      role: user.role
    }))
  );
});

/*
 * ============================================================
 * ERROR HANDLER
 * ============================================================
 *
 * F-01 remediation:
 * Detailed errors are logged server-side only.
 */

app.use((err, req, res, next) => {
  console.error('Unhandled application error:', err);

  res.status(500).json({
    error: 'Internal server error'
  });
});

/*
 * ============================================================
 * SERVER
 * ============================================================
 */

app.listen(PORT, '127.0.0.1', () => {
  console.log(
    `Secure VAPT Lab running at http://127.0.0.1:${PORT}`
  );
});
