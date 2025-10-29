package com.auction;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.*;

@WebServlet("/AuctionStatusServlet")
public class AuctionStatusServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String pidStr = request.getParameter("productId");
        if (pidStr == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing productId");
            return;
        }
        int productId = Integer.parseInt(pidStr);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String json = AuctionService.buildStatusJson(productId);
            out.print(json);
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, e.getMessage());
        }
    }
}
