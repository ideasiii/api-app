<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@page import="java.io.*"%> 	
	
<%@include file="poi_common.jsp"%>


<%
	request.setCharacterEncoding("UTF-8");
	JSONObject jobj = processRequest(request);
	out.print(jobj.toString());
%>

<%!

	private JSONObject processRequest(HttpServletRequest request) throws ServletException, IOException
{
	if (!hasRequiredParameters(request)) {
		return ApiResponse.error(ApiResponse.STATUS_MISSING_PARAMETER);
	}

	final String strAppId = request.getParameter("app_id");
	//final String strCategory = request.getParameter("category");
	String strCategory =  request.getParameter("category");
	strCategory = new String(strCategory.getBytes("ISO-8859-1"),"UTF-8");

	if (!isValidAppId(strAppId)) {
		return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
	}
	
	if (!isNotEmptyString(strCategory)) {
		return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid category.");
	}

	int nCheckAppIdExist = checkAppIdExistance(strAppId);
	
	if (0 >= nCheckAppIdExist)
	{
		return ApiResponse.appIdNotFound();
	}
	
	JSONObject jobj = new JSONObject();
	JSONArray resArray = new JSONArray();
	int nCount = queryCatePoiArray(strAppId, strCategory, resArray);

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
	
	public int queryCatePoiArray(final String strAppId,final String strCategory, final JSONArray out) {

		int status = select(null, "SELECT `poi`, `category`, `count` FROM `app_user_locational_category_poi` WHERE `app_id`=? AND `category`=? ORDER BY `count` DESC",
				new Object[] {strAppId, strCategory}, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							JSONObject jobj = new JSONObject();
							jobj.put("category", rs.getString("category"));
							jobj.put("poi", rs.getString("poi"));
							jobj.put("count", rs.getInt("count"));
							out.put(jobj);
						}
						return itemCount;
					}
				});
		return status;
	}
	
	
	%>