package gov.cida.sedmap.web;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import gov.cida.sedmap.io.util.ErrUtils;
import gov.cida.sedmap.io.util.SessionUtil;
import gov.usgs.cida.proxy.ProxyServlet;


public class GeoserverProxy extends ProxyServlet {

	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger(GeoserverProxy.class);

	public static final String NHD_ENV_SERVER = "sedmap/nhdServer";
	public static final String NHD_ENV_PATH   = "sedmap/nhdPath";
	public static final String SED_ENV_SERVER = "sedmap/sedServer";	// This is our GeoServer instance

	private String NHD_SERVER = "http://cida-wiwsc-wsdev.er.usgs.gov:8080";
	private String NHD_PATH   = "/geoserver/NHDPlusFlowlines/wms";
	private String SED_SERVER = "http://localhost:8080";



	public GeoserverProxy() {
		try {
			NHD_SERVER = SessionUtil.lookup("java:comp/env/"+NHD_ENV_SERVER, NHD_SERVER);
			NHD_PATH   = SessionUtil.lookup("java:comp/env/"+NHD_ENV_PATH,   NHD_PATH);
			SED_SERVER = SessionUtil.lookup("java:comp/env/"+SED_ENV_SERVER, SED_SERVER);
		} catch (Exception e) {
			logger.warn("Falling back to default geoservers. NHD:" + NHD_SERVER+NHD_PATH
					+" and sedmap: " + SED_SERVER, e);
		}
		// lets concat this once
		NHD_SERVER  += NHD_PATH;
	}



	@Override
	public URL buildRequestURL(HttpServletRequest request, URL baseURL)
			throws MalformedURLException {
		String uri = request.getRequestURI();

		String params = request.getQueryString();
		if (uri.contains("flow")) {
			uri = NHD_SERVER; //"http://cida-wiwsc-wsdev.er.usgs.gov:8080/geoserver/NHDPlusFlowlines/wms";
			logger.error(uri+"?"+params);
		} else {
			uri = uri.replace("sediment/map", "geoserver/sedmap");
			uri = SED_SERVER + uri; //"http://cida-wiwsc-sedmapdev.er.usgs.gov:8080" + uri;
		}
		return new URL(uri +"?" +params);
	}



	@Override
	public void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		doGeo(request, response);
	}



	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			doGeo(request, response);
		} catch (Exception e) {
			ErrUtils.handleExceptionResponse(request,response,e);
		}
	}



	protected void doGeo(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		HttpURLConnection  targetConn = null; //Do not disconnect when done
		OutputStreamWriter targetConnWriter = null; // Close when done
		InputStream 	   targetIs = null; // Close when done
		OutputStream       responseOutputStream = null;

		URL targetURL     = buildRequestURL(request, null);


		try {
			targetConn = getConnection(targetURL, "GET", 15000, 60000);
			// Copy headers from the incoming request to the forwarded request
			copyHeaders(request, targetConn);

			// Applications can override the next method to addStrategy app specific properties
			addCustomRequestHeaders(request, targetConn);

			// Establish connection to forwarded server
			targetConn.setDoOutput(true);
			targetConn.connect();

			// No custom params are defined, so we can just copy the body of
			// the request from the incoming request to the forwarded request
			copyStreams(request.getInputStream(), targetConn.getOutputStream());

			// Copy header back from the forwarded response to the servlet response
			copyHeaders(targetConn, response);

			response.setStatus(targetConn.getResponseCode());
			responseOutputStream = response.getOutputStream();
			targetIs = targetConn.getInputStream();
			copyStreams(targetIs, responseOutputStream);

			//		} catch (IOException e) {
			//			log.warn("An exception was thrown in the Proxy Servlet", e);
			//			if (log.isDebugEnabled()) {
			//				dumpRequest(request);
			//				//attempting to access these seems to cause another error
			//				//dumpURLConnProperties(targetConn);
			//			}
		} catch (Exception e) {
			logger.warn("An exception was thrown in the Proxy Servlet", e);
			if (logger.isDebugEnabled()) {
				dumpRequest(request);
				//attempting to access these seems to cause another error
				//dumpURLConnProperties(targetConn);
			}

			//This err is caught before writing to the output stream, so send err content
			if (targetConn != null) {
				response.setStatus(targetConn.getResponseCode());
				handleErrorStream(targetConn, responseOutputStream);
			}
		} finally {
			if (targetConnWriter != null) {
				//This is likely not an err at all - could already be closed.
				try { targetConnWriter.close(); } catch (Exception e) {}
			}

			if (targetIs != null) {
				//This is likely not an err at all - could already be closed.
				try { targetIs.close(); } catch (Exception e) {}
			}
		}
	}

}
