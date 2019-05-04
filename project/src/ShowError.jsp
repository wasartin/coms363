<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="ISO-8859-1"%>
<!--isErrorPage is important  -->
<%@ page isErrorPage="true"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="author" content="Will Sartin & Tom Staudt">
<title>Error</title>
</head>
<body>
	<p>Here is the exception stack trace:</p>
	<p>
		<%
			exception.printStackTrace(response.getWriter());
		%>
	</p>
</body>
</html>