package com.auction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;
import java.nio.file.Files;
import java.sql.*;

@WebServlet("/AdminServlet")
@MultipartConfig
public class AdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();

        String name = request.getParameter("productName");
        String priceStr = request.getParameter("basePrice");

        if (name == null || name.trim().isEmpty() || priceStr == null) {
            session.setAttribute("msg", "❌ Name or Price missing");
            response.sendRedirect("admin.jsp");
            return;
        }

        try {
            double basePrice = Double.parseDouble(priceStr);

            // save uploaded image into webapp /images
            Part filePart = request.getPart("productImage");
            String imagePath = null;

            if (filePart != null && filePart.getSize() > 0) {
                String fileName = new File(filePart.getSubmittedFileName()).getName();

                String imagesDir = getServletContext().getRealPath("/images");
                if (imagesDir == null) { // rare fallback
                    imagesDir = System.getProperty("java.io.tmpdir") + File.separator + "images";
                }

                File dir = new File(imagesDir);
                if (!dir.exists()) dir.mkdirs();

                File dest = new File(dir, fileName);
                try (InputStream in = filePart.getInputStream()) {
                    Files.copy(in, dest.toPath(), java.nio.file.StandardCopyOption.REPLACE_EXISTING);
                }
                // store a RELATIVE path that JSPs can render
                imagePath = "images/" + fileName.replace("\\", "/");
            }

            long startTime = System.currentTimeMillis();
            long duration = 60_000L; // not used for close, but kept for schema

            try (Connection conn = DBUtil.getConnection()) {
                String sql = "INSERT INTO products (name, base_price, start_time, duration, image_url, last_bid_time) VALUES (?,?,?,?,?,0)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setDouble(2, basePrice);
                    ps.setLong(3, startTime);
                    ps.setLong(4, duration);
                    ps.setString(5, imagePath);
                    ps.executeUpdate();
                }
            }

            session.setAttribute("msg", "✅ Product added successfully");
            response.sendRedirect("admin.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            session.setAttribute("msg", "❌ Error adding product: " + e.getMessage());
            response.sendRedirect("admin.jsp");
        }
    }
}
