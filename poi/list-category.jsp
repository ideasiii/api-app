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
	
		
		JSONObject jobj = new JSONObject();
		JSONArray resArray = new JSONArray();
		int nCount = getCategoryList(resArray);

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


	public int getCategoryList(final JSONArray out) {
		final Connection conn = connect(Common.DB_URL_TRACKER, Common.DB_USER_TRACKER, Common.DB_PASS_TRACKER);
		int status = select(conn,
				"SELECT `tag` FROM `google_poi_tag_list`",
				new Object[] {  },
				new ResultSetReader() {
					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;

						while (rs.next()) {
							++itemCount;
							String strCategory = rs.getString("tag");
							
							if (isNotEmptyString(strCategory)){
							out.put(strCategory);
							}
						}
						return itemCount;
					}
				});
		return status;
	}

	
	
	%>