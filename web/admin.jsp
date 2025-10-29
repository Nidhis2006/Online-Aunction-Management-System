<%@ page import="java.sql.*, com.auction.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  HttpSession sess = request.getSession(false);
  if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
      response.sendRedirect("login.jsp?msg=Please login as admin");
      return;
  }
  java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("en", "IN"));
  nf.setMaximumFractionDigits(2);
%>
<html>
<head>
  <title>Admin Panel - Online Auction</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Admin Panel - Online Auction</h2>
    <div>
      <a class="btn btn-secondary btn-sm" href="index.jsp">Home</a>
      <a class="btn btn-danger btn-sm" href="LogoutServlet">Logout</a>
    </div>
  </div>

  <% String flash = (String) sess.getAttribute("msg");
     if (flash != null) { %>
    <div class="alert alert-info"><%= flash %></div>
  <% sess.removeAttribute("msg"); } %>

  <% if (request.getParameter("deleted") != null) { %>
    <div class="alert alert-success">🗑️ Product deleted successfully</div>
  <% } else if (request.getParameter("deleteError") != null) { %>
    <div class="alert alert-danger">❌ Failed to delete product</div>
  <% } %>

  <h4>Add Product</h4>
  <form action="AdminServlet" method="post" enctype="multipart/form-data" class="mb-4">
    <div class="mb-2">
      <label>Product Name</label>
      <input name="productName" class="form-control" required>
    </div>
    <div class="mb-2">
      <label>Base Price (₹)</label>
      <input name="basePrice" type="number" step="1" class="form-control" required>
    </div>
    <div class="mb-2">
      <label>Product Image</label>
      <input name="productImage" type="file" accept="image/*" class="form-control">
    </div>
    <button class="btn btn-primary">Add Product</button>
  </form>

 <h4>All Products</h4>
<table class="table table-bordered table-hover align-middle">
  <thead class="table-dark">
    <tr><th>#</th><th>Name</th><th>Base Price</th><th>Image</th><th>Action</th></tr>
  </thead>
  <tbody>
  <%
    int row = 1; // 👈 start numbering from 1
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement("SELECT * FROM products ORDER BY id ASC");
         ResultSet rs = ps.executeQuery()) {
      while (rs.next()) {
        String name = rs.getString("name");
        double base = rs.getDouble("base_price");
        String img = rs.getString("image_url");
        int id = rs.getInt("id");
  %>
    <tr>
      <td><%= row++ %></td>   <!-- 👈 serial number, not DB id -->
      <td><%= name %></td>
      <td>₹<%= nf.format(base) %></td>
      <td>
        <% if (img != null && !img.isEmpty()) { %>
          <img src="<%= request.getContextPath() + "/" + img %>" width="120" class="img-thumbnail"/>
        <% } else { %>
          <span class="text-muted">No image</span>
        <% } %>
      </td>
      <td>
        <a href="viewBids.jsp?id=<%= id %>" class="btn btn-info btn-sm">View Bids</a>
        <a href="DeleteProductServlet?id=<%= id %>" class="btn btn-danger btn-sm"
           onclick="return confirm('Delete this product?')">Delete</a>
      </td>
    </tr>
  <% }
    } catch (Exception e) { e.printStackTrace(); } %>
  </tbody>
</table>

</body>
</html>
