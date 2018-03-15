<%!

/** select() read ResultSet callback */
public interface ResultSetReader {
    int read(ResultSet rs) throws Exception;
}


public static Connection connect(final String strDB, final String strUser, final String strPwd) {
    Connection conn = null;
    try {
        Class.forName("com.mysql.jdbc.Driver");
        conn = DriverManager.getConnection(strDB, strUser, strPwd);
    } catch (Exception e) {
        e.printStackTrace();
    }
    return conn;
}

public static int closeConn(Connection conn) {
    try {
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        return ERR_EXCEPTION;
    }
    return ERR_SUCCESS;
}


/** SELECT **/
public int select(Connection conn, final String template,
        final Object[] params, final ResultSetReader reader) {
    PreparedStatement pst = null;
    boolean closeConnOnReturn = false;
	int status = 0; 
	
    try {
        if (conn == null) {
           conn = connect(Common.DB_URL_MORE, Common.DB_USER, Common.DB_PASS);
           closeConnOnReturn = true;
        }
        pst = conn.prepareStatement(template);
        int paramIndex = 1;
        for (int i = 0; i < params.length; i++) {
            Object param = params[i];
            if (param instanceof Integer) {
                pst.setInt(paramIndex++, ((Integer)param).intValue());
            } else if (param instanceof Long) {
                pst.setLong(paramIndex++, ((Long)param).longValue());
            } else if (param instanceof String) {
                pst.setString(paramIndex++, (String)param);
            } else {
                throw new IllegalArgumentException(
                        "parameter with unsupported type " + param.getClass().getName());
            }
        }
        ResultSet rs = pst.executeQuery();
        status = reader.read(rs);
		
        rs.close();
        pst.close();
    } catch (Exception e) {
        e.printStackTrace();
        status = ERR_EXCEPTION;
    } finally {
        if (closeConnOnReturn) {
            closeConn(conn);
        }
        return status;
    }
}

%>
