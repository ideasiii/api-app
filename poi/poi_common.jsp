<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.Map"%>

<%@include file="../api_common.jsp"%>
<%@include file="../response_utility.jsp"%>

<%!


	public static class PoiData {
		public String app_id;
		public String start_date;
		public String end_date;
		public String period;
		public String time_interval;
		public String area;
		public String category;
		public String poi;
		public int count;
		public String update_date;
	}
	
	public boolean checkTimeInterval(final String ti) {
		return ti.equals("morning") || ti.equals("noon") || ti.equals("night") || ti.equals("mid");
	}
	
	public boolean checkArea(final String a) {
		return a.equals("north") || a.equals("mid") || a.equals("east") || a.equals("south");
	}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	%>