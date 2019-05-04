<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Results</title>
<meta name="author" content="Will Sartin & Tom Staudt">
</head>
<body>
	<!-- At the begining of this file we have a few isntance variables, and some general methods that will be used throughout the class  -->

	<!-- any error is redirected to ShowError.jsp -->
	<%@ page errorPage="ShowError.jsp"%>
	<!-- include all the database connection configurations -->
	<%@ include file="DBInfo.jsp"%>
	<%! 
	public Connection conn = null;
	public ResultSet rs = null;
	public PreparedStatement stmt = null;
	
	/**
	* This method takes a list of 'headers', a list of 'body' arguments, and the result set.
	* It iterates through the lists, and constructs a html table to be printed by the browser
	* @return String that is the table to be printed
	*/
	public String getStringToPrint(List<String> headers, List<String> body, ResultSet rs) { 
		int rowNum = 1;
		String result = "";
		result += "<table cellpadding=\"2\" cellspacing=\"2\" border=\"1\"><tr><th>#</th>";
		for(String h : headers){
			result+= "<th>" + h + "</th>";
		}
		result += "</tr>";
		try{
			while(rs.next()){
				int keys = body.size();
				result += "<tr>";
				result+= "<td>" + rowNum++ + "</td>";
				for(String b : body){
					
					Object item = rs.getObject(b);
					String strValue = (item == null ? null : item.toString());
					result+="<td>" + strValue + "</td>";
				}
				result += "</tr>";
			}
		}catch(Exception e){}
		result += "</table>";
		return result;
	} 

	%>
	<!-- All the queries are these strings. I hope to get back to this and change it up so it is cleaner -->
	<!-- This class is a series of if statments that check what the query was. It then picks the correct query and executes it -->
	<%
		String Q_1 = "SELECT t.retweet_count, t.tweet_text, t.screen_name, u.category, u.party "
					+"FROM tweets t, users u "
					+"WHERE t.screen_name = u.screen_name "
					+"AND t.posted_month = ? "
					+"AND t.posted_year = ? "
					+"ORDER BY t.retweet_count DESC LIMIT ?"; 
					
		String Q_2 ="SELECT t.screen_name, u.category,  t.tweet_text, t.retweet_count "
					+"FROM users u, tweets t, hashtags h "
					+"WHERE h.word = ? "
					+"AND t.screen_name = u.screen_name "
					+"AND h.tid = t.tid "
					+"AND t.posted_month = ? "
					+"AND t.posted_year = ? "
					+"ORDER BY t.retweet_count DESC LIMIT ? ";		
		
		String Q_3 ="SELECT DISTINCT h.word, GROUP_CONCAT(DISTINCT location_state SEPARATOR \', \') as appeared_in, "
						+"COUNT(DISTINCT location_state) as num_of_states "
					+"FROM hashtags h, users u "
					+"WHERE h.tid IN "
						+"(SELECT t.tid "
						+"FROM tweets t "
						+"WHERE t.screen_name = u.screen_name "
						+ "AND t.posted_year = ?) "
					+"GROUP BY h.word "
					+"ORDER BY num_of_states DESC LIMIT ? ";
					
		String Q_6 ="SELECT DISTINCT u.screen_name, u.location_state "
					+"FROM users u, hashtags h, tweets t "
					+"WHERE u.screen_name = t.screen_name "
						+"AND t.tid = h.tid "
						+"AND ( FIND_IN_SET (h.word, ?) ) " //list of words
					+"ORDER BY u.followers_count DESC LIMIT ? "; //number of results desired
		
		String Q_10 ="SELECT DISTINCT h.word, u.location_state "
					+"FROM users u, tweets t, hashtags h "
					+"WHERE  t.screen_name = u.screen_name "
						+"AND h.tid = t.tid "
						+"AND ( FIND_IN_SET( u.location_state, ? ) ) " 
						+ "AND t.posted_month = ? "
						+"AND t.posted_year = ? "
					+"ORDER BY u.location_state";
				
		String Q_15 ="SELECT DISTINCT usr.screen_name, usr.location_state, GROUP_CONCAT(DISTINCT url.link_path SEPARATOR \', \') as paths "
					+"FROM users usr, tweets t, urls url "
					+"WHERE  t.screen_name = usr.screen_name "
						+"AND url.tid = t.tid "
						+"AND usr.party = ? "
						+"AND t.posted_month = ? "
						+"AND t.posted_year = ? "
					+"GROUP BY usr.screen_name, usr.location_state "
					+"ORDER BY usr.screen_name ";
		
		String Q_23 = "SELECT h.word, COUNT(h.word) AS Occurences "
					+"FROM hashtags h "
					+"WHERE h.tid IN "
						+"(SELECT t.tid "
							+"FROM tweets t, users u "
							+"WHERE t.screen_name = u.screen_name "
								+"AND u.party = ? "
								+"AND t.posted_year = ? "
								+"AND  FIND_IN_SET(t.posted_month, ?) != 0) "
					+"GROUP BY h.word "
					+"ORDER BY occurences DESC LIMIT ? ";
				
		String Q_27 ="SELECT t.screen_name "
					+"FROM tweets t, users u "
					+"WHERE t.screen_name = u.screen_name "
						+"AND (t.posted_month = ? " 
						+"OR t.posted_month = ?) "
						+"AND t.posted_year = ? "
					+"ORDER BY t.retweet_count DESC LIMIT ?";

		String Q_DELETE ="DELETE FROM users "
					+"WHERE screen_name = ? ";
					
		String IS_USER_IN_DB ="SELECT EXISTS(SELECT * FROM users WHERE screen_name = ?) as present";
		
		int limit = 1;
		int month = 1;
		int year = 2016;
		String username = "";
		String hashtag = "";
		String party = "";
		String screenname = "";
		String category ="";
		
		int querySelected = Integer.parseInt(request.getParameter("query_selected"));
		
		if(querySelected == -1){	
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				
				screenname = (request.getParameter("screen_name") != null) ? request.getParameter("screen_name") : "na";
				stmt = conn.prepareStatement(Q_DELETE);
				stmt.setString(1, screenname);
				
				int success = stmt.executeUpdate();
				String result = (success == 1)? "User was deleted" : "User could not be found";
				out.println(result);
			}catch(Exception e){
				out.println("User was not deleted");
			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
		else if(querySelected == 0){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				screenname = (request.getParameter("screen_name") != null) ? request.getParameter("screen_name") : "na";
				username = (request.getParameter("user_name") != null) ? request.getParameter("user_name") : "na";
				party = (request.getParameter("party") != null) ? request.getParameter("party") : "na";
				category = (request.getParameter("category") != null) ? request.getParameter("category") : "na";
				String location_state = (request.getParameter("state") != null) ? request.getParameter("state") : "na";
				int followers = Integer.parseInt(request.getParameter("followers"));
				int following = Integer.parseInt(request.getParameter("following"));

				if(screenname == null || screenname.equals("na") || screenname.length() == 0){
					out.println("The user must have a screen name.");
				}else{
					String Q_INSERT ="INSERT INTO users (screen_name, user_name, party, category, location_state, followers_count, following_count) "
							+"VALUES (?, ?, ?, ?, ?, ?, ?) ";
					stmt = conn.prepareStatement(Q_INSERT);
					stmt.setString(1, screenname);
					stmt.setString(2, username);
					stmt.setString(3, party);
					stmt.setString(4, category);
					stmt.setString(5, location_state);
					stmt.setInt(6, followers);
					stmt.setInt(7, following);
	 
					Integer allGood = stmt.executeUpdate();
					
					if(allGood == 1){
						out.println("User has been added");
					}else{
						out.println("It Looks like User is already in the Database");
					}
				}
			}catch(Exception e){
					out.println("It Looks like User is already in the Database");
			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
		else if(querySelected == 1){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				//parse request
				limit = Integer.parseInt(request.getParameter("limit"));
				month = Integer.parseInt(request.getParameter("month"));
				year = Integer.parseInt(request.getParameter("year"));
				
				//make query
				stmt = conn.prepareStatement(Q_1);
				stmt.setInt(1, month);
				stmt.setInt(2, year);
				stmt.setInt(3, limit);

				rs = stmt.executeQuery();

				List<String> headers = new ArrayList<String>(); 
				headers.add("retweet_count");	headers.add("screen_name");	headers.add("tweet_text");	headers.add("category");	headers.add("party");
				List<String> body = new ArrayList<String>();
				body.add("retweet_count");	body.add("tweet_text");	body.add("screen_name");	body.add("category");	body.add("party");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
		else if(querySelected == 2){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				//parse request
				limit = Integer.parseInt(request.getParameter("limit"));
				month = Integer.parseInt(request.getParameter("month"));
				year = Integer.parseInt(request.getParameter("year"));
				hashtag = request.getParameter("hashtag");
				
				//make query
				stmt = conn.prepareStatement(Q_2);
				stmt.setString(1, hashtag);
				stmt.setInt(2, month);
				stmt.setInt(3, year);
				stmt.setInt(4, limit);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("screen_name");	headers.add("category");	headers.add("tweet_text");	headers.add("retweet_count");
				List<String> body = new ArrayList<String>();
				body.add("screen_name");	body.add("category");	body.add("tweet_text");	body.add("retweet_count");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}

		}
		else if(querySelected == 3){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				
				limit = Integer.parseInt(request.getParameter("limit"));
				year = Integer.parseInt(request.getParameter("year"));
				
				stmt = conn.prepareStatement(Q_3);
				stmt.setInt(1, year);
				stmt.setInt(2, limit);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("hashtag");	headers.add("state");	headers.add("Number of states");
				List<String> body = new ArrayList<String>();
				body.add("word");	body.add("appeared_in");	body.add("num_of_states");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
		else if(querySelected == 6){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				limit = Integer.parseInt(request.getParameter("limit"));
				String[] hashtagArray = request.getParameterValues("hashtags");
				String inputForHashtags = Arrays.toString(hashtagArray).replaceAll("[\\[.\\].\\s+]", "");
				//make query
				stmt = conn.prepareStatement(Q_6);
				stmt.setString(1, inputForHashtags);
				stmt.setInt(2, limit);
				
				out.println("<h2>Query 6</h2>");
				out.println("<p>Input: " + inputForHashtags + "</p>");
				rs = stmt.executeQuery();

				List<String> headers = new ArrayList<String>(); 
				headers.add("screen_name");	headers.add("state");
				List<String> body = new ArrayList<String>();
				body.add("screen_name");	body.add("location_state");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);	
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}

		}
		else if(querySelected == 10){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				//parse request
				month = Integer.parseInt(request.getParameter("month"));
				year = Integer.parseInt(request.getParameter("year"));
				
				String[] satesArray = request.getParameterValues("states");
				String inputForStates = Arrays.toString(satesArray).replaceAll("[\\[.\\].\\s+]", "");
					
				stmt = conn.prepareStatement(Q_10);
				stmt.setString(1, inputForStates);
				stmt.setInt(2, month);
				stmt.setInt(3, year);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("hashtag");	headers.add("state");
				List<String> body = new ArrayList<String>();
				body.add("word");	body.add("location_state");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);	
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}

		}
		else if(querySelected == 15){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				//parse request
				party = request.getParameter("party");
				month = Integer.parseInt(request.getParameter("month"));
				year = Integer.parseInt(request.getParameter("year"));
				
				stmt = conn.prepareStatement(Q_15);
				stmt.setString(1, party);
				stmt.setInt(2, month);
				stmt.setInt(3, year);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("screen_name");	headers.add("state"); headers.add("urls");
				List<String> body = new ArrayList<String>();
				body.add("screen_name");	body.add("location_state");	body.add("paths");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);	
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
		else if(querySelected == 23){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				limit = Integer.parseInt(request.getParameter("limit"));
				party = request.getParameter("party");
				year = Integer.parseInt(request.getParameter("year"));
				
				String[] monthsFromForm = request.getParameterValues("months");
				String monthsInput = Arrays.toString(monthsFromForm).replaceAll("[\\[.\\].\\s+]", "");
				
				stmt = conn.prepareStatement(Q_23);
				stmt.setString(1, party);
				stmt.setInt(2, year);
				stmt.setString(3, monthsInput);
				stmt.setInt(4, limit);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("hashtag");	headers.add("Occurences");
				List<String> body = new ArrayList<String>();
				body.add("word");	body.add("Occurences");	
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);	
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
			//parse request

		}
		else if(querySelected == 27){
			try{
				Class.forName("com.mysql.jdbc.Driver");
				conn = DriverManager.getConnection(DB_URL, DB_USERNAME, DB_PASSWORD);
				limit = Integer.parseInt(request.getParameter("limit"));
				int monthOne = Integer.parseInt(request.getParameter("month1"));
				int monthTwo = Integer.parseInt(request.getParameter("month2"));
				year = Integer.parseInt(request.getParameter("year"));
				
				stmt = conn.prepareStatement(Q_27);
				stmt.setInt(1, monthOne);
				stmt.setInt(2, monthTwo);
				stmt.setInt(3, year);
				stmt.setInt(4, limit);
				
				rs = stmt.executeQuery();
				
				List<String> headers = new ArrayList<String>(); 
				headers.add("screen_name");
				List<String> body = new ArrayList<String>();
				body.add("screen_name");
				String toPrint = getStringToPrint(headers, body, rs);
				out.println(toPrint);	
			}catch(Exception e){

			}finally{
				if (rs!= null) rs.close();
				if (stmt!= null) stmt.close();
				if (conn != null) conn.close();
			}
		}
	%>
	<br />
	<form action="QuerySelector.jsp">
		<input type="submit" value="BACK" />
	</form>
</body>
</html>