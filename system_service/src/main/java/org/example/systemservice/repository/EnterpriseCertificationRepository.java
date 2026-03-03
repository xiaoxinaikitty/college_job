package org.example.systemservice.repository;

import org.example.systemservice.entity.EnterpriseCertification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EnterpriseCertificationRepository extends JpaRepository<EnterpriseCertification, Long> {

    Optional<EnterpriseCertification> findTopByEnterpriseIdOrderBySubmittedAtDesc(Long enterpriseId);
}
