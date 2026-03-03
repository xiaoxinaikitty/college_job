package org.example.systemservice.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.DatabaseMetaData;

@Component
public class DataSourceStartupLogger implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(DataSourceStartupLogger.class);

    private final DataSource dataSource;

    public DataSourceStartupLogger(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    public void run(ApplicationArguments args) {
        try (Connection connection = dataSource.getConnection()) {
            DatabaseMetaData metaData = connection.getMetaData();
            log.info("Active JDBC URL: {}", metaData.getURL());
            log.info("DB Product: {} {}", metaData.getDatabaseProductName(), metaData.getDatabaseProductVersion());
            log.info("DB User: {}", metaData.getUserName());
        } catch (Exception e) {
            log.error("Failed to inspect datasource metadata: {}", e.getMessage(), e);
        }
    }
}
