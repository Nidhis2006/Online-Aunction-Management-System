package com.auction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.File;
import java.io.IOException;
import java.sql.*;

@WebServlet("/DeleteProductServlet")
public class DeleteProductServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String id = request.getParameter("id");
        if (id == null || id.isEmpty()) {
            response.sendRedirect("admin.jsp?deleteError=InvalidID");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            String imagePath = null;

            // 🔹 Get image path first
            try (PreparedStatement ps1 = conn.prepareStatement("SELECT image_url FROM products WHERE id=?")) {
                ps1.setString(1, id);
                try (ResultSet rs = ps1.executeQuery()) {
                    if (rs.next()) imagePath = rs.getString("image_url");
                }
            }

            // 🔹 Delete related bids first
            try (PreparedStatement psBids = conn.prepareStatement("DELETE FROM bids WHERE product_id=?")) {
                psBids.setString(1, id);
                psBids.executeUpdate();
            }

            // 🔹 Now delete product
            int rows;
            try (PreparedStatement ps2 = conn.prepareStatement("DELETE FROM products WHERE id=?")) {
                ps2.setString(1, id);
                rows = ps2.executeUpdate();
            }

            if (rows > 0) {
                // 🔹 Delete image file from server
                if (imagePath != null && !imagePath.isEmpty()) {
                    String appPath = getServletContext().getRealPath("/");
                    File imgFile = new File(appPath, imagePath);
                    if (imgFile.exists()) imgFile.delete();
                }
                response.sendRedirect("admin.jsp?deleted=1");
            } else {
                response.sendRedirect("admin.jsp?deleteError=NotFound");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("admin.jsp?deleteError=" + e.getMessage());
        }
    }
}
