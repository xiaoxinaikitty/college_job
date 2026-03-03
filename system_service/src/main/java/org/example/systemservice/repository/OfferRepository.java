package org.example.systemservice.repository;

import org.example.systemservice.entity.Offer;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OfferRepository extends JpaRepository<Offer, Long> {

    List<Offer> findByStudentUserIdOrderByCreatedAtDesc(Long studentUserId);

    Optional<Offer> findByIdAndStudentUserId(Long id, Long studentUserId);

    List<Offer> findByEnterpriseIdOrderByCreatedAtDesc(Long enterpriseId);

    Optional<Offer> findByIdAndEnterpriseId(Long id, Long enterpriseId);

    Optional<Offer> findByApplicationId(Long applicationId);
}
