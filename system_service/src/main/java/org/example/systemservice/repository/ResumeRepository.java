package org.example.systemservice.repository;

import jakarta.transaction.Transactional;
import org.example.systemservice.entity.Resume;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ResumeRepository extends JpaRepository<Resume, Long> {

    List<Resume> findByStudentUserIdOrderByUpdatedAtDesc(Long studentUserId);

    Optional<Resume> findByIdAndStudentUserId(Long id, Long studentUserId);

    @Modifying
    @Transactional
    @Query("update Resume r set r.isDefault = 0 where r.studentUserId = :studentUserId")
    void clearDefaultByStudentUserId(Long studentUserId);
}
