package org.example.systemservice.repository;

import org.example.systemservice.entity.Enterprise;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface EnterpriseRepository extends JpaRepository<Enterprise, Long> {

    Optional<Enterprise> findByOwnerUserId(Long ownerUserId);
}
