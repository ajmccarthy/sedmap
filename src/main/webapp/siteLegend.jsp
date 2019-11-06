<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
	java.util.Date today = new java.util.Date();
	java.text.DateFormat df = new java.text.SimpleDateFormat("MM-dd-yyyy");
	String date = df.format(today);	
%>

    <div id="siteLegend" class="siteLegend">
      <div class="legendEntry" style="height: 78px;">
        <div style="margin-left: 8px;margin-top: 2px;">Discrete</div>
        <div class="legendIcon" style="clear: left;margin-top: 2px;"><img style="width:40px; height:40px;" src="./images/discretelegend.png"/></div>
        <div style="font-size: 10px;margin-top: 2px;line-height: 13px;">Discrete suspended-sediment sites</div>
        <div style="font-size: 8px;margin-top: 2px;">Data current as of 9-17-19. Point size is proportional to number of samples.</div>
      </div>
      <div class="legendEntry" style="height: 78px;">
        <div style="margin-left: 8px;margin-top: 2px;">Daily</div>
        <div class="legendIcon" style="clear: left;margin-top: 2px;"><img style="width:40px; height:40px;" src="./images/dailylegend.png"/></div>
        <div style="font-size: 10px;margin-top: 2px;line-height: 13px;">Daily suspended-sediment sites</div>
        <div style="font-size: 8px;margin-top: 2px;">Data current as of <%= date %>. Point size proportional to years of available data.</div>
      </div>
    </div>
    <span id="sitethumb" class="siteThumb legendThumb" style="height:18px;">Site Legend</span>
