<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
	<!-- 
	-This is the QuerySelector page. For this first portion we have some general methods, and how we keep the info whether the user is an admin or not.
	-From there we set up our connection if the user is logging in. 
	-Finally we list out all the queries available depending on the user.
	 -->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Query Selector</title>
<link href = "css/selector.css" rel = "stylesheet" type ="text/css" />
<meta name="author" content="Will Sartin & Tom Staudt">
</head>
<body>
	<%@ page errorPage="ShowError.jsp"%>
	<%@ include file="DBInfo.jsp"%>
	<%!										
		public Connection conn = null;
		public PreparedStatement pStmt = null;
		public ResultSet rs = null;
		public Statement stmt = null;
		public static boolean isAdmin = false;
		
		public List<String> getAllParties(Connection aConn){
			List<String> partyList = new ArrayList<String>();
			Connection temp = aConn;
			try{

				String getAllParties = "SELECT DISTINCT party FROM users";
				stmt = temp.createStatement();
				rs = stmt.executeQuery(getAllParties);
				
				while (rs.next()) {
					partyList.add(rs.getString("party"));
				}
				
			}catch(SQLException e){
				
			}
			return partyList;
		}
	%>
	<%
		String VERIFY_USER_QUERY = "SELECT * FROM application_users a"
		+" WHERE a.un = ?"	//un: mcmuffin 
		+" AND a.pw = SHA(?)";	//pw:biscuts1
		// Java way for handling an error using try catch

		try {
			Class.forName("com.mysql.jdbc.Driver");
			conn = DriverManager.getConnection(DB_URL,DB_USERNAME, DB_PASSWORD); 
			
			String username = (request.getParameter("username") != null) ? request.getParameter("username") : "";
			String password = (request.getParameter("password") != null) ? request.getParameter("password") : "";
			if(username.length() != 0){
				session.setAttribute("username", username);

				pStmt = conn.prepareStatement(VERIFY_USER_QUERY);
				pStmt.setString(1, username);
				pStmt.setString(2, password);
				
				rs = pStmt.executeQuery();

				out.println("<table><tr><th>User Name</th><th>Role</th></tr>");
				while (rs.next()) {
					String user = rs.getString("un");
						Boolean anAdmin = rs.getBoolean("is_admin");
						isAdmin = anAdmin;
						session.setAttribute("role", isAdmin);
						out.println("<tr>");
						out.println("<td>" + user + "</td>");
						out.println("<td>" + ((isAdmin)?"admin" : "general") + "</td>");
						out.println("</tr>");
				}
				out.println("</table>");
			}

			List<String> partyList = getAllParties(conn);

			List<String> monthsList = new ArrayList<String>();
				monthsList.add("Jan");	monthsList.add("Feb");	monthsList.add("Mar");
				monthsList.add("Apr");	monthsList.add("May");	monthsList.add("Jun");
				monthsList.add("Jul");	monthsList.add("Aug");	monthsList.add("Sep");
				monthsList.add("Oct");	monthsList.add("Nov");	monthsList.add("Dec");
				
	%>
	<!--  All the Queries -->
	<center>
	<h2>Query Selector</h2>
	
		<div class="query-box">
		<h3 id="q1">Query 1</h3>
		<p>List k most retweeted tweets in a given month and a given year; show the retweet count, the tweet
			text, the posting user's screen name, the posting user's category, the posting user's sub-category in
			descending order of the retweet count</br></p>
		<p>Input: value of k (e.g., 10), month (e.g., 1), and year (e.g., 2016)</p>
		<form method = "get" action = "ShowResult.jsp"> <!--  TODO add generalLogin jsp to handle specific users -->
			<!-- This is a hidden thing being sent. 1 is so the next page knows which query is being executed-->
			<input type="hidden" value="1" name="query_selected" /> <!-- This is probably considered bad, but i don't know enough html to know otherwise-->
			
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter The number of results"><br>
			
			<label for="month">Month</label>
			<select name="month">
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q2">Query 2</h3>
		<p>In a given month of a given year, find k users who used a given hashtag in a tweet with the most number of retweets; show the user's screen name, user's category, tweet text, and retweet count in 
			descending order of the retweet count. Rationale: This query finds k most influential users who used a hashtag of interest that may represent a certain agenda.</br></p>
		<p>Input: value of k (e.g., 10), hashtag, month, and year (e.g., 2016)</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="2" name="query_selected" /> 
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter Number"><br>
			
			<label for="hashtag">Hashtag</label>
			<input type = "text" name = "hashtag" placeholder="NewYear"><br>
			
			<label for="month">Month</label>
			<select name="month">
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q3">Query 3</h3>
		<p>Find k hashtags that appeared in the most number of states in a given year; list the total number of states the hashtag appeared, the list of the distinct states it appeared, and the hashtag itself in descending order of the number of states the hashtag appeared.
		Rationale: This query finds k hashtags that are spread across the most number ofstates, which could indicate a certain agenda that is widely discussed.</br></p>
		<p>Input: value of k (e.g., 10), and year (e.g., 2016)</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="3" name="query_selected" /> 
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter Number"><br>

			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q6">Query 6</h3>
		<p>Find k users who used a certain set of hashtags in their tweets. Show the user's screen name and the state to which the user belongs in descending order of the number of followers. Rationale: This is to find k users who share similar interests.</br></p>
		<p>Input: value of k (e.g., 10), and hashtags</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="6" name="query_selected" /> 
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter Number"><br>
			<!-- TODO HASHTAGS LIST INPUT-->
			<label for="hashtags">Hashtags</label>
			<input type="text" name="hashtags"></br>
			<p>Please seperate hashtags with commas</p>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="10">Query 10</h3>
		<p>Find the list of distinct hashtags that appeared in one of the states in a given list in a given month of a given year; show the list of the hashtags and the names of the states in which they appeared.
			Rationale: This is to find common interest among the users in the states of interest.</br></p>
		<p>Input: List of states, month, year</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="10" name="query_selected" /> 
			<!-- I really don't like this, I am sure there is a better way to do this -->
			<label for="states">States Hold down the Ctrl (windows) / Command (Mac) button to select multiple </label>
			<select name="states" multiple>
					<option value="AL">Alabama</option><option value="AK">Alaska</option><option value="AZ">Arizona</option><option value="AR">Arkansas</option>
					<option value="CA">California</option><option value="CO">Colorado</option><option value="CT">Connecticut</option><option value="DE">Delaware</option>
					<option value="DC">District Of Columbia</option><option value="FL">Florida</option><option value="GA">Georgia</option><option value="HI">Hawaii</option>
					<option value="ID">Idaho</option><option value="IL">Illinois</option><option value="IN">Indiana</option><option value="IA">Iowa</option>
					<option value="KS">Kansas</option><option value="KY">Kentucky</option><option value="LA">Louisiana</option><option value="ME">Maine</option>
					<option value="MD">Maryland</option><option value="MA">Massachusetts</option><option value="MI">Michigan</option><option value="MN">Minnesota</option>
					<option value="MS">Mississippi</option><option value="MO">Missouri</option><option value="MT">Montana</option><option value="NE">Nebraska</option>
					<option value="NV">Nevada</option><option value="NH">New Hampshire</option><option value="NJ">New Jersey</option><option value="NM">New Mexico</option>
					<option value="NY">New York</option><option value="NC">North Carolina</option><option value="ND">North Dakota</option><option value="OH">Ohio</option>
					<option value="OK">Oklahoma</option><option value="OR">Oregon</option><option value="PA">Pennsylvania</option><option value="RI">Rhode Island</option>
					<option value="SC">South Carolina</option><option value="SD">South Dakota</option><option value="TN">Tennessee</option><option value="TX">Texas</option>
					<option value="UT">Utah</option><option value="VT">Vermont</option><option value="VA">Virginia</option><option value="WA">Washington</option>
					<option value="WV">West Virginia</option><option value="WI">Wisconsin</option><option value="WY">Wyoming</option>
			</select></br>
			<!-- TODO lsit of states somehow.--> 
			<label for="month">Month</label>
			<select name="month">
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q15">Query 15</h3>
		<p>Find users in a given sub-category along with the list of URLs used in the user's tweets in a given month of a given year. Show the user's screen name, the state the user belongs, and the list of URLs
		Rationale: This query finds URLs shared by a party.</br></p>
		<p>Input: subcatgory (party), month, yaear</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="15" name="query_selected" /> 
			<label for="party">Party</label>
			<select name="party"> <!-- TODO: User should be able to pick multiple -->
				<%
				for(String currParty : partyList){
					out.println("<option value="+ currParty + ">" + currParty + "</option>");
				}
				%>
			</select></br>
			<!-- TODO DROP DOWN list for subcategories-->
			<label for="month">Month</label>
			<select name="month">
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q23">Query 23</h3>
		<p>Find k most used hashtags with the count of tweets it appeared posted by a given sub-category of users in a list of months. Show the hashtag name and the count in descending order of the count.</br></p>
		<p>Input: Limit, year, Party (GOP, ...), List of Months</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="23" name="query_selected" /> 
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter Number"><br>
			<label for="party">Party</label>
			<select name="party"> 
				<%
				for(String currParty : partyList){
					out.println("<option value="+ currParty + ">" + currParty + "</option>");
				}
				%>
			</select></br>
			
			<label for="month">Month -Hold down the Ctrl (windows) / Command (Mac) button to select multiple </label>
			<select name="months" multiple> 
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
		
		<div class="query-box">
		<h3 id="q27">Query 27</h3>
		<p>Given a year and two selected months, report the screen names of influential users (based on top k retweet counts in that month in the two selected years).</br></p>
		<p>Input: Limit, month, year, select two months</p>
		<form method = "get" action = "ShowResult.jsp"> 
			<input type="hidden" value="27" name="query_selected" /> 
			<label for="limit">Limit</label>
			<input type = "text" name = "limit" placeholder="Enter Number"><br>
	
			<label for="month1">First Month</label>
			<select name="month1">
			<%
				for(int i=0; i<monthsList.size(); i++){
					out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
				}
			%>
			</select></br>
			
			<label for="month2">Second Month</label>
			<select name="month2">
			<%
			for(int i=0; i<monthsList.size(); i++){
				out.println("<option value="+ (i + 1) + ">" + monthsList.get(i) + "</option>");
			}
			%>
			</select></br>
			
			<label for="year">Year</label>
			<select name="year">
				<option value="2016">2016</option>
				<option value="2016">3000</option>
			</select></br>
		<input type = "submit" value = "Execute Query" />
		</form>
		</div>
<div class="admin-only-box" 
<%
if(isAdmin == false){
	out.println("hidden");
}  %>
>
		<div class="query-box">
		<h3 id="qi">Query Insert</h3>
		<p>Insert information of a new user into the database.</br></p>
		<p>Input: screen name, username, party, category, state, followers, following</p>
			<form method = "post" action = "ShowResult.jsp"> 
			<input type="hidden" value="0" name="query_selected" /> 
				<!-- Text Boxes-->
			<label for="screen_name">Screen name</label>
			<input type = "text" name = "screen_name" placeholder="Enter a new screen_name"><br>
			
			<label for="user_name">user name</label>
			<input type = "text" name = "user_name" placeholder="Enter a new user_name"><br>
			
			<label for="party">Party</label>
			<input type = "text" name = "party" placeholder="Enter a political party"><br>

			<label for="category">Category</label>
			<input type = "text" name = "category" placeholder="Enter a category"><br>

			<label for="state">State</label>
			<select name="state">
				<option value="AL">Alabama</option><option value="AK">Alaska</option><option value="AZ">Arizona</option><option value="AR">Arkansas</option>
				<option value="CA">California</option><option value="CO">Colorado</option><option value="CT">Connecticut</option><option value="DE">Delaware</option>
				<option value="DC">District Of Columbia</option><option value="FL">Florida</option><option value="GA">Georgia</option><option value="HI">Hawaii</option>
				<option value="ID">Idaho</option><option value="IL">Illinois</option><option value="IN">Indiana</option><option value="IA">Iowa</option>
				<option value="KS">Kansas</option><option value="KY">Kentucky</option><option value="LA">Louisiana</option><option value="ME">Maine</option>
				<option value="MD">Maryland</option><option value="MA">Massachusetts</option><option value="MI">Michigan</option><option value="MN">Minnesota</option>
				<option value="MS">Mississippi</option><option value="MO">Missouri</option><option value="MT">Montana</option><option value="NE">Nebraska</option>
				<option value="NV">Nevada</option><option value="NH">New Hampshire</option><option value="NJ">New Jersey</option><option value="NM">New Mexico</option>
				<option value="NY">New York</option><option value="NC">North Carolina</option><option value="ND">North Dakota</option><option value="OH">Ohio</option>
				<option value="OK">Oklahoma</option><option value="OR">Oregon</option><option value="PA">Pennsylvania</option><option value="RI">Rhode Island</option>
				<option value="SC">South Carolina</option><option value="SD">South Dakota</option><option value="TN">Tennessee</option><option value="TX">Texas</option>
				<option value="UT">Utah</option><option value="VT">Vermont</option><option value="VA">Virginia</option><option value="WA">Washington</option>
				<option value="WV">West Virginia</option><option value="WI">Wisconsin</option><option value="WY">Wyoming</option>
			</select></br>				

			<label for="followers">Followers</label>
			<input type="text" name="followers" placeholder="Number of followers"><br>
			
			<label for="following">following</label>
			<input type="text" name="following" placeholder="Number of following"><br>
			<input type = "submit" value = "Execute Query" />
			</form>
		</div>
		<div class="query-box">
				<h3 id="qd">Query Delete</h3>
				<p>Delete a given user and all the tweets the user has tweeted, relevant hashtags, and users mentioned</br></p>
				<p>Input: screen name</p>
				<form method = "post" action = "ShowResult.jsp"> 
					<input type="hidden" value="-1" name="query_selected" /> 
					<label for="screen_name">Screen name</label>
					<input type = "text" name = "screen_name" placeholder="Enter a new screen_name"><br>	
					<input type = "submit" value = "Execute Query" />
				</form>
		</div>
</div><!-- End of admin only box. -->
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