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
	final String strArea = request.getParameter("area");

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

	if (!checkArea(strArea)) {
		return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid area.");
	}

	int nCheckAppIdExist = checkAppIdExistance(strAppId);
	
	if (0 >= nCheckAppIdExist)
	{
		return ApiResponse.appIdNotFound();
	}
	
	JSONObject jobj = new JSONObject();
	JSONArray resArray = new JSONArray();
	int nCount = queryAreaCateArray(strAppId, strStartDate, strEndDate, strArea, resArray);

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
	return paramMap.containsKey("app_id") && paramMap.containsKey("start_date") && paramMap.containsKey("end_date") && paramMap.containsKey("area");
	}
	
	public int queryAreaCateArray(final String strAppId, final String strStartDate, final String strEndDate, final String strArea, final JSONArray out) {

		int status = select(null, "SELECT `category`, `count` FROM `app_user_pre_area` WHERE `app_id`=? AND `area`=? AND `start_date`=? AND `end_date`=? ORDER BY `count` DESC",
				new Object[] {strAppId, strArea, strStartDate, strEndDate}, new ResultSetReader() {
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