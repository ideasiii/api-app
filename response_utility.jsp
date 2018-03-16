
<%@ page import="org.json.JSONObject"%>
<%!//response type to client on request failure

	public static class ApiResponse {

		public static final String STATUS_DATA_NOT_FOUND = "ER0100";

		public static final String STATUS_MISSING_PARAMETER = "ER0120";

		public static final String STATUS_INVALID_PARAMETER = "ER0220";

		public static final String STATUS_CONFLICTS = "ER0240";

		public static final String STATUS_INTERNAL_ERROR = "ER0500";

		public static JSONObject error(String status) {
			return error(status, null);
		}

		public static JSONObject error(String status, String message) {
			JSONObject jobj = new JSONObject();
			jobj.put("success", false);
			jobj.put("error", status);
			if (message == null) {
				// fill with canned message
				if (status == null) {
					message = "Internal server error.";
				} else if (status.equals(STATUS_DATA_NOT_FOUND)) {
					message = "The record you requested does not exist.";
				} else if (status.equals(STATUS_MISSING_PARAMETER)) {
					message = "Missing required parameter.";
				} else if (status.equals(STATUS_INVALID_PARAMETER)) {
					message = "Invalid input.";
				} else if (status.equals(STATUS_CONFLICTS)) {
					message = "There is a conflict between the request and existing record";
				} else if (status.equals(STATUS_INTERNAL_ERROR)) {
					message = "Internal server error.";
				} else {
					message = "Unknown error.";
				}
			}
			jobj.put("message", message);
			return jobj;
		}

		public static JSONObject successTemplate() {
			JSONObject jobj = new JSONObject();
			jobj.put("success", true);
			return jobj;
		}

		public static JSONObject unknownError() {
			JSONObject jobj = new JSONObject();
			jobj.put("success", false);
			jobj.put("error", STATUS_INTERNAL_ERROR);
			jobj.put("message", "Unknown error.");
			return jobj;
		}

		public static JSONObject appIdNotFound() {
			JSONObject jobj = new JSONObject();
			jobj.put("success", false);
			jobj.put("error", STATUS_DATA_NOT_FOUND);
			jobj.put("message", "app_id not found.");
			return jobj;
		}
		
		public static JSONObject dataNotFound() {
			JSONObject jobj = new JSONObject();
			jobj.put("success", false);
			jobj.put("error", STATUS_DATA_NOT_FOUND);
			jobj.put("message", "data not found.");
			return jobj;
		}

		public static JSONObject byReturnStatus(int status) {
			switch (status) {
			case ERR_EXCEPTION:
				return ApiResponse.error(ApiResponse.STATUS_INTERNAL_ERROR);
			default:
				return ApiResponse.unknownError();
			}
		}
	}
	
%>
