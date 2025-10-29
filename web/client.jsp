<%@ page import="java.sql.*, com.auction.DBUtil" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
  HttpSession sess = request.getSession(false);
  if (sess == null || !"user".equals(sess.getAttribute("role"))) {
      response.sendRedirect("login.jsp?msg=Please login again");
      return;
  }
  String username = (String) sess.getAttribute("username");
  java.text.NumberFormat nf = java.text.NumberFormat.getInstance(new java.util.Locale("en", "IN"));
  nf.setMaximumFractionDigits(2);
%>
<html>
<head>
  <title>Client Panel</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
</head>
<body class="container mt-4">

  <!-- Header -->
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Client Panel</h2>
    <div>
      <span class="me-3">👋 Hi, <strong><%= username %></strong></span>
      <a class="btn btn-info btn-sm" href="contact.jsp">Contact</a>
      <a class="btn btn-danger btn-sm" href="LogoutServlet">Logout</a>
    </div>
  </div>
  <hr/>

  <!-- Products Table -->
  <h4>All Products</h4>
  <table class="table table-bordered table-hover">
    <tr class="table-dark">
      <th>Product</th><th>Image</th><th>Base Price</th><th>Highest Bid</th><th>Action</th>
    </tr>
    <%
      try (Connection conn = DBUtil.getConnection();
           PreparedStatement ps = conn.prepareStatement("SELECT * FROM products ORDER BY id ASC");
           ResultSet rs = ps.executeQuery()) {
        while (rs.next()) {
          int id = rs.getInt("id");
          String name = rs.getString("name");
          double base = rs.getDouble("base_price");
          String img = rs.getString("image_url");

          long now = System.currentTimeMillis();
          long lastBidTime = rs.getLong("last_bid_time");
          boolean sold = (lastBidTime > 0 && (now - lastBidTime > 15000)); // 15s after last bid

          String highestBid = "Not sold yet";
          try (PreparedStatement ps2 = conn.prepareStatement(
                  "SELECT bidder_name, bid_amount FROM bids WHERE product_id=? ORDER BY bid_amount DESC LIMIT 1")) {
              ps2.setInt(1, id);
              try (ResultSet rs2 = ps2.executeQuery()) {
                  if (rs2.next()) {
                      String bidderName = rs2.getString("bidder_name");
                      double maxBid = rs2.getDouble("bid_amount");
                      highestBid = (bidderName != null ? bidderName : "Unknown") + " (₹" + nf.format(maxBid) + ")";
                  }
              }
          }
    %>
      <tr>
        <td><%= name %></td>
        <td>
          <% if (img != null && !img.isEmpty()) { %>
            <img src="<%= request.getContextPath() + "/" + img %>" width="100" class="img-thumbnail"/>
          <% } else { %>
            <span class="text-muted">No image</span>
          <% } %>
        </td>
        <td>₹<%= nf.format(base) %></td>
        <td><%= highestBid %></td>
        <td>
          <% if (sold) { %>
            <button class="btn btn-danger btn-sm" disabled>Sold</button>
          <% } else { %>
            <a href="client.jsp?productId=<%= id %>" class="btn btn-primary btn-sm">Bid</a>
          <% } %>
        </td>
      </tr>
    <% }
      } catch (Exception e) { e.printStackTrace(); } %>
  </table>

  <%
    String pid = request.getParameter("productId");
    if (pid != null) {
      int productId = Integer.parseInt(pid);
      String productName = "";
      double basePrice = 0;
      long lastBidTime = 0;

      try (Connection conn = DBUtil.getConnection();
           PreparedStatement ps = conn.prepareStatement("SELECT * FROM products WHERE id=?")) {
        ps.setInt(1, productId);
        try (ResultSet rs = ps.executeQuery()) {
          if (rs.next()) {
            productName = rs.getString("name");
            basePrice = rs.getDouble("base_price");
            lastBidTime = rs.getLong("last_bid_time");
          }
        }
      }

      long now = System.currentTimeMillis();
      boolean auctionEnded = false;
      long remaining = 0L;
      if (lastBidTime > 0) {
        long diff = now - lastBidTime;
        if (diff > 15000) auctionEnded = true; else remaining = 15000 - diff;
      }
  %>
<hr/>

<!-- 🔔 Live end-of-auction banner -->
<div id="auction-ended-wrap" style="display:none; margin:16px 0;">
  <div style="font-size:20px; font-weight:800; color:#dc2626; margin-bottom:8px;">
    Auction ended!
  </div>
  <div id="winner-card" style="background:#d1fae5; border:1px solid #a7f3d0; color:#065f46;
       padding:14px 16px; border-radius:10px; font-size:18px; line-height:1.4;">
    🏆 <span id="winner-name">—</span> won with ₹<span id="winner-amount">0</span>
    <button id="print-result"
            style="float:right; padding:6px 10px; border-radius:8px; border:1px solid #065f46; background:#065f46; color:#fff; cursor:pointer;">
      Print
    </button>
    <div style="clear:both"></div>
  </div>
</div>

<hr/>
<h3>Bidding for: <%= productName %> (Base: ₹<%= nf.format(basePrice) %>)</h3>

<%
   if (auctionEnded) {
%>
    <p class="text-danger fw-bold">Auction ended!</p>
    <h4>Winner</h4>
    <%
        try (Connection conn = DBUtil.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT bidder_name, bid_amount FROM bids WHERE product_id=? ORDER BY bid_amount DESC LIMIT 1"
            );
            ps.setInt(1, productId);
            ResultSet rsWin = ps.executeQuery();
            if (rsWin.next()) {
                String winnerName = rsWin.getString("bidder_name");
                double winnerBid = rsWin.getDouble("bid_amount");
    %>
        <div class="alert alert-success">
            🏆 <strong><%= winnerName %></strong> won with ₹<%= nf.format(winnerBid) %>
        </div>
    <%
            } else {
    %>
        <p class="text-muted">No bids were placed.</p>
    <%
            }
        }
    %>
<%
   } else {
%>
    <% if (lastBidTime > 0) { %>
        <p>Auction ends in: <span id="timer"></span></p>
        <script>
            let remaining = <%= remaining %>;
            function updateTimer() {
                if (remaining <= 0) {
                    document.getElementById("timer").innerText = "Auction ended!";
                    return;
                }
                let sec = Math.floor(remaining / 1000);
                document.getElementById("timer").innerText = sec + "s";
                remaining -= 1000;
                setTimeout(updateTimer, 1000);
            }
            updateTimer();
        </script>
    <% } %>

    <!-- ✅ Live Auction UI -->
    <div id="auction-status"></div>

    <div id="bid-form">
        <form action="BidServlet" method="post" class="mb-3">
            <input type="hidden" name="productId" value="<%= productId %>">
            <div class="mb-2">
                <label>Your Bid (₹)</label>
                <input type="number" step="1" name="bidAmount" required class="form-control" />
            </div>
            <button type="submit" class="btn btn-primary">Place Bid</button>
        </form>
    </div>

    <p><strong>Highest Bid:</strong> <span id="highest-bid">Loading...</span></p>

<%
   }
%>

  <h4>All Bids:</h4>
  <ol>
  <%
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(
           "SELECT bidder_name, bid_amount FROM bids WHERE product_id=? ORDER BY bid_time ASC")) {
      ps.setInt(1, productId);
      try (ResultSet rs = ps.executeQuery()) {
        boolean has = false;
        while (rs.next()) {
          has = true;
          String formattedBid = "₹" + nf.format(rs.getDouble("bid_amount"));
  %>
    <li><%= rs.getString("bidder_name") %> → <%= formattedBid %></li>
  <%
        }
        if (!has) {
  %>
    <li><span class="text-muted">No bids yet.</span></li>
  <%
        }
      }
    } catch (Exception e) { e.printStackTrace(); }
  %>
  </ol>

  <% } // end if pid %>

<!-- ✅ WebSocket live updates + polling fallback -->
<script>
  function fmtINR(n){ return Number(n || 0).toLocaleString(); }

  function renderState(state) {
    if (!state) return;

    var statusEl   = document.getElementById("auction-status");
    var formEl     = document.getElementById("bid-form");
    var highestEl  = document.getElementById("highest-bid");

    // NEW: banner elements
    var endedWrap  = document.getElementById("auction-ended-wrap");
    var winnerName = document.getElementById("winner-name");
    var winnerAmt  = document.getElementById("winner-amount");

    if (state.ended) {
      // detail panel
      if (statusEl) {
        statusEl.innerHTML =
          '<span style="color:#dc2626; font-weight:700;">Auction ended!</span>';
      }
      if (formEl) formEl.style.display = "none";

      // 🔔 show big banner instantly
      if (endedWrap) {
        endedWrap.style.display = "block";
        if (winnerName) winnerName.textContent = state.bidder || '—';
        if (winnerAmt)  winnerAmt.textContent  = fmtINR(state.amount);
        // bring it into view once
        setTimeout(function(){
          endedWrap.scrollIntoView({behavior:'smooth', block:'start'});
        }, 0);
        // print button
        var btn = document.getElementById("print-result");
        if (btn && !btn._bound) {
          btn._bound = true;
          btn.addEventListener('click', function(){ window.print(); });
        }
      }

      // (optional) update top table action → Sold (if you added hooks)
      if (typeof productId !== "undefined") {
        var pid = productId;
        document
          .querySelectorAll('.js-grid-action[data-product-id="' + pid + '"]')
          .forEach(function(el){ el.innerHTML = '<span class="badge bg-secondary">Sold</span>'; });
      }

    } else {
      // still running
      if (statusEl && state.bidder !== undefined) {
        statusEl.innerHTML =
          '<p>Highest bid so far: ' + (state.bidder || '—') +
          ' (₹' + fmtINR(state.amount) + ')</p>';
      }
      if (highestEl && state.bidder !== undefined) {
        highestEl.textContent = (state.bidder || '—') + ' (₹' + fmtINR(state.amount) + ')';
      }
      if (endedWrap) endedWrap.style.display = "none";
    }

    // (optional) keep grid “Highest Bid” cell in sync if you added hooks
    if (typeof productId !== "undefined") {
      var pid2 = productId;
      document
        .querySelectorAll('.js-grid-highest[data-product-id="' + pid2 + '"]')
        .forEach(function(el){
          el.textContent = (state.bidder || '—') + ' (₹' + fmtINR(state.amount) + ')';
        });
    }
  }
</script>


</body>
</html>
