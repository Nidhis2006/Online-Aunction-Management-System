package com.auction;

import org.json.JSONObject;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/** Helper to compute current auction JSON. */
public class AuctionService {

    /** Returns a JSON string with current winner/amount/ended for a product. */
    public static String buildStatusJson(int productId) throws Exception {
        String bidder = "";
        double amount = 0.0;
        boolean ended = false;
        long lastBidTime = 0L;

        try (Connection conn = DBUtil.getConnection()) {
            // Highest bid so far
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT bidder_name, bid_amount FROM bids WHERE product_id=? " +
                    "ORDER BY bid_amount DESC, bid_time ASC LIMIT 1"
            )) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bidder = rs.getString("bidder_name");
                        amount = rs.getDouble("bid_amount");
                    }
                }
            }

            // Last bid timestamp to decide "ended"
            try (PreparedStatement ps2 = conn.prepareStatement(
                    "SELECT last_bid_time FROM products WHERE id=?"
            )) {
                ps2.setInt(1, productId);
                try (ResultSet rs = ps2.executeQuery()) {
                    if (rs.next()) {
                        lastBidTime = rs.getLong("last_bid_time");
                    }
                }
            }
        }

        if (lastBidTime > 0L) {
            long now = System.currentTimeMillis();
            long diff = now - lastBidTime;
            ended = diff > 15000; // 15s since last bid = end
        }

        JSONObject json = new JSONObject();
        json.put("type", "state");
        json.put("bidder", bidder == null ? "" : bidder);
        json.put("amount", amount);
        json.put("ended", ended);
        return json.toString();
    }
    
    public static boolean isAuctionEnded(int productId) throws Exception {
    long start = 0L, duration = 0L;
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement ps = conn.prepareStatement(
            "SELECT start_time, duration FROM products WHERE id=?")) {
        ps.setInt(1, productId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                start = rs.getLong("start_time");
                duration = rs.getLong("duration"); // both are milliseconds in your schema
            }
        }
    }
    if (start <= 0L || duration <= 0L) return false; // treat as not-ended if data missing
    return System.currentTimeMillis() >= (start + duration);
}
}
