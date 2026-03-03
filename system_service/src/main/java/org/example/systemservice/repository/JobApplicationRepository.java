package org.example.systemservice.repository;

import org.example.systemservice.entity.JobApplication;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface JobApplicationRepository extends JpaRepository<JobApplication, Long> {

    boolean existsByJobIdAndStudentUserId(Long jobId, Long studentUserId);

    Optional<JobApplication> findByIdAndStudentUserId(Long id, Long studentUserId);

    List<JobApplication> findByStudentUserIdOrderByCreatedAtDesc(Long studentUserId);

    Optional<JobApplication> findByIdAndEnterpriseId(Long id, Long enterpriseId);

    List<JobApplication> findByEnterpriseIdOrderByCreatedAtDesc(Long enterpriseId);

    long countByJobId(Long jobId);
}
