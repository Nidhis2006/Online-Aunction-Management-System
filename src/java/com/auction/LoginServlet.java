package com.auction;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.*;

@WebServlet(name = "LoginServlet", urlPatterns = {"/LoginServlet"})
public class LoginServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        try (Connection conn = DBUtil.getConnection()) {
            String sql = "SELECT role FROM users WHERE username=? AND password=?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ps.setString(2, password);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        String role = rs.getString("role");
                        HttpSession session = request.getSession(true);
                        session.setAttribute("username", username);
                        session.setAttribute("role", role);

                        if ("admin".equalsIgnoreCase(role)) {
                            response.sendRedirect("admin.jsp");
                        } else {
                            response.sendRedirect("client.jsp");
                        }
                        return;
                    }
                }
            }
            response.sendRedirect("login.jsp?msg=Invalid credentials");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?msg=Server error");
        }
    }
}
