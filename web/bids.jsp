<%@ page import="java.sql.*, com.auction.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  String productId = request.getParameter("productId");
  if (productId == null) { return; }
%>
<table class="table table-sm table-striped">
  <tr class="table-dark">
    <th>#</th><th>Bidder</th><th>Amount (₹)</th><th>Time</th>
  </tr>
  <%
    try (Connection conn = DBUtil.getConnection()) {
      PreparedStatement ps = conn.prepareStatement(
        "SELECT bidder_name, bid_amount, bid_time FROM bids WHERE product_id=? ORDER BY bid_time DESC");
      ps.setInt(1, Integer.parseInt(productId));
      ResultSet rs = ps.executeQuery();
      int i = 1;
      java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("HH:mm:ss");
      while (rs.next()) {
  %>
    <tr>
      <td><%= i++ %></td>
      <td><%= rs.getString("bidder_name") %></td>
      <td>₹<%= rs.getDouble("bid_amount") %></td>
      <td><%= fmt.format(new java.util.Date(rs.getLong("bid_time"))) %></td>
    </tr>
  <%
      }
      if (i == 1) {
  %>
    <tr><td colspan="4" class="text-center">No bids yet</td></tr>
  <%
      }
    } catch (Exception e) { e.printStackTrace(); }
  %>
</table>
