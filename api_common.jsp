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

<%@ include file="api_db_utility.jsp"%>  

<%!
	public final static int ERR_SUCCESS = 1;

	public final static int ERR_EXCEPTION = -1;
	public final static int ERR_INVALID_PARAMETER = -2;
	public final static int ERR_CONFLICT = -3;
	
	
	public class Common {
	
		//private static final String DB_IP = "52.68.108.37";
		//private static final String DB_IP = "10.0.20.130";
		private static final String DB_IP = "127.0.0.1";
		
		
		public static final String DB_URL_MORE = "jdbc:mysql://" + DB_IP + ":3306/more?useUnicode=true&characterEncoding=UTF-8&useSSL=false&verifyServerCertificate=false";
		public static final String DB_USER = "more";
		public static final String DB_PASS = "ideas123!";
		
	}
	
	public static class AppData {
		public String app_id;	
		
	}
	
	private static final String PERIOD_TYPE_DAY = "day";
	private static final String PERIOD_TYPE_WEEK = "week";
	private static final String PERIOD_TYPE_MONTH = "month";
	

	/** APP ID CHECK **/
	public int checkAppIdExistance(final String strAppId) {
	
	int status = select(null, "SELECT NULL FROM app WHERE app_id=?", new Object[]{strAppId}, new ResultSetReader() {
		
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
	

    public static boolean isValidAppId(final String s) {
        return StringUtility.isValid(s);
    }
    
	
	public boolean isValidDate(String dateToValidate, String dateFromat){

		if(dateToValidate == null){
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
	
	
%>