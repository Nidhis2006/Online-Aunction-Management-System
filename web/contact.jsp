<%-- 
    Document   : contact
    Created on : Sep 13, 2025, 8:56:16 PM
    Author     : Nidhi Singh
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
   // context path for safe links
   String ctx = request.getContextPath();

   // Use implicit 'session' (no imports needed). It may be null if session="false" (not our case).
   String backUrl = ctx + "/login.jsp"; // default
   Object roleObj = (session != null) ? session.getAttribute("role") : null;
   String role = roleObj != null ? roleObj.toString() : null;

   if ("admin".equals(role)) {
       backUrl = ctx + "/admin.jsp";
   } else if ("user".equals(role)) {
       backUrl = ctx + "/client.jsp";
   }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Contact Us</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
</head>
<body class="container mt-4">

  <!-- Header -->
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h2>Contact Us</h2>
    <div>
      <a href="<%= backUrl %>" class="btn btn-secondary btn-sm">Back</a>
      <a href="<%= ctx %>/LogoutServlet" class="btn btn-danger btn-sm">Logout</a>
    </div>
  </div>
  <hr/>

  <!-- Contact Information -->
  <div class="card p-4 shadow-sm">
    <h4>Get in Touch</h4>
    <p><strong>Email:</strong> support@onlineauction.com</p>
    <p><strong>Phone:</strong> +91 98765 43210</p>
    <p><strong>Address:</strong> 123 Auction Street, Bangalore, India</p>
  </div>

</body>
</html>
