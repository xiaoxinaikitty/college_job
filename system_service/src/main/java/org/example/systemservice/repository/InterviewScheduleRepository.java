package org.example.systemservice.repository;

import org.example.systemservice.entity.InterviewSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface InterviewScheduleRepository extends JpaRepository<InterviewSchedule, Long> {

    @Query("""
            select i from InterviewSchedule i
            where i.applicationId in (
              select a.id from JobApplication a where a.studentUserId = :studentUserId
            )
            order by i.scheduledAt desc
            """)
    List<InterviewSchedule> findByStudentUserId(@Param("studentUserId") Long studentUserId);

    @Query("""
            select i from InterviewSchedule i
            where i.id = :interviewId and i.applicationId in (
              select a.id from JobApplication a where a.studentUserId = :studentUserId
            )
            """)
    Optional<InterviewSchedule> findByIdAndStudentUserId(
            @Param("interviewId") Long interviewId,
            @Param("studentUserId") Long studentUserId
    );
}
