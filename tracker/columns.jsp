<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.*"%>
<%@ page import="com.mongodb.MongoClient"%>
<%@ page import="com.mongodb.DB"%>
<%@ page import="com.mongodb.DBCollection"%>
<%@ page import="com.mongodb.BasicDBObject"%>
<%@ page import="com.mongodb.DBObject"%>
<%@ page import="com.mongodb.DBCursor"%>
<%@ page import="com.mongodb.BasicDBList"%>
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

		if (!isValidAppId(strAppId)) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
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
		int nCount = getTrackerColumnName(strAppId, resArray);

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

	public int getTrackerColumnName(final String strID, final JSONArray out) {
		MongoClient mongoClient = null;
		boolean closeConnOnReturn = false;
		int status = 0;

		try {

			mongoClient = new MongoClient(Common.DB_IP_MONGO, 27017);
			DB db = mongoClient.getDB("access");

			if (null != db) {
				DBCollection collection = db.getCollection("mobile");
				closeConnOnReturn = true;

				BasicDBObject dataQuery = new BasicDBObject();
				dataQuery.put("ID", new BasicDBObject("$regex", strID));
				DBCursor cursor = collection.find(dataQuery);

				//	System.out.println("*****************curcorCount***" + cursor.count());
				//	System.out.println("*****************dataQ***" + dataQuery.toString());

				for (String key : cursor.next().keySet()) {

					if (!key.equals("_id")) {
						out.put(key);
					}
				}
			}
			status = out.length();

		} catch (Exception e) {
			e.printStackTrace();
			status = ERR_EXCEPTION;
		} finally {
			if (closeConnOnReturn) {
				mongoClient.close();
			}
			return status;
		}

	}%>