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


	if (!isValidAppId(strAppId)) {
		return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
	}
	

	int nCheckAppIdExist = checkAppIdExistance(strAppId);
	
	if (0 >= nCheckAppIdExist)
	{
		return ApiResponse.appIdNotFound();
	}
	
	JSONObject jobj = new JSONObject();
	JSONArray resArray = new JSONArray();
	int nCount = queryCategoryArray(strAppId, resArray);

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
	return paramMap.containsKey("app_id");
	}
	
	public int queryCategoryArray(final String strAppId, final JSONArray out) {

		int status = select(null, "SELECT `category`, `count` FROM `app_user_locational_category` WHERE `app_id`=? ORDER BY `count` DESC",
				new Object[] {strAppId}, new ResultSetReader() {
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