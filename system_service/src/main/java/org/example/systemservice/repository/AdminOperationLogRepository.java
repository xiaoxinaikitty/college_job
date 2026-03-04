package org.example.systemservice.repository;

import org.example.systemservice.entity.AdminOperationLog;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminOperationLogRepository extends JpaRepository<AdminOperationLog, Long> {
}
