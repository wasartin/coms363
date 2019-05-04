<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta charset="ISO-8859-1">
<title>Political Tweets Analyzer Login</title> <!-- Political Tweets Analysis -->
<link href = "css/home.css" rel = "stylesheet" type ="text/css" />
<meta name="author" content="Will Sartin">
</head>
<body>
	 <center>
	 <h1>Initial Login Screen</h1>
	 <div class="inital-login-box">
     <form method = "post" action = "QuerySelector.jsp"> <!--  TODO add generalLogin jsp to handle specific users -->
     	<label for="username">Username</label>
     	<input type = "text" name = "username" placeholder="Enter your username"><br>
     	
     	<label for="password">Password</label>
     	<input type="password" name="password" placeholder="Enter your password"><br>
     	<input type = "submit" value = "Login" /> </br></br></br>
		<p vertical-align: bottom;>*Login is only necessary if you are an admin user who wishes to update the data.</p>
     </form>
	 </div>

</body>
</html>