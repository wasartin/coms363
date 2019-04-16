<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Result from static form</title>
</head>
<body>
	<p>you selected</p>
	<%=request.getParameter("food_selector")%>

	<form action="HelloForm.html">
		<input type="submit" value="BACK" />
	</form>
</body>
</html>