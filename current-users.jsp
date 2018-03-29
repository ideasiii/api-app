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
		final String strTableName;

		if (!isValidAppId(strAppId)) {
			return ApiResponse.error(ApiResponse.STATUS_INVALID_PARAMETER, "Invalid app_id.");
		}

		//check APP ID from DB_MORE before connect to DB_Tracker
		int nCheckAppIdExist = checkAppIdExistance(strAppId);
		if (0 >= nCheckAppIdExist) {
			switch (nCheckAppIdExist) {
			case 0:
				return ApiResponse.appIdNotFound();
			default:
				return ApiResponse.byReturnStatus(nCheckAppIdExist);
			}
		}

		//check table name exist in DB_Tracker
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

		Date dTime = new Date(System.currentTimeMillis()-30*60*1000);
		SimpleDateFormat sdf = new SimpleDateFormat ("yyyy-MM-dd HH:mm:ss");
		String strTime = sdf.format(dTime);
		System.out.println("*********Time: " + strTime);
		
		JSONObject jobj = new JSONObject();
		int nCount = queryCurrentUserAmount(strTime, strTableName);

		if (0 < nCount) {
			jobj = ApiResponse.successTemplate(); 
			jobj.put("count", nCount);

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


	public int queryCurrentUserAmount(final String strTime, final String strTableName) {
		final Connection conn = connect(Common.DB_URL_TRACKER, Common.DB_USER_TRACKER, Common.DB_PASS_TRACKER);
		int status = select(conn,
				"SELECT COUNT(DISTINCT id) FROM " + strTableName + " WHERE `create_date` >= ?",
				new Object[] { strTime },
				new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
						}
						return itemCount;
					}
				});
		return status;
	}

	
	
	%>