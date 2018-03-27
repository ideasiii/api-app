<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.Map"%>

<%@include file="../api_common.jsp"%>
<%@include file="../response_utility.jsp"%>

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

		if (0 >= nCheckAppIdExist) {
			return ApiResponse.appIdNotFound();
		}

		LocatData locatData = new LocatData();
		JSONObject jobj;
		int nCount = queryLocationalAmount(strAppId, strStartDate, strEndDate, locatData);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate();
			jobj.put("north_count", locatData.north_count);
			jobj.put("south_count", locatData.south_count);
			jobj.put("east_count", locatData.east_count);
			jobj.put("mid_count", locatData.mid_count);

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

	public int queryLocationalAmount(final String strAppId, final String strStartDate, final String strEndDate,
			final LocatData locatData) {

		int status = select(null,
				"SELECT * FROM `app_user_locational_amount` WHERE `app_id`=? AND `start_date`=? AND `end_date`=? AND `period`=?",
				new Object[] { strAppId, strStartDate, strEndDate, PERIOD_TYPE_MONTH }, new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							locatData.app_id = rs.getString("app_id");
							locatData.start_date = rs.getString("start_date");
							locatData.end_date = rs.getString("end_date");
							locatData.north_count = rs.getInt("north_count");
							locatData.east_count = rs.getInt("east_count");
							locatData.south_count = rs.getInt("south_count");
							locatData.mid_count = rs.getInt("mid_count");
							locatData.update_date = rs.getString("update_date");
						}
						return itemCount;
					}
				});
		return status;
	}

	public static class LocatData {
		public String app_id;
		public String start_date;
		public String end_date;
		public int north_count;
		public int mid_count;
		public int east_count;
		public int south_count;
		public String update_date;
	}
	
	%>