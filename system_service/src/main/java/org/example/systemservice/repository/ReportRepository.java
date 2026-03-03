package org.example.systemservice.repository;

import org.example.systemservice.entity.Report;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReportRepository extends JpaRepository<Report, Long> {

    List<Report> findByReporterUserIdOrderByCreatedAtDesc(Long reporterUserId);
}
