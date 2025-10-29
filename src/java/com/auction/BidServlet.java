package com.auction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet("/BidServlet")
public class BidServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            response.sendRedirect("login.jsp?msg=Please login again");
            return;
        }

        String username = (String) session.getAttribute("username");
        String pidStr = request.getParameter("productId");
        String amtStr = request.getParameter("bidAmount");
        if (pidStr == null || amtStr == null) {
            response.sendRedirect("client.jsp?msg=Invalid bid");
            return;
        }

        int pid = Integer.parseInt(pidStr);
        double bidAmount = Double.parseDouble(amtStr);

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);

            // Is auction already ended?
            long lastBidTime = 0L;
            double base = 0.0;
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT base_price, last_bid_time FROM products WHERE id=? FOR UPDATE")) {
                ps.setInt(1, pid);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        base = rs.getDouble("base_price");
                        lastBidTime = rs.getLong("last_bid_time");
                    } else {
                        session.setAttribute("msg", "❌ Product not found");
                        response.sendRedirect("client.jsp");
                        return;
                    }
                }
            }

            if (lastBidTime > 0L && (System.currentTimeMillis() - lastBidTime) > 15000) {
                conn.rollback();
                session.setAttribute("msg", "❌ Auction already ended");
                response.sendRedirect("client.jsp?productId=" + pid);
                return;
            }

            // Highest so far
            double highest = base;
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT MAX(bid_amount) AS max_bid FROM bids WHERE product_id=?")) {
                ps.setInt(1, pid);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) highest = Math.max(highest, rs.getDouble("max_bid"));
                }
            }

            if (bidAmount <= highest) {
                conn.rollback();
                session.setAttribute("msg", "❌ Your bid must be greater than current highest (" + highest + ")");
                response.sendRedirect("client.jsp?productId=" + pid);
                return;
            }

            long now = System.currentTimeMillis();
            // Insert bid
            try (PreparedStatement ps = conn.prepareStatement(
                 "INSERT INTO bids (product_id, bidder_name, bid_amount, bid_time) VALUES (?, ?, ?, ?)")) {
                ps.setInt(1, pid);
                ps.setString(2, username);
                ps.setDouble(3, bidAmount);
                ps.setLong(4, now);
                ps.executeUpdate();
            }

            // Update last bid time
            try (PreparedStatement ps2 = conn.prepareStatement(
                 "UPDATE products SET last_bid_time=? WHERE id=?")) {
                ps2.setLong(1, now);
                ps2.setInt(2, pid);
                ps2.executeUpdate();
            }

            conn.commit();

            session.setAttribute("msg", "✅ Bid placed successfully");

            // 🔔 Broadcast new state to all watchers of this product
            try {
                AuctionSocket.broadcastState(pid);
            } catch (Throwable ignored) {}

            response.sendRedirect("client.jsp?productId=" + pid);
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg", "❌ Error placing bid: " + e.getMessage());
            response.sendRedirect("client.jsp");
        }
    }
}
