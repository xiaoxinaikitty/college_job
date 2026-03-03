package org.example.systemservice.repository;

import org.example.systemservice.entity.InterviewStudentConfirm;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface InterviewStudentConfirmRepository extends JpaRepository<InterviewStudentConfirm, Long> {

    Optional<InterviewStudentConfirm> findByInterviewIdAndStudentUserId(Long interviewId, Long studentUserId);

    Optional<InterviewStudentConfirm> findByInterviewId(Long interviewId);
}
