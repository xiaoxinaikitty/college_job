package org.example.systemservice.repository;

import org.example.systemservice.entity.JobPosting;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface JobPostingRepository extends JpaRepository<JobPosting, Long> {

    @Query("""
            select j from JobPosting j
            where j.status = 3
              and (:keyword is null or j.title like %:keyword% or j.description like %:keyword%)
              and (:city is null or j.city = :city)
              and (:category is null or j.category = :category)
            """)
    Page<JobPosting> searchOnlineJobs(
            @Param("keyword") String keyword,
            @Param("city") String city,
            @Param("category") String category,
            Pageable pageable
    );

    Optional<JobPosting> findByIdAndStatus(Long id, Integer status);

    Optional<JobPosting> findByIdAndEnterpriseId(Long id, Long enterpriseId);

    List<JobPosting> findByEnterpriseIdOrderByCreatedAtDesc(Long enterpriseId);
}
