package org.example.systemservice.repository;

import org.example.systemservice.entity.PenaltyRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PenaltyRecordRepository extends JpaRepository<PenaltyRecord, Long> {
}
