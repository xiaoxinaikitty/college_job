package org.example.systemservice.repository;

import org.example.systemservice.entity.EnterpriseReview;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EnterpriseReviewRepository extends JpaRepository<EnterpriseReview, Long> {

    boolean existsByApplicationIdAndStudentUserId(Long applicationId, Long studentUserId);

    List<EnterpriseReview> findByStudentUserIdOrderByCreatedAtDesc(Long studentUserId);
}
