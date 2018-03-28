<%@ page trimDirectiveWhitespaces="true"%>
<%@ page language="java" contentType="application/json; charset=UTF-8"
	pageEncoding="UTF-8" session="false"%>

<%@ page import="java.sql.*"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.Arrays"%>
<%@ page import="more.Logs"%>
<%@ page import="more.StringUtility"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.util.regex.Matcher"%>
<%@ page import="java.util.regex.Pattern"%>
<%@ page import="java.text.ParseException"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<%@ page import="java.util.Calendar"%>

<%@ include file="api_db_utility.jsp"%> 

<%!public final static int ERR_SUCCESS = 1;

	public final static int ERR_EXCEPTION = -1;
	public final static int ERR_INVALID_PARAMETER = -2;
	public final static int ERR_CONFLICT = -3;

	public class Common {

		//private static final String DB_IP = "52.68.108.37";
		//private static final String DB_IP = "10.0.20.130";
		private static final String DB_IP_MORE = "127.0.0.1";
		public static final String DB_URL_MORE = "jdbc:mysql://" + DB_IP_MORE
				+ ":3306/more?useUnicode=true&characterEncoding=UTF-8&useSSL=false&verifyServerCertificate=false";
		public static final String DB_USER_MORE = "more";
		public static final String DB_PASS_MORE = "ideas123!";
		
		
		private static final String DB_IP_TRACKER = "124.9.6.64";
		public static final String DB_URL_TRACKER = "jdbc:mysql://" + DB_IP_TRACKER
				+ ":3306/tracker?useUnicode=true&characterEncoding=UTF-8&useSSL=false&verifyServerCertificate=false";
		public static final String DB_USER_TRACKER = "moresdk";
		public static final String DB_PASS_TRACKER = "moresdk123!";
		
	}

	public static class AppListData {
		public String app_id;
		public String table_name;
	}

	public static final String PERIOD_TYPE_DAY = "day";
	public static final String PERIOD_TYPE_WEEK = "week";
	public static final String PERIOD_TYPE_MONTH = "month";

	/** APP ID CHECK **/
	public int checkAppIdExistance(final String strAppId) {

		int status = select(null, "SELECT NULL FROM app WHERE app_id=?", new Object[] { strAppId },
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

	public JSONObject tryIfAppIdNotExsit(Connection conn, final String strAppId) {

		JSONObject jobj = null;

		int nCount = checkAppIdExistance(strAppId);
		if (nCount < 1) {
			switch (nCount) {
			case 0:
				jobj = ApiResponse.appIdNotFound();
				break;
			default:
				jobj = ApiResponse.byReturnStatus(nCount);
			}
		}
		return jobj;
	}
	
	
	/** TRACKER DATA APP ID CHECK ***/
	public int checkTrackerAppIdExist(final String strAppId, final AppListData appListData) {
		final Connection conn = connect(Common.DB_URL_TRACKER, Common.DB_USER_TRACKER, Common.DB_PASS_TRACKER);
		if (conn == null) {
			return ERR_EXCEPTION;
		}
		
		int status = select(null, "SELECT `table_name` FROM `tracker`.`app_list` WHERE `app_id`=?", new Object[] { strAppId },
				new ResultSetReader() {

					public int read(ResultSet rs) throws Exception {
						int itemCount = 0;
						while (rs.next()) {
							++itemCount;
							appListData.table_name = rs.getString("table_name");
						}
						return itemCount;
					}
				});
		closeConn(conn);
		return status;
	}
	
	
	
	/** VALIDATIONS **/
	public static boolean isValidAppId(final String s) {
		return StringUtility.isValid(s);
	}

	public boolean isValidDate(String dateToValidate, String dateFromat) {

		if (dateToValidate == null) {
			return false;
		}

		SimpleDateFormat sdf = new SimpleDateFormat(dateFromat);
		sdf.setLenient(false);

		try {
			//if not valid, it will throw ParseException
			Date date = sdf.parse(dateToValidate);
			System.out.println(date);

		} catch (ParseException e) {

			e.printStackTrace();
			return false;
		}

		return true;
	}
	
	 public static boolean isNotEmptyString(final String s) {
	    	return s != null && s.length() > 0;
	    }

	public boolean isValidStartDate(String sd, String ed, String dateFromat) {

		SimpleDateFormat sdf = new SimpleDateFormat(dateFromat);
		sdf.setLenient(false);

		try {
			//check startDate before endDate
			boolean validStartDate = sdf.parse(sd).before(sdf.parse(ed));
			if (validStartDate == false)
				return false;

		} catch (ParseException e) {

			e.printStackTrace();
			return false;
		}

		return true;
	}

	public static boolean isValidDateInSameMonth(final String sd, final String ed, String dateFromat) {

		SimpleDateFormat sdf = new SimpleDateFormat(dateFromat);
		sdf.setLenient(false);

		try {
			Date date1 = sdf.parse(sd);
			Date date2 = sdf.parse(ed);

			Calendar c1 = Calendar.getInstance();
			Calendar c2 = Calendar.getInstance();
			c1.setTime(date1);
			c2.setTime(date2);

			boolean sameMonth = c1.get(Calendar.MONTH) == c2.get(Calendar.MONTH);
			if (sameMonth == false)
				return false;

		} catch (ParseException e) {

			e.printStackTrace();
			return false;
		}

		return true;
	}
	
	%>