<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.Map"%>
<%@ page import="more.Mongo"%>

<%@include file="../api_common.jsp"%>
<%@include file="../response_utility.jsp"%>

<%
	request.setCharacterEncoding("UTF-8");
	JSONObject jobj = processRequest(request);
	out.print(jobj.toString());
%>

<%!private JSONObject processRequest(HttpServletRequest request) {
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

		//check APP ID from MYSQLDB_MORE before connect to MONGO
		int nCheckAppIdExist = checkAppIdExistance(strAppId);
		if (0 >= nCheckAppIdExist) {
			switch (nCheckAppIdExist) {
			case 0:
				return ApiResponse.appIdNotFound();
			default:
				return ApiResponse.byReturnStatus(nCheckAppIdExist);
			}
		}

		JSONObject jobj = new JSONObject();
		JSONArray resArray = new JSONArray();
		int nCount = queryTrackerData(strAppId, strStartDate, strEndDate, resArray);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate();
			jobj.put("result", resArray);
			System.out.println("********************" + resArray.length());

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

	public int queryTrackerData(final String strAppId, final String strStartDate, final String strEndDate,
			final JSONArray out) {
		boolean closeConnOnReturn = false;
		int status = 0;
		Mongo mongo = new Mongo();

		try {

			mongo.Connect(Common.DB_IP_MONGO, 27017);
			closeConnOnReturn = true;
			ArrayList<String> listResult = new ArrayList<String>();
			ArrayList<Mongo.Filter> listFilter = new ArrayList<Mongo.Filter>();

			Mongo.Filter f1 = new Mongo.Filter();
			f1.strField = "ID";
			f1.mapFilter.put("$regex", strAppId);
			listFilter.add(f1);

			if (null != strStartDate || null != strEndDate) {
				Mongo.Filter f2 = new Mongo.Filter();
				f2.strField = "create_date";
				if (null != strStartDate) {
					f2.mapFilter.put("$gte", strStartDate + "00:00:00");
				}

				if (null != strEndDate) {
					f2.mapFilter.put("$lte", strEndDate + " 23:59:59");
				}
				listFilter.add(f2);
			}

			status = mongo.query("access", "mobile", listFilter, listResult);
			if (0 < status) {
			out.put(listResult);
			}

		} catch (Exception e) {
			e.printStackTrace();
			status = ERR_EXCEPTION;
		} finally {
			if (closeConnOnReturn) {
				mongo.close();
			}
			return status;
		}
		
	}
	%>