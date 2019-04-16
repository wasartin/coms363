<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Nodes Page</title>
</head>
<body>
<h1>TODO</h1>

	<%@ include file="./DBInfo.jsp"%>
	<%
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		// Java way for handling an error using try catch
		try {
			Class.forName("com.mysql.jdbc.Driver");
			String username = request.getParameter("username_input");
			String password = request.getParameter("password_input");
			session.setAttribute("username_input", username);
			session.setAttribute("password_input", password);
			conn = DriverManager.getConnection(DB_URL, username, password);
			stmt = conn.createStatement();
			// show example how to use Statement object for static SQL statements
			String sqlQuery = "SELECT f.FID, f.FNAME FROM food f";
			rs = stmt.executeQuery(sqlQuery);
			String name = request.getParameter( "username" );
			session.setAttribute( "theName", name );
	%>
			<!-- the form method can be get or post
				but post does not let anyone see the parameter values that are passed between pages
				Use post for sensitive information
			-->
	<%
			
		} catch (SQLException e) {
			out.println("An exception occurred: " + e.getMessage());
		} finally {
			if (rs!= null) rs.close();
			if (stmt!= null) stmt.close();
			if (conn != null) conn.close();
		}
	%>
</body>
</html>