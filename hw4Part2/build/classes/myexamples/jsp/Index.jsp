<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<html>
<head>
<title>Food Web App for Demo</title>
</head>
<body>
	<h3>Select the food to view its recipe:</h3>
	<%@ include file="./DBInfo.jsp"%>
	<%
		Connection conn =null;
		Statement stmt =null;
		ResultSet rs =null;

		// Java way for handling an error using try catch
		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
			stmt = conn.createStatement();
			// show example how to use Statement object for static SQL statements
			String sqlQuery = "SELECT f.FID, f.FNAME FROM food f";
			rs = stmt.executeQuery(sqlQuery);
	%>
			<!-- the form method can be get or post
				but post does not let anyone see the parameter values that are passed between pages
				Use post for sensitive information
			-->
			<form method="post" action="ShowResult.jsp">
			<select name="food_selector">
	<%
				while (rs.next()) {
						out.println("<option value="+ rs.getInt("FID") + ">" + rs.getString("FNAME") + "</option>");
				}
	%>
			</select>
			<p></p>
			<input type="submit" value="GO">
			</form>
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