package org.example.systemservice.repository;

import org.example.systemservice.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {

    boolean existsByPhoneAndIsDeleted(String phone, Integer isDeleted);

    Optional<User> findByPhoneAndIsDeleted(String phone, Integer isDeleted);

    boolean existsByIdAndUserTypeAndIsDeleted(Long id, Integer userType, Integer isDeleted);
}
