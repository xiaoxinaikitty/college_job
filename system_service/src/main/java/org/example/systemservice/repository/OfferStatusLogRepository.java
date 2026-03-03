package org.example.systemservice.repository;

import org.example.systemservice.entity.OfferStatusLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OfferStatusLogRepository extends JpaRepository<OfferStatusLog, Long> {

    List<OfferStatusLog> findByOfferIdOrderByCreatedAtAsc(Long offerId);
}
