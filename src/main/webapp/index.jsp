<%@ include file="/context.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
    
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" >
        <meta name="google-site-verification" content="RIM1jcVM_GCYDz0SivW1kUhog3SNhVAgoA8A0SFWfQM" />
    
        <link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
        <link rel="icon" href="favicon.ico" type="image/x-icon" />
        <link type="text/css" rel="stylesheet" href="css/normalize/normalize.css" />
        <link type="text/css" rel="stylesheet" href="css/smoothness/jquery-ui-1.10.0.custom.min.css" />
        <!-- Import OL CSS, auto import does not work with our minified OL.js build -->
        <link rel="stylesheet" type="text/css" href="js/openlayers/theme/default/style.css">
        <!-- Basic CSS definitions -->
        <link rel="stylesheet" type="text/css" href="css/openlayers/basic.css">
        <link type="text/css" rel="stylesheet" href="css/custom.css" />
        <link type="text/css" rel="stylesheet" href="css/app.css" />
        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <![endif]-->
        <jsp:include page="template/USGSHead.jsp">
            <jsp:param name="relPath" value="" />
            <jsp:param name="shortName" value="USGS Sediment Data Portal" />
            <jsp:param name="title" value="USGS Sediment Data Portal" />
            <jsp:param name="description" value="" />
            <jsp:param name="author" value="USGS" />
            <jsp:param name="keywords" value="" />
            <jsp:param name="publisher" value="" />
            <jsp:param name="revisedDate" value="" />
            <jsp:param name="nextReview" value="" />
            <jsp:param name="expires" value="never" />
            <jsp:param name="development" value="<%= development %>" />
            <jsp:param name="google-analytics-account-code" value="<%= googleAnalyticsAccountNumber %>" />
        </jsp:include>
        <script type="text/javascript" src="js/jquery/jquery-1.10.2.min.js"></script>
        <script type="text/javascript" src="js/openlayers/OpenLayers.js"></script>
        <script type="text/javascript" src="js/utils.js"></script>
        <!-- Google Analytics Setup -->
	<script type="text/javascript" async="" src="https://www.google-analytics.com/ga.js"></script>
	<script type="text/javascript">
		   var _gaq = _gaq || [];
		   _gaq.push(['_setAccount', 'UA-46483138-2']);
		  _gaq.push (['_gat._anonymizeIp']);
		  _gaq.push(['_trackPageview']);
    

		 (function() {
        		  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
        		  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
        		  var scripts = document.getElementsByTagName('script');
        		  var s = scripts[scripts.length-1]; s.parentNode.insertBefore(ga, s);
			 })();

	</script>
    </head>
    
    <body>
        <%-- Loads during application startup, fades out when application is built --%>
        <!--  jsp:include page="components/application-overlay.jsp">< /jsp:include -->

        <div class="container-fluid">
            <div class="row-fluid" id="header-row" style="min-width: 1388px;">
                <jsp:include page="template/USGSHeader.jsp">
                    <jsp:param name="relPath" value="" />
                    <jsp:param name="header-class" value="" />
                    <jsp:param name="site-title" value="USGS Sediment Data Portal" />
                </jsp:include>
            </div>
            
            <div class="row-fluid" id="content-row">
                <!-- NAV -->
                <div class="span1" id='nav-list'>
                    <ul id="stage-select-tablist" class="nav nav-pills nav-stacked">
                    <!-- 
                        <li class="active"><a href="#shorelines" data-toggle="tab"><img id="shorelines_img" src="images/workflow_figures/shorelines.png" title="Display Shorelines"/></a></li>
                        <li><a href="#baseline" data-toggle="tab"><img id="baseline_img" src="images/workflow_figures/baseline_future.png" title="Display Baseline"/></a></li>
                        <li><a href="#transects" data-toggle="tab"><img id="transects_img" src="images/workflow_figures/transects_future.png" title="Calculate Transects"/></a></li>
                        <li><a href="#calculation" data-toggle="tab"><img id="calculation_img" src="images/workflow_figures/calculation_future.png" title="Show Calculation"/></a></li>
                        <li><a href="#results" data-toggle="tab"><img id="results_img" src="images/workflow_figures/results_future.png" title="Display Results"/></a></li>
                     -->
                    </ul>
                    <div id="app-spinner" class="mapSpinner"><img src="images/spinner/spinner-big.gif"  class="mapSpinner"/></div>
                </div>

                <!-- Toolbox -->
                <div class="span4" id="toolbox-span">
                    <div id="toolbox-well" class="well well-small tab-content">


                    </div>

                </div>

                <!-- MAP -->
                <div class="span7" id="map-span">
                    <div id="map-well" class="well well-small tab-content">
                        <div class="olMap" id="map"></div>
                        <div id="nlcdlegend">
                            <span id="nlcdthumb" class="nlcdThumb legendThumb">NLCD Legend</span>
                            <a href="http://www.mrlc.gov/nlcd06_leg.php" target="_tab"><img id="nlcdimg" src="images/nlcdlegend.png"></a>
                        </div>
                        <div id="applyFilter-warn" class="hidden filterWarn inputFilterWarnOn pleaseFix">
                            Please address errors.
                        </div>
				        <div id="filterDiv" class="filter filterScroll">
				        </div>
                        <div id="siteInfo">
                            <jsp:include page="siteInfo.jsp"/>
                        </div>
                    </div>
                </div>

            </div>
            <div class="row-fluid" id="alert-row">
                <div id="application-alert-container" class="span11 offset1"></div>
            </div>

            <div class="row-fluid" id="footer-row">
                <jsp:include page="template/USGSFooter.jsp">
                    <jsp:param name="relPath" value="" />
                    <jsp:param name="header-class" value="" />
                    <jsp:param name="site-url" value="<script type='text/javascript'>document.write(document.location.href);</script>" />
                    <jsp:param name="contact-info" value="<a href='mailto:SedimentPortal_HELP@usgs.gov?Subject=Sediment%20Portal%20Feedback'>Sediment Portal Help</a>" />
                </jsp:include>
            </div>
        
        </div>
		
		<%-- Stuff that isn't shown in the application but is used by JS --%>
        <div id="modal-window" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="modal-window-label" aria-hidden="true">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                <h3 id="modal-window-label"></h3>
            </div>
            <div class="modal-body">
                <div id="modal-body-content"></div>
            </div>
            <div class="modal-footer"></div>
        </div>
        <div id="noFiltersConfirmation" title="Large Download Confirmation" class="hidden"> 
            <p>No filters have been applied. All data for all sites will be downloaded for the data types selected.</p>
        </div>
        <div id="splashContent" class="hidden" title="Welcome to the USGS Sediment Data Portal">
        	  <p style="font-size: 12px;">
        	  	Use the USGS sediment data portal to find and interpret USGS discrete and daily suspended-sediment as well as related data. 
        	  </p>
        	  <h3>Data Update</h3>
        	  <p style="margin-top: -12px;font-size: 12px;">
		  	The sediment portal has been updated with data through July 15, 2017.  As part of these updates, the previous restriction that only allowed users to view and download data from sites with at least 15 or more discrete samples has been removed.  Users can now visualize and download data from all sites with discrete suspended-sediment analyses.
		  </p>
        	  <h3>Data Source</h3>
        	  <p style="margin-top: -12px;font-size: 12px;">
        	  	The USGS National Water Information System (NWIS) is the original source of all daily and discrete suspended-sediment data presented in the portal, though some suspended-sediment data hosted by NWIS are not provided via this portal. 
        	  </p>
        	  <h3>Help</h3>
            <p style="margin-top: -12px;font-size: 12px;">
            	Get information about the data presented or for instructions on site navigation
		  </p>
		  <ul style="margin-top: -8px;">
            	<li>See <a href="helpGuide.jsp">User Guide</a></li>
            	<li>View video demonstrations (<a href="http://www.youtube.com/watch?v=kXvlKzqSpzI">Demo 1</a>, <a href="http://www.youtube.com/watch?v=V6FHRZv14MQ">Demo 2</a>, <a href="http://www.youtube.com/watch?v=CBFSsxsY-_M">Demo 3</a>)</li>
            </ul>
            <h3 style="float: right;margin-right: 15px;margin-top: 10px;"><a href="helpQuick.jsp">> > > Click for Quick Start guide.</a></h3>
        </div>
        <jsp:include page="siteLegend.jsp"/>
        <jsp:include page="download.jsp"/>
        <jsp:include page="menu.jsp"/>
        
    
    <script type="text/javascript" src="js/jquery-ui/jquery-ui-1.10.0.custom.min.js"></script>
    <script type="text/javascript" src="js/util/util.js"></script>
    <script type="text/javascript" src="js/ui/ui.js"></script>
    <script src="js/openlayers/extension/Raster.js"></script>
    <script src="js/openlayers/extension/Raster/Grid.js"></script>
    <script src="js/openlayers/extension/Raster/Composite.js"></script>
    <script src="js/openlayers/extension/Raster/Operation.js"></script>
    <script src="js/openlayers/extension/Layer/Raster.js"></script>    
    <script type="text/javascript" src="js/map.js" defer="defer" ></script>
    <script type="text/javascript" src="js/filter-api.js"></script>
    <script type="text/javascript" src="js/filter.js"></script>
    <script type="text/javascript" src="js/jquery-cookie/jquery.cookie.js"></script>
    <script type="text/javascript" src="js/onReady.js"></script>
    
</body>
</html>
