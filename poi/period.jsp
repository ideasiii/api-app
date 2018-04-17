<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@include file="poi_common.jsp"%>


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
	final String strTimeInterval = request.getParameter("time_interval");

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

	if (!checkTimeInterval(strTimeInterval)) {
		return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid time_interval.");
	}

	int nCheckAppIdExist = checkAppIdExistance(strAppId);
	
	if (0 >= nCheckAppIdExist)
	{
		return ApiResponse.appIdNotFound();
	}
	
	JSONObject jobj = new JSONObject();
	JSONArray resArray = new JSONArray();
	int nCount = queryPeriodCateArray(strAppId, strStartDate, strEndDate, strTimeInterval, resArray);

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
	return paramMap.containsKey("app_id") && paramMap.containsKey("start_date") && paramMap.containsKey("end_date") && paramMap.containsKey("time_interval");
	}
	
	public int queryPeriodCateArray(final String strAppId, final String strStartDate, final String strEndDate, final String strTimeInterval, final JSONArray out) {

		int status = select(null, "SELECT `category`, `count` FROM `app_user_pre_period` WHERE `app_id`=? AND `time_interval`=? AND `start_date`=? AND `end_date`=? ORDER BY `count` DESC",
				new Object[] {strAppId, strTimeInterval, strStartDate, strEndDate}, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							JSONObject jobj = new JSONObject();
							jobj.put("category", rs.getString("category"));
							jobj.put("count", rs.getInt("count"));
							out.put(jobj);
						}
						return itemCount;
					}
				});
		return status;
	}
	
	
	%>