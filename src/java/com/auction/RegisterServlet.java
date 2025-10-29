package com.auction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (username == null || password == null || confirmPassword == null ||
            username.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("register.jsp?msg=" + URLEncoder.encode("All fields are required", "UTF-8"));
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?msg=" + URLEncoder.encode("Passwords do not match", "UTF-8"));
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // ✅ Check if username exists
            PreparedStatement check = conn.prepareStatement("SELECT id FROM users WHERE username=?");
            check.setString(1, username);
            ResultSet rs = check.executeQuery();
            if (rs.next()) {
                response.sendRedirect("register.jsp?msg=" + URLEncoder.encode("Username already exists", "UTF-8"));
                return;
            }

            // ✅ Insert new user with role 'user'
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO users (username, password, role) VALUES (?, ?, 'user')");
            ps.setString(1, username);
            ps.setString(2, password); // plain text for now (can be hashed later)
            ps.executeUpdate();

            response.sendRedirect("login.jsp?msg=" + URLEncoder.encode("Registered successfully, please login", "UTF-8"));

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?msg=" + URLEncoder.encode("Error: " + e.getMessage(), "UTF-8"));
        }
    }
}
