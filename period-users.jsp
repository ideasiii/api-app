<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.Map"%>

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

		if (!isValidDate(strStartDate, "yyyy-mm-dd")) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid start_date.");
		}
		
		if (!isValidDate(strEndDate, "yyyy-mm-dd")) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid end_date.");
		}

		int nCheckAppIdExit = checkAppIdExistance(strAppId);
		
		if (0 > nCheckAppIdExit)
		{
			return ApiResponse.appIdNotFound();
		}
			
		PeriodAmountData amountData = new PeriodAmountData();
		JSONObject jobj;
		int nCount = queryPeriodUserAmount(strAppId, strStartDate, strEndDate, amountData);

		if (0 > nCount) {
			jobj = ApiResponse.successTemplate();
			jobj.put("count", amountData.count);
			System.out.print("count: " + amountData.count);
			System.out.print("update_date: " + amountData.update_date);
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

	public int queryPeriodUserAmount(final String strAppId, final String strStartDate, final String strEndDate, final PeriodAmountData amountData) {

		int status = select(null, "SELECT `count` FROM `app_user_period_amount` WHERE `app_id`=? AND `start_date`=? AND `end_date`=?",
				new Object[] {strAppId, strStartDate, strEndDate}, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							amountData.app_id = rs.getString("app_id");
							amountData.start_date = rs.getString("start_date");
							amountData.end_date = rs.getString("end_date");
							amountData.count = rs.getInt("count");
							amountData.update_date = rs.getString("update_date");
						}
						return itemCount;
					}
				});
		return status;
	}

	public static class PeriodAmountData {
		public String app_id;
		public String start_date;
		public String end_date;
		public int count;
		public String update_date;
	}
	
	
	%>