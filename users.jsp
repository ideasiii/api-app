<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>

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
        return ApiResponse.error(ApiResponse.STATUS_MISSING_PARAM);
    }

	final String strAppId = request.getParameter("app_id");
	final String strDate = request.getParameter("date");    

	if (!isValidAppId(strAppId)) {
    return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
	}
    
	if (!isValidDate(strDate)) {
	    return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid date.");
		}
    
    TotalAmountData amountData = new TotalAmountData();
	JSONObject jobj;
	int nStatus = queryTotalUserAmount(strAppId, strDate, amountData);
    
	if (0 > nStatus) {
		jobj = ApiResponse.successTemplate();
		jobj.put("count", amountData.count);
	} else {
		switch (nStatus) {
		case 0:
			jobj = ApiResponse.appIdNotFound();
			break;
		default:
			jobj = ApiResponse.byReturnStatus(nStatus);
		}
	}
	return jobj;
}


public boolean hasRequiredParameters(final HttpServletRequest request) {
    Map paramMap = request.getParameterMap();
    return paramMap.containsKey("app_id") && paramMap.containsKey("date");
}


public int queryTotalUserAmount(final String strAppId, final String strDate, final TotalAmountData amountData) {

int status = select(null, "SELECT `count` FROM `app_user_total_amount` WHERE `app_id`=? AND `date`=?", new Object[]{strAppId, strDate}, new ResultSetReader() {
public int read(ResultSet rs) throws Exception {	
	int itemCount = 0;
	
	while (rs.next()){
	++itemCount;
	amountData.app_id = rs.getString("app_id");
	amountData.date = rs.getString("date");
	amountData.count = rs.getInt("count");
	amountData.update_date = rs.getString("update_date");
	}
	return itemCount;
}	
});
return status;
}


public static class TotalAmountData {
	public String app_id;
	public String date;
	public int count;
	public String update_date;
}

%>