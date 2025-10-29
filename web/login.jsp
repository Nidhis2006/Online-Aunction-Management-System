<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
  <title>Login</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container d-flex justify-content-center align-items-center vh-100">

  <div class="card shadow p-4" style="width: 400px;">
    <h3 class="text-center mb-3">Login</h3>

    <!-- ✅ Show login messages once -->
    <%
       String msg = request.getParameter("msg");
       if (msg != null && !msg.trim().isEmpty()) {
    %>
       <p class="text-danger text-center"><%= msg %></p>
    <%
       }
    %>

    <!-- ✅ Login Form -->
    <form action="LoginServlet" method="post">
      <div class="mb-3">
        <label class="form-label">Username</label>
        <input type="text" name="username" class="form-control" required>
      </div>
      <div class="mb-3">
        <label class="form-label">Password</label>
        <input type="password" name="password" class="form-control" required>
      </div>
      <button type="submit" class="btn btn-primary w-100">Login</button>
    </form>

    <hr/>

    <!-- ✅ Registration option -->
    <p class="text-center mb-0">Don’t have an account?
      <a href="register.jsp">Register here</a>
    </p>
  </div>

</body>
</html>
