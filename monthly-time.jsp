<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.Map"%>
<%@ page import="java.time.YearMonth"%>

<%@include file="api_common.jsp"%>
<%@include file="response_utility.jsp"%>  

<% 
	request.setCharacterEncoding("UTF-8");
	JSONObject jobj = processRequest(request);
	out.print(jobj.toString());
%>

<%!
		private JSONObject processRequest(HttpServletRequest request) {
		if (!hasRequiredParameters(request)) {
			return ApiResponse.error(ApiResponse.STATUS_MISSING_PARAMETER);
		}

		final String strAppId = request.getParameter("app_id");
		final String strStartDate = request.getParameter("start_date");
		final String strEndDate = request.getParameter("end_date");

		if (!isValidAppId(strAppId)) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
		}

		if (!isValidDate(strStartDate, "yyyy-MM-dd")) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid start_date.");
		}
		
		if (!isValidDate(strEndDate, "yyyy-MM-dd")) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid end_date.");
		}
		
		if (!isValidStartDate(strStartDate, strEndDate, "yyyy-MM-dd")) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid period values.");
		}

		int nCheckAppIdExist = checkAppIdExistance(strAppId);
		
		if (0 >= nCheckAppIdExist)
		{
			return ApiResponse.appIdNotFound();
		}
			
		TimePeriodData timeData = new TimePeriodData();
		JSONObject jobj;
		int nCount = queryTimePeriodUser(strAppId, strStartDate, strEndDate, timeData);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate();
			jobj.put("morning_count", timeData.morning_count);
			jobj.put("noon_count", timeData.noon_count);
			jobj.put("night_count", timeData.night_count);
			jobj.put("mid_count", timeData.mid_count);
			
		} else {
			switch (nCount) {
			case 0:
				jobj = ApiResponse.dataNotFound();
				break;
			default:
				jobj = ApiResponse.byReturnStatus(nCount);
			}
		}
		return jobj;
	}


	public boolean hasRequiredParameters(final HttpServletRequest request) {
		Map paramMap = request.getParameterMap();
		return paramMap.containsKey("app_id") && paramMap.containsKey("start_date") && paramMap.containsKey("end_date");
	}
	

	public int getDaysInMonth(String strDate) { 
		//get number of days in particular month of particular year
		String str[] = strDate.split("-");
		int year = Integer.parseInt(str[0]);
		int month = Integer.parseInt(str[1]);
		
		YearMonth yearMonthObject = YearMonth.of(year, month);
		int daysInMonth = yearMonthObject.lengthOfMonth();
		System.out.println("*****month: " + month + " year: " + year + " daysInMonth: " + daysInMonth);
		return daysInMonth;
	}
	

	public int queryTimePeriodUser(final String strAppId, final String strStartDate, final String strEndDate, final TimePeriodData timeData) {

		int status = select(null, "SELECT * FROM `app_user_amount_bytime` WHERE `app_id`=? AND `start_date`=? AND `end_date`=? AND `period`=?",
				new Object[] {strAppId, strStartDate, strEndDate, PERIOD_TYPE_MONTH}, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;
						int nDays = getDaysInMonth(strStartDate);

						while (rs.next()) {
							++itemCount;
							timeData.app_id = rs.getString("app_id");
							timeData.start_date = rs.getString("start_date");
							timeData.end_date = rs.getString("end_date");
							//AVG(day count) in month 
							timeData.morning_count = (rs.getInt("morning_count")/nDays);
							timeData.noon_count = (rs.getInt("noon_count")/nDays);
							timeData.night_count = (rs.getInt("night_count")/nDays);
							timeData.mid_count = (rs.getInt("mid_count")/nDays);
							timeData.update_date = rs.getString("update_date");
						}
						return itemCount;
					}
				});
		return status;
	}

	public static class TimePeriodData {
		public String app_id;
		public String start_date;
		public String end_date;
		public int morning_count;
		public int noon_count;
		public int night_count;
		public int mid_count;
		public String update_date;
	}
	
	
	%>