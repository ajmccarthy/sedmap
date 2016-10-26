package gov.cida.sedmap.data;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import org.apache.log4j.Logger;
import org.geotools.jdbc.JDBCDataStoreFactory;
import org.geotools.jdbc.JDBCJNDIDataStoreFactory;

import gov.cida.sedmap.io.IoUtils;
import gov.cida.sedmap.io.util.SessionUtil;

public class FetcherConfig {
	private static final Logger logger = Logger.getLogger(FetcherConfig.class);

	Map<String, Object>       DATA_STORE_ENV;
	Map<String, List<Column>> TABLE_METADATA;
	Map<String, String>       DATA_TABLES;
	// TODO before making the following view - make sure it is still relevant
	// TODO create this view "select d.* from sedmap.discrete_sample_fact d join sedmap.discrete_stations s on s.site_no = d.site_no "

	Map<String, Class<? extends Formatter>> FILE_FORMATS;
	Map<String, String>       FIELD_TRANSLATIONS;
	List<String>              DATA_TYPES;
	List<String>              DATA_VALUES;

	protected static final String NWIS_URL_ENV     = "sedmap/NWIS_URL";
	protected static final String NWIS_URL_DEFAULT = "http://waterservices.usgs.gov/nwis/dv/?format=_format_&sites=_sites_&startDT=_startDate_&endDT=_endDate_&statCd=00003&parameterCd=00060,80154,80155";
	protected static String nwisUrl;

	protected String jndiDS = "java:comp/env/jdbc/sedmapDS";


	public FetcherConfig() {
		this(null);
	}

	public FetcherConfig(String jndiResource) {
		if (jndiResource != null) {
			jndiDS = jndiResource;
		}
	}


	// this prevents concurrency issues
	public FetcherConfig init() {
		logger.info("Static Fetcher initialization.");
		nwisUrl = SessionUtil.lookup(NWIS_URL_ENV, NWIS_URL_DEFAULT);

		FIELD_TRANSLATIONS = configFieldTranslaions();
		FILE_FORMATS       = configFormats();
		DATA_TABLES        = configTables();
		DATA_TYPES         = configDataTypes();
		DATA_VALUES        = configDataValues();
		DATA_STORE_ENV     = configDataStore();

		// TODO was unmodifiable but the following quick fix disallows it and we are out of time on the project
		TABLE_METADATA     = loadTableMetadata();

		// TODO this is a quick fix because we are out of time on the project
		List<Column> cols = TABLE_METADATA.get("DAILY_STATIONS_DL");
		if (cols != null) {
			cols.add(new Column("SAMPLE_YEARS", Types.NUMERIC, 15, false));
		}
		cols = TABLE_METADATA.get("DISCRETE_STATIONS_DL");
		if (cols != null) {
			cols.add(new Column("SAMPLE_COUNT", Types.NUMERIC, 15, false));
		}
		return this;
	}



	protected Map<String, String> configFieldTranslaions() {
		logger.info("Static Fetcher configFieldTranslaions.");
		Map<String,String> trans = new HashMap<String,String>();
		trans.put("HUC_8","HUC_12");
		return Collections.unmodifiableMap(trans);
	}



	private List<String> configDataTypes() {
		logger.info("Static Fetcher configDataTypes.");
		return Collections.unmodifiableList( Arrays.asList("discrete","daily") ); // discrete first so if want flow can send w/ daily
	}



	private List<String> configDataValues() {
		logger.info("Static Fetcher configDataValues.");
		return Collections.unmodifiableList( Arrays.asList("sites","data") ); // sites first for use with NWIS data
	}



	protected Map<String, Class<? extends Formatter>> configFormats() {
		logger.info("Static Fetcher configFormats.");
		Map<String, Class<? extends Formatter>> formats = new HashMap<String, Class<? extends Formatter>>();
		formats.put("csv", CsvFormatter.class);
		formats.put("rdb", RdbFormatter.class);
		formats.put("tsv", TsvFormatter.class);
		return Collections.unmodifiableMap(formats);
	}



	protected Map<String, String> configTables() {
		logger.info("Static Fetcher configTables.");
		Map<String,String> tables = new HashMap<String,String>();
		tables.put("daily_sites",    "DAILY_STATIONS_DL");
		tables.put("discrete_sites", "DISCRETE_STATIONS_DL");
		tables.put("discrete_data",  "DISCRETE_SAMPLE_FACT");
		return Collections.unmodifiableMap(tables);
	}



	protected Map<String, Object> configDataStore() {
		logger.info("Static Fetcher configDataStore.");
		Map<String, Object> env = new HashMap<String, Object>();
		env.put( JDBCDataStoreFactory.SCHEMA.getName(), "sedmap"); // OPTIONAL
		env.put( JDBCDataStoreFactory.DBTYPE.getName(), "oracle");
		env.put( JDBCDataStoreFactory.EXPOSE_PK.getName(), true);
		env.put( JDBCJNDIDataStoreFactory.JNDI_REFNAME.getName(), jndiDS);

		return Collections.unmodifiableMap(env);
	}


	protected Map<String, List<Column>> loadTableMetadata() {
		logger.info("Static Fetcher loadTableMetadata.");
		Connection cn = null;
		Statement  st = null;
		try {
			DataSource ds = SessionUtil.lookupDataSource(jndiDS);
			cn = ds.getConnection();
			st = cn.createStatement();

			Map<String, List<Column>> tableData = new HashMap<String, List<Column>>();

			ResultSet rs = null;
			for (String tableName : DATA_TABLES.values()) {
				try {
					rs = st.executeQuery("select * from sedmap." +tableName+ " where 0=1");
					List<Column> columnData = getTableColumns(rs);
					tableData.put(tableName, columnData);
					logger.info("Collected " +columnData.size()+ " columns metadata for table " +tableName);
				} catch (Exception e) {
					throw new RuntimeException("Did not find metadata for table "+tableName, e);
				} finally {
					IoUtils.quiteClose(rs);
				}
			}
			return tableData;
		} catch (Exception e) {
			handleMetadataException(e);
		} finally {
			IoUtils.quiteClose(st,cn);
		}
		return null;
	}


	protected void handleMetadataException(Exception e) {
		throw new RuntimeException("Failed it load table metadata",e);
	}

	// TODO this one connects once per table metadata and the other connects to retrieve all tables metadata
	protected List<Column> loadTableMetadata(String tableName) {
		logger.info("Static Fetcher loadTableMetadata.");
		Connection cn = null;
		Statement  st = null;
		ResultSet rs = null;
		try {
			DataSource ds = SessionUtil.lookupDataSource(jndiDS);
			cn = ds.getConnection();
			st = cn.createStatement();
			rs = st.executeQuery("select * from sedmap." +tableName+ " where 0=1");
			List<Column> columnData = getTableColumns(rs);
			logger.info("Collected " +columnData.size()+ " columns metadata for table " +tableName);
			return columnData;
		} catch (Exception e) {
			logger.error("failed to load table metadata " + tableName);
			handleMetadataException(e);
		} finally {
			IoUtils.quiteClose(rs,st,cn);
		}
		return null;
	}


	public List<Column> getTableColumns(ResultSet rs) throws SQLException {
		List<Column> columnData = new ArrayList<Column>();

		ResultSetMetaData md = rs.getMetaData();

		int columnCount = md.getColumnCount();
		for (int c = 1; c<= columnCount; c++) {
			String name = md.getColumnName(c);
			int    type = md.getColumnType(c);
			int    size = md.getScale(c);
			columnData.add( new Column(name, type, size, false) );
		}

		return  columnData; // was unmod but see comment above
	}



	public List<Column> getTableMetadata(String tableName) {
		List<Column> meta = TABLE_METADATA.get(tableName);

		if (meta == null) {
			meta = loadTableMetadata(tableName);
		}

		return meta;
	}
}
