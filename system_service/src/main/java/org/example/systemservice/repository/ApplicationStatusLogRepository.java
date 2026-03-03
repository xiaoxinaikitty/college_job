package org.example.systemservice.repository;

import org.example.systemservice.entity.ApplicationStatusLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ApplicationStatusLogRepository extends JpaRepository<ApplicationStatusLog, Long> {

    List<ApplicationStatusLog> findByApplicationIdOrderByCreatedAtAsc(Long applicationId);
}
