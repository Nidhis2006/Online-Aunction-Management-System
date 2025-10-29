<%@ page import="java.sql.*, com.auction.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  HttpSession sess = request.getSession(false);
  if (sess == null || !"admin".equals(sess.getAttribute("role"))) {
      response.sendRedirect("login.jsp?msg=Please login as admin");
      return;
  }
  String sid = request.getParameter("id");
  if (sid == null) { response.sendRedirect("admin.jsp?msg=No product selected"); return; }

  int pid = Integer.parseInt(sid);
  java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("en", "IN"));
  nf.setMaximumFractionDigits(2);
%>
<html>
<head>
  <title>View Bids</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">
  <a class="btn btn-secondary btn-sm mb-3" href="admin.jsp">⬅ Back to Admin Panel</a>
  <h3>Bids for Product ID: <%= pid %></h3>

  <%
    String winner = null; Double winAmt = null;
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "SELECT bidder_name, bid_amount FROM bids WHERE product_id=? ORDER BY bid_amount DESC LIMIT 1")) {
      ps.setInt(1, pid);
      try (ResultSet rs = ps.executeQuery()) {
        if (rs.next()) { winner = rs.getString("bidder_name"); winAmt = rs.getDouble("bid_amount"); }
      }
    } catch (Exception e) { e.printStackTrace(); }
    if (winner != null) {
  %>
    <div class="alert alert-success">🏆 <strong>Winner:</strong> <%= winner %> with ₹<%= nf.format(winAmt) %></div>
  <% } %>

  <table class="table table-striped table-bordered">
    <thead class="table-dark">
      <tr><th>#</th><th>Bidder</th><th>Amount (₹)</th><th>Time</th></tr>
    </thead>
    <tbody>
    <%
      int i = 0;
      try (Connection conn = DBUtil.getConnection();
           PreparedStatement ps = conn.prepareStatement(
             "SELECT bidder_name, bid_amount, bid_time FROM bids WHERE product_id=? ORDER BY bid_time ASC")) {
        ps.setInt(1, pid);
        try (ResultSet rs = ps.executeQuery()) {
          while (rs.next()) {
            i++;
            String who = rs.getString("bidder_name");
            double amt = rs.getDouble("bid_amount");
            java.util.Date t = new java.util.Date(rs.getLong("bid_time"));
    %>
      <tr>
        <td><%= i %></td>
        <td><%= who %></td>
        <td>₹<%= nf.format(amt) %></td>
        <td><%= t.toString() %></td>
      </tr>
    <%   }
        }
      } catch (Exception e) { e.printStackTrace(); } %>
    </tbody>
  </table>
</body>
</html>
