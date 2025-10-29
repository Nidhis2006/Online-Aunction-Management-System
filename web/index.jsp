<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Welcome - Online Auction System</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <style>
    body {
      height: 100vh;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      background: linear-gradient(135deg, #667eea, #764ba2);
      color: white;
      text-align: center;
      font-family: 'Segoe UI', sans-serif;
    }
    h1 {
      font-size: 3rem;
      font-weight: bold;
      margin-bottom: 15px;
    }
    p {
      font-size: 1.2rem;
      margin-bottom: 30px;
    }
    .btn-login {
      background-color: #2563eb;
      color: white;
      padding: 12px 30px;
      font-size: 1.1rem;
      border-radius: 8px;
      transition: 0.3s;
      text-decoration: none;
    }
    .btn-login:hover {
      background-color: #1e40af;
      transform: scale(1.05);
    }
    footer {
      position: absolute;
      bottom: 15px;
      font-size: 0.9rem;
      color: #e0e0e0;
    }
  </style>
</head>
<body>
  <div>
    <h1>Welcome to Online Auction System</h1>
    <p>Bid on products in real-time and manage auctions with ease.</p>
    <a href="login.jsp" class="btn-login">Login to Continue</a>
  </div>
  <footer>
    © 2025 Online Auction System. All rights reserved.
  </footer>
</body>
</html>
