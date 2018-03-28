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

		final TimeParam tp = new TimeParam();
		if (!checkTimePeriod(request, tp)) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid time_period");
		}

		final String strAppId = request.getParameter("app_id");
		final String strTimePeriod = request.getParameter("time_period");
		final String strStartDate = request.getParameter("start_date");
		final String strEndDate = request.getParameter("end_date");
		final String strTableName;

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

		//check APP ID from DB_MORE before connect to DB_Tracker
	/*	int nCheckAppIdExist = checkAppIdExistance(strAppId);
		if (0 >= nCheckAppIdExist) {
			switch (nCheckAppIdExist) {
			case 0:
				return ApiResponse.appIdNotFound();
			default:
				return ApiResponse.byReturnStatus(nCheckAppIdExist);
			}
		}*/

		final Connection conn = connect(Common.DB_URL_TRACKER, Common.DB_USER_TRACKER, Common.DB_PASS_TRACKER);
		if (conn == null) {
			return ApiResponse.error(ApiResponse.STATUS_INTERNAL_ERROR, "test.");
		}

		AppListData appListData = new AppListData();
		int nCheckTable = checkTrackerAppIdExist(strAppId, appListData);
		if (0 < nCheckTable) {
			strTableName = appListData.table_name;
		} else {
			switch (nCheckTable) {
			case 0:
				return ApiResponse.unauthorizedError();
			default:
				return ApiResponse.byReturnStatus(nCheckTable);
			}
		}

		JSONObject jobj = new JSONObject();
		JSONArray resArray = new JSONArray();
		int nCount = queryCoordinates(strStartDate, strEndDate, tp.start_hour, tp.end_hour, strTableName, resArray);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate(); 
			jobj.put("count", nCount);
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
		return paramMap.containsKey("app_id") && paramMap.containsKey("time_period")
				&& paramMap.containsKey("start_date") && paramMap.containsKey("end_date");
	}

	public boolean checkTimePeriod(HttpServletRequest request, TimeParam tp) {
		tp.time_period = request.getParameter("time_period");
		if (tp.time_period == null) {
			return false;

		} else {
			tp.time_period = request.getParameter("time_period").trim();
			
			if (tp.time_period.equals("morning")) {
				tp.start_hour = "06";
				tp.end_hour = "11";
			} else if (tp.time_period.equals("noon")) {
				tp.start_hour = "12";
				tp.end_hour = "17";
			} else if (tp.time_period.equals("night")) {
				tp.start_hour = "18";
				tp.end_hour = "23";
			} else if (tp.time_period.equals("mid")) {
				tp.start_hour = "00";
				tp.end_hour = "05";
			} else {
				
				return false;
			}
		}
		return true;
	}

	public int queryCoordinates(final String strStartDate, final String strEndDate, final String strStartHour,
			final String strEndHour, final String strTableName, final JSONArray out) {
System.out.println("strTableName: " + strTableName);
		
		int status = select(null,
				"SELECT latitude, longitude FROM ? WHERE create_date BETWEEN ? AND ? AND HOUR(create_date) BETWEEN ? AND ?",
				new Object[] { strTableName, strStartDate, strEndDate, strStartHour, strEndHour },
				new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							JSONObject jobj = new JSONObject();
							jobj.put("latitude", rs.getString("latitude"));
							jobj.put("longitude", rs.getString("longitude"));
							out.put(jobj);
						}
						return itemCount;
					}
				});
		return status;
	}

	private static class TimeParam {
		String time_period;
		String start_hour;
		String end_hour;
	}
	
	
	
	%>