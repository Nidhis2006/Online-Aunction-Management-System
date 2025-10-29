<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>User Registration</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-5">

  <h2 class="mb-4">Register</h2>

  <form action="RegisterServlet" method="post" class="card p-4 shadow-sm">
    <div class="mb-3">
      <label class="form-label">Username</label>
      <input type="text" name="username" class="form-control" required>
    </div>

    <div class="mb-3">
      <label class="form-label">Password</label>
      <input type="password" name="password" class="form-control" required>
    </div>

    <div class="mb-3">
      <label class="form-label">Confirm Password</label>
      <input type="password" name="confirmPassword" class="form-control" required>
    </div>

    <button type="submit" class="btn btn-success">Register</button>
    <a href="login.jsp" class="btn btn-secondary">Back to Login</a>
  </form>

  <% String msg = request.getParameter("msg");
     if (msg != null) { %>
     <p class="text-danger mt-3"><%= msg %></p>
  <% } %>

</body>
</html>
