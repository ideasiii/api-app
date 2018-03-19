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


		int nCheckAppIdExit = checkAppIdExistance(strAppId);
		
		if (0 > nCheckAppIdExit)
		{
			return ApiResponse.appIdNotFound();
		}

		JSONObject jobj = new JSONObject();
		JSONArray resArray = new JSONArray();
		String strRequireMonth = getYearMonth(strStartDate);
		int nCount = queryDailyUserAmount(strAppId, strRequireMonth, resArray);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate();
			jobj.put("result", resArray);
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

	public String getYearMonth(String strDate) { 
		String str[] = strDate.split("-");
		int year = Integer.parseInt(str[0]);
		int month = Integer.parseInt(str[1]);
		String strYearMonth = year + "-" + month + "-";
		System.out.println("*****strYearMonth: " + strYearMonth);
		return strYearMonth;
	}
	
	
	public int queryDailyUserAmount(final String strAppId, final String strRequireMonth, final JSONArray out) {

		int status = select(null, "SELECT `start_date`, `count` FROM `app_user_period_amount` WHERE `app_id`=? AND `start_date` LIKE? AND `period`=?",
				new Object[] {strAppId, strRequireMonth, PERIOD_TYPE_DAY}, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							JSONObject jobj = new JSONObject();
							jobj.put("start_date", rs.getString("start_date"));
							jobj.put("count", Integer.toString(rs.getInt("count")));
							out.put(jobj);
						}
						return itemCount;
					}
				});
		return status;
	}


	
	
	%>